import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:disk_space_2/disk_space_2.dart';
import 'package:flutter_quick_video_encoder/flutter_quick_video_encoder.dart';
import 'package:gal/gal.dart';

/// Диагностика записи: тайминги этапов, реальный fps, состояние декодера.
/// Включается через `--dart-define=REC_DIAG=true`, пишет в лог с префиксом
/// `[REC]` (`adb logcat -s flutter`), итог показывает в уведомлении.
const bool kRecorderDiagnostics = bool.fromEnvironment('REC_DIAG');

/// Минимальный интервал между кадрами, то есть 25 кадров в секунду.
const int _minFrameIntervalMs = 40;

/// Битрейт записи, 4 Мбит/с.
const int _videoBitrate = 4000000;

/// Notification callback
typedef OnRecorderNotification = void Function(bool isError, String message);

/// Processing state callback
typedef OnProcessingChanged = void Function(bool isProcessing);

/// Один снятый кадр: пиксели RGBA и размер, к которому привязан кодировщик.
typedef _Frame = ({Uint8List bytes, int width, int height});

/// Утилита для записи видео и создания снапшотов
class VideoRecorder {
  final GlobalKey videoKey;
  final OnRecorderNotification onNotification;
  final OnProcessingChanged? onProcessingChanged;

  /// Only read by diagnostics, to report the decoder state.
  final Player? player;

  bool isRecording = false;
  Stopwatch stopwatch = Stopwatch();
  bool _encoderStarted = false;

  VideoRecorder({
    required this.videoKey,
    required this.onNotification,
    this.onProcessingChanged,
    this.player,
  });

  /// Захват кадра в PNG — для снимка, который уходит в галерею картинкой.
  Future<Uint8List?> _captureSnapshot() async {
    try {
      final boundary =
          videoKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Snapshot error: $e');
      return null;
    }
  }

  /// Сделать снапшот и сохранить в галерею
  Future<void> takeSnapshot() async {
    try {
      DateTime now = DateTime.now();
      int timestamp = now.millisecondsSinceEpoch;

      Uint8List? imageData = await _captureSnapshot();
      if (imageData == null || imageData.isEmpty) {
        throw Exception("Failed to take snapshot: No data available.");
      }

      final directory = await getTemporaryDirectory();
      String fileName = 'snapshot_$timestamp.png';
      String filePath = '${directory.path}/$fileName';
      File file = File(filePath);
      await file.writeAsBytes(imageData);

      try {
        await Gal.putImage(filePath);
        onNotification(false, 'Snapshot successfully saved to gallery.');
      } catch (e) {
        onNotification(true, 'Failed to save snapshot to gallery.');
      }
    } catch (e) {
      onNotification(true, 'Failed to save snapshot to gallery.');
    }
  }

  /// Начать запись видео. Кадры кодируются на ходу, поэтому после остановки
  /// остаётся только закрыть файл и сохранить его в галерею.
  Future<void> startRecording() async {
    if (isRecording) return;

    isRecording = true;
    _encoderStarted = false;
    stopwatch
      ..reset()
      ..start();

    final diag = kRecorderDiagnostics ? _RecordingDiagnostics() : null;
    if (diag != null) {
      _log('start: ${_describeView()}');
      _playerStats().then((stats) => _log('player at start: $stats'));
    }

    final directory = await getTemporaryDirectory();
    final outputPath =
        '${directory.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    await _deleteLeftoverVideos(directory);

    int frames = 0;
    try {
      frames = await _captureLoop(outputPath, diag);
    } catch (e) {
      print('Recording error: $e');
      diag?.log('recording error: $e');
      onNotification(true, 'Something went wrong. Video recording stopped.');
    }

    isRecording = false;
    stopwatch.stop();
    if (diag != null) {
      diag.recorded = stopwatch.elapsed;
      diag.logCapture();
      _playerStats().then((stats) => _log('player at stop: $stats'));
    }

    onProcessingChanged?.call(true);
    await _finishVideo(outputPath, frames, diag);
    onProcessingChanged?.call(false);

    stopwatch.reset();
  }

  /// Остановить запись: цикл сам закроет файл и сохранит его.
  Future<void> stopRecording() async {
    isRecording = false;
  }

  /// Снимает кадры и сразу отдаёт их кодировщику. Возвращает число кадров,
  /// попавших в файл.
  Future<int> _captureLoop(
      String outputPath, _RecordingDiagnostics? diag) async {
    // Кодировщик пишет примерно по 0.5 МБ в секунду; останавливаемся, пока на
    // диске ещё остаётся место.
    final freeSpaceInMB = await DiskSpace.getFreeDiskSpace;
    final sizeLimit = ((freeSpaceInMB ?? 1024.0) * 1024 * 1024 * 0.8).toInt();

    int frames = 0;
    int width = 0;
    int height = 0;
    int nextFrameMs = 0;

    while (isRecording) {
      final waitMs = nextFrameMs - stopwatch.elapsedMilliseconds;
      if (waitMs > 0) {
        await Future.delayed(Duration(milliseconds: waitMs));
        continue;
      }

      final capturedAtMs = stopwatch.elapsedMilliseconds;
      nextFrameMs = capturedAtMs + _minFrameIntervalMs;
      diag?.frameStarted();

      final frame = await _captureFrame(diag);
      // stopRecording() may have run while we were capturing: this frame is
      // past the end of the recording.
      if (!isRecording) break;
      if (frame == null) continue;

      if (frames == 0) {
        width = frame.width;
        height = frame.height;
        await FlutterQuickVideoEncoder.setup(
          width: width,
          height: height,
          fps: 1000 ~/ _minFrameIntervalMs,
          videoBitrate: _videoBitrate,
          audioChannels: 0,
          audioBitrate: 0,
          sampleRate: 44100,
          filepath: outputPath,
          profileLevel: ProfileLevel.baselineAutoLevel,
        );
        _encoderStarted = true;
        diag?.frameSize = '${width}x$height';
      } else if (frame.width != width || frame.height != height) {
        // The boundary changed size mid-recording (rotation, layout): the
        // encoder is fixed to the size of the first frame.
        diag?.resized++;
        continue;
      }

      // Every frame carries its own capture time, so an uneven capture rate
      // does not speed the video up or slow it down.
      await _timed(
        diag?.append,
        () => FlutterQuickVideoEncoder.appendVideoFrame(
          frame.bytes,
          timestampUs: capturedAtMs * 1000,
        ),
      );
      frames++;
      diag?.frameAppended(frame.bytes);

      if (frames % 50 == 0 && await File(outputPath).length() >= sizeLimit) {
        onNotification(true, 'Storage limit reached. Stopping recording.');
        isRecording = false;
      }
    }

    return frames;
  }

  /// Снимок кадра без сжатия.
  Future<_Frame?> _captureFrame(_RecordingDiagnostics? diag) async {
    final boundary =
        videoKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;

    final image =
        await _timed(diag?.toImage, () => boundary.toImage(pixelRatio: 1.0));
    final byteData = await _timed(diag?.readback,
        () => image.toByteData(format: ui.ImageByteFormat.rawRgba));
    final width = image.width;
    final height = image.height;
    image.dispose();
    if (byteData == null) return null;

    final pixels = byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    final evenWidth = width ~/ 2 * 2;
    final evenHeight = height ~/ 2 * 2;
    if (evenWidth == width && evenHeight == height) {
      return (bytes: pixels, width: width, height: height);
    }
    return (
      bytes: _cropToEven(pixels, width, evenWidth, evenHeight, diag),
      width: evenWidth,
      height: evenHeight,
    );
  }

  /// H.264 не кодирует кадр с нечётной стороной, поэтому лишние столбец и
  /// строку отрезаем. Строка обходится без копирования, столбец требует
  /// переложить кадр построчно.
  Uint8List _cropToEven(Uint8List pixels, int width, int evenWidth,
      int evenHeight, _RecordingDiagnostics? diag) {
    final watch = diag == null ? null : (Stopwatch()..start());
    final Uint8List result;
    if (evenWidth == width) {
      result = Uint8List.sublistView(pixels, 0, width * evenHeight * 4);
    } else {
      final dstRowBytes = evenWidth * 4;
      final srcRowBytes = width * 4;
      result = Uint8List(dstRowBytes * evenHeight);
      for (var y = 0; y < evenHeight; y++) {
        result.setRange(
            y * dstRowBytes, y * dstRowBytes + dstRowBytes, pixels, y * srcRowBytes);
      }
    }
    if (watch != null) diag!.crop.add(watch.elapsedMicroseconds);
    return result;
  }

  /// Закрыть файл и отдать его в галерею.
  Future<void> _finishVideo(
      String outputPath, int frames, _RecordingDiagnostics? diag) async {
    final file = File(outputPath);
    try {
      if (_encoderStarted) {
        final finishing = Stopwatch()..start();
        await FlutterQuickVideoEncoder.finish();
        _encoderStarted = false;
        diag?.log('encoder: $frames frames, finish took '
            '${finishing.elapsedMilliseconds} ms');
      }

      if (frames == 0) {
        diag?.log('encoder: nothing was recorded');
        return;
      }

      await Gal.putVideo(outputPath);
      onNotification(
        false,
        diag == null
            ? 'Video successfully saved to gallery.'
            : 'Video saved. ${diag.shortSummary}',
      );
    } catch (e) {
      print("Video creation error: $e");
      diag?.log('encoder error: $e');
      onNotification(true, 'Failed to create video.');
    } finally {
      try {
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
  }

  /// Ролики остаются во временной папке только после падения приложения.
  Future<void> _deleteLeftoverVideos(Directory directory) async {
    try {
      for (final entity in directory.listSync()) {
        if (entity is File && entity.path.endsWith('.mp4')) {
          entity.deleteSync();
        }
      }
    } catch (_) {}
  }

  String _describeView() {
    final context = videoKey.currentContext;
    final box = context?.findRenderObject() as RenderBox?;
    if (context == null || box == null) return 'boundary not mounted';
    final view = View.of(context);
    return 'boundary ${box.size.width.round()}x${box.size.height.round()} lp, '
        'dpr ${view.devicePixelRatio.toStringAsFixed(2)}, '
        'screen ${view.physicalSize.width.round()}x'
        '${view.physicalSize.height.round()} px '
        '@ ${view.display.refreshRate.round()} Hz';
  }

  /// mpv decoder state: whether hardware decoding is active, stream vs.
  /// actually decoded fps, and how many frames the player itself dropped.
  Future<String> _playerStats() async {
    final player = this.player;
    final native = player?.platform;
    if (player == null || native is! NativePlayer) return 'n/a';
    Future<String> prop(String name) =>
        native.getProperty(name).catchError((_) => '?');
    return 'codec=${await prop('video-format')}, '
        'hwdec=${await prop('hwdec-current')}, '
        'fps container=${await prop('container-fps')} '
        'decoded=${await prop('estimated-vf-fps')}, '
        'dropped vo=${await prop('frame-drop-count')} '
        'decoder=${await prop('decoder-frame-drop-count')}, '
        'video ${player.state.width}x${player.state.height}';
  }
}

void _log(String message) => debugPrint('[REC] $message');

/// Runs [body], adding its duration to [timings] when diagnostics are on.
Future<T> _timed<T>(_Timings? timings, Future<T> Function() body) async {
  if (timings == null) return body();
  final watch = Stopwatch()..start();
  final result = await body();
  timings.add(watch.elapsedMicroseconds);
  return result;
}

class _Timings {
  final List<int> _us = [];

  void add(int microseconds) => _us.add(microseconds);

  double get averageMs =>
      _us.isEmpty ? 0 : _us.reduce((a, b) => a + b) / _us.length / 1000;

  @override
  String toString() {
    if (_us.isEmpty) return 'n/a';
    final sorted = [..._us]..sort();
    String ms(num us) => (us / 1000).toStringAsFixed(1);
    String at(double q) => ms(sorted[((sorted.length - 1) * q).round()]);
    return 'avg ${averageMs.toStringAsFixed(1)}, p50 ${at(0.5)}, '
        'p95 ${at(0.95)}, max ${ms(sorted.last)} ms (n=${sorted.length})';
  }
}

class _RecordingDiagnostics {
  final interval = _Timings();
  final toImage = _Timings();
  final readback = _Timings();
  final crop = _Timings();
  final append = _Timings();

  final Stopwatch _clock = Stopwatch()..start();
  Duration recorded = Duration.zero;
  String? frameSize;
  int frames = 0;
  int duplicates = 0;
  int resized = 0;
  int? _lastStartUs;
  int? _lastHash;

  void log(String message) => _log(message);

  void frameStarted() {
    final now = _clock.elapsedMicroseconds;
    if (_lastStartUs != null) interval.add(now - _lastStartUs!);
    _lastStartUs = now;
  }

  /// Identical pixels mean the video texture had not changed since the
  /// previous capture, i.e. the player, not the capture, sets the pace.
  void frameAppended(Uint8List pixels) {
    frames++;
    var hash = pixels.length;
    for (var i = 0; i < pixels.length; i += 97) {
      hash = 0x1fffffff & (hash * 31 + pixels[i]);
    }
    if (hash == _lastHash) duplicates++;
    _lastHash = hash;
  }

  double get _seconds => recorded.inMicroseconds / 1e6;
  String _fps(int count) =>
      _seconds == 0 ? '0' : (count / _seconds).toStringAsFixed(1);

  void logCapture() {
    _log('stop: ${_seconds.toStringAsFixed(2)} s, $frames frames = '
        '${_fps(frames)} fps captured, ${frames - duplicates} unique = '
        '${_fps(frames - duplicates)} fps, frame ${frameSize ?? '?'} px'
        '${resized == 0 ? '' : ', $resized skipped after a size change'}');
    _log('  interval $interval');
    _log('  toImage  $toImage');
    _log('  readback $readback');
    _log('  crop     $crop');
    _log('  append   $append');
  }

  String get shortSummary => '${_fps(frames)} fps '
      '(${_fps(frames - duplicates)} unique), frame ${frameSize ?? '?'}\n'
      'toImage ${toImage.averageMs.round()} / readback '
      '${readback.averageMs.round()} / append ${append.averageMs.round()} ms';
}
