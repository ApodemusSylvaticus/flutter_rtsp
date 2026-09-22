import 'dart:io';
import 'dart:math' as math;
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

/// Notification callback
typedef OnRecorderNotification = void Function(bool isError, String message);

/// Progress callback: current frame index, total frames
typedef OnRecorderProgress = void Function(int current, int total);

/// Processing state callback
typedef OnProcessingChanged = void Function(bool isProcessing);

/// Утилита для записи видео и создания снапшотов
class VideoRecorder {
  final GlobalKey videoKey;
  final OnRecorderNotification onNotification;
  final OnRecorderProgress? onProgress;
  final OnProcessingChanged? onProcessingChanged;

  /// Only read by diagnostics, to report the decoder state.
  final Player? player;

  bool isRecording = false;
  Stopwatch stopwatch = Stopwatch();
  List<String> _imagePaths = [];
  /// Capture time of each of [_imagePaths], ms since the recording started.
  final List<int> _frameTimesMs = [];
  DateTime _lastSnapshotTime = DateTime.now();
  final int _debounceDurationMillis = 20;
  _RecordingDiagnostics? _diag;

  VideoRecorder({
    required this.videoKey,
    required this.onNotification,
    this.onProgress,
    this.onProcessingChanged,
    this.player,
  });

  /// Захват кадра из видео
  Future<Uint8List?> _captureSnapshot([_RecordingDiagnostics? diag]) async {
    try {
      final boundary =
          videoKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image =
          await _timed(diag?.toImage, () => boundary.toImage(pixelRatio: 1.0));
      final byteData = await _timed(
          diag?.png, () => image.toByteData(format: ui.ImageByteFormat.png));

      // GPU->CPU readback alone (no PNG compression), sampled every 10th
      // frame, to split the `png` time into copy and compression.
      if (diag != null && diag.frames % 10 == 0) {
        await _timed(diag.readback,
            () => image.toByteData(format: ui.ImageByteFormat.rawRgba));
      }
      diag?.captureSize ??= '${image.width}x${image.height}';
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

  /// Начать запись видео
  Future<void> startRecording() async {
    final directory = await getTemporaryDirectory();

    if (directory.existsSync()) {
      directory.listSync().forEach((entity) {
        if (entity is File) {
          entity.deleteSync();
        }
      });
    }

    isRecording = true;
    stopwatch.start();
    int index = 0;

    final diag = kRecorderDiagnostics ? _RecordingDiagnostics() : null;
    _diag = diag;
    if (diag != null) {
      _log('start: ${_describeView()}');
      _playerStats().then((stats) => _log('player at start: $stats'));
    }

    final freeSpaceInMB = await DiskSpace.getFreeDiskSpace;
    final freeSpaceInMBNonNull = freeSpaceInMB ?? 1024.0;
    final freeSpaceInBytes = (freeSpaceInMBNonNull * 1024 * 1024).toInt();
    final limit = (freeSpaceInBytes * 0.8).toInt();

    int usedSpace = 0;

    while (isRecording) {
      try {
        DateTime now = DateTime.now();
        int difference =
            now.difference(_lastSnapshotTime).inMilliseconds - _debounceDurationMillis;

        if (difference >= _debounceDurationMillis) {
          _lastSnapshotTime = now;
          final capturedAtMs = stopwatch.elapsedMilliseconds;
          diag?.frameStarted();

          final imageData = await _captureSnapshot(diag);
          if (imageData == null) continue;

          String fileName = 'image_${index.toString().padLeft(6, '0')}.png';
          String filePath = '${directory.path}/$fileName';
          File file = File(filePath);

          await _timed(diag?.write, () => file.writeAsBytes(imageData));

          // stopRecording() may have run during the awaits above: this frame
          // is past the end, and adding it to the already-cleared list would
          // leak it into the next recording.
          if (!isRecording) break;

          diag?.frameStored(imageData);
          _imagePaths.add(filePath);
          _frameTimesMs.add(capturedAtMs);

          // Diagnostics only: also time the alternative frame source.
          if (diag != null && diag.frames % 10 == 5) {
            final shot = await _timed(diag.mpvShot, _mpvScreenshot);
            if (shot == null) diag.mpvShotFailed++;
          }

          int fileSize = await file.length();
          usedSpace += fileSize;

          if (usedSpace >= limit) {
            onNotification(true, 'Storage limit reached. Stopping recording.');
            await stopRecording();
          }

          index++;
        } else {
          await Future.delayed(Duration(milliseconds: difference.abs()));
        }
      } catch (e) {
        onNotification(true, 'Something went wrong. Video recording stopped.');
        await stopRecording();
      }
    }
  }

  /// Остановить запись и создать видео
  Future<void> stopRecording() async {
    isRecording = false;
    stopwatch.stop();

    final diag = _diag;
    _diag = null;
    if (diag != null) {
      diag.recorded = stopwatch.elapsed;
      diag.logCapture();
      _playerStats().then((stats) => _log('player at stop: $stats'));
    }

    final pathsCopy = List<String>.from(_imagePaths);
    final frameTimesCopy = List<int>.from(_frameTimesMs);
    _imagePaths.clear();
    _frameTimesMs.clear();

    onProcessingChanged?.call(true);
    await _createVideoFromImages(
        pathsCopy, frameTimesCopy, stopwatch.elapsedMilliseconds, diag);
    onProcessingChanged?.call(false);

    for (var path in pathsCopy) {
      try {
        await File(path).delete();
      } catch (_) {}
    }

    stopwatch.reset();
  }

  Future<void> _createVideoFromImages(
    List<String> paths,
    List<int> frameTimesMs,
    int durationMs, [
    _RecordingDiagnostics? diag,
  ]) async {
    if (paths.isEmpty || durationMs <= 0) {
      diag?.log('encoder: skipped (${paths.length} frames, $durationMs ms)');
      return;
    }

    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final outputPath = '${directory.path}/video_$timestamp.mp4';

    // The encoder only takes a constant integer fps, while frames are
    // captured unevenly. Lay them out on an fps grid by their capture times,
    // so the video lasts as long as the recording did and motion keeps its
    // real speed.
    final int fps = _gridFps(frameTimesMs, durationMs);
    final int slotCount = math.max(1, (durationMs * fps / 1000).round());
    final slotFrames = _frameForSlots(frameTimesMs, fps, slotCount);
    print("Video fps: $fps");
    if (diag != null) {
      final shown = slotFrames.toSet().length;
      diag.log('encoder: ${paths.length} frames over '
          '${(durationMs / 1000).toStringAsFixed(2)} s -> fps=$fps, '
          '$slotCount slots = ${(slotCount / fps).toStringAsFixed(2)} s video '
          '(${paths.length - shown} frames dropped, '
          '${slotCount - shown} slots repeat the previous frame)');
    }

    try {
      final processing = Stopwatch()..start();
      final firstImageBytes = await File(paths.first).readAsBytes();
      final firstCodec = await ui.instantiateImageCodec(firstImageBytes);
      final firstFrame = await firstCodec.getNextFrame();
      final width = firstFrame.image.width;
      final height = firstFrame.image.height;
      final adjustedWidth = (width ~/ 2) * 2;
      final adjustedHeight = (height ~/ 2) * 2;
      firstFrame.image.dispose();

      await FlutterQuickVideoEncoder.setup(
        width: adjustedWidth,
        height: adjustedHeight,
        fps: fps,
        videoBitrate: 4000000,
        audioChannels: 0,
        audioBitrate: 0,
        sampleRate: 44100,
        filepath: outputPath,
        profileLevel: ProfileLevel.baselineAutoLevel,
      );

      late Uint8List rgba;
      var rgbaFrame = -1;
      for (var slot = 0; slot < slotCount; slot++) {
        final frame = slotFrames[slot];
        if (frame != rgbaFrame) {
          rgba = await _timed(diag?.decode,
              () => _loadImageAsRgba(paths[frame], adjustedWidth, adjustedHeight));
          rgbaFrame = frame;
        }
        await _timed(
            diag?.append, () => FlutterQuickVideoEncoder.appendVideoFrame(rgba));
        onProgress?.call(slot + 1, slotCount);
      }

      await FlutterQuickVideoEncoder.finish();
      diag?.logProcessing(processing.elapsed);

      await Gal.putVideo(outputPath);
      onNotification(
        false,
        diag == null
            ? 'Video successfully saved to gallery.'
            : 'Video saved. ${diag.shortSummary}',
      );

      await File(outputPath).delete();
    } catch (e) {
      print("Video creation error: $e");
      diag?.log('encoder error: $e');
      onNotification(true, 'Failed to create video.');

      final file = File(outputPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  Future<Uint8List> _loadImageAsRgba(
      String path, int targetWidth, int targetHeight) async {
    final bytes = await File(path).readAsBytes();
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: targetWidth,
      targetHeight: targetHeight,
    );
    final frame = await codec.getNextFrame();
    final byteData =
        await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba);
    frame.image.dispose();
    return byteData!.buffer.asUint8List();
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

  /// Alternative frame source, only timed by diagnostics: the decoded video
  /// frame straight from mpv (BGRA, native resolution, no Flutter overlays).
  Future<Uint8List?> _mpvScreenshot() async {
    try {
      return await player
          ?.screenshot(format: null)
          .timeout(const Duration(seconds: 1), onTimeout: () => null);
    } catch (_) {
      return null;
    }
  }
}

/// Grid fps for [_frameForSlots], rounded up so (nearly) every captured
/// frame gets its own slot. Uses the median capture interval as well as the
/// average rate: a stall lowers the average, and a grid that coarse would
/// drop frames all around it.
int _gridFps(List<int> frameTimesMs, int durationMs) {
  var fps = frameTimesMs.length * 1000 / durationMs;
  if (frameTimesMs.length > 2) {
    final intervals = [
      for (var i = 1; i < frameTimesMs.length; i++)
        frameTimesMs[i] - frameTimesMs[i - 1],
    ]..sort();
    final median = intervals[intervals.length ~/ 2];
    if (median > 0) fps = math.max(fps, 1000 / median);
  }
  return fps.ceil().clamp(1, 30);
}

/// Maps a constant-[fps] grid of [slotCount] slots onto frames captured at
/// [frameTimesMs]: each frame goes to the slot nearest to its capture time
/// and is held until the next frame's slot. A later frame wins a shared
/// slot; slots before the first frame show the first frame.
List<int> _frameForSlots(List<int> frameTimesMs, int fps, int slotCount) {
  int slotOf(int frame) =>
      (frameTimesMs[frame] * fps / 1000).round().clamp(0, slotCount - 1);

  final frames = List<int>.filled(slotCount, 0);
  var frame = 0;
  for (var slot = 0; slot < slotCount; slot++) {
    while (frame + 1 < frameTimesMs.length && slotOf(frame + 1) <= slot) {
      frame++;
    }
    frames[slot] = frame;
  }
  return frames;
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
  final Stopwatch _clock = Stopwatch()..start();
  final interval = _Timings();
  final toImage = _Timings();
  final readback = _Timings();
  final png = _Timings();
  final write = _Timings();
  final decode = _Timings();
  final append = _Timings();
  final mpvShot = _Timings();

  Duration recorded = Duration.zero;
  String? captureSize;
  int frames = 0;
  int duplicates = 0;
  int mpvShotFailed = 0;
  int _pngBytes = 0;
  int? _lastStartUs;
  int? _lastHash;

  void log(String message) => _log(message);

  void frameStarted() {
    final now = _clock.elapsedMicroseconds;
    if (_lastStartUs != null) interval.add(now - _lastStartUs!);
    _lastStartUs = now;
  }

  /// PNG encoding is deterministic, so identical bytes mean the video
  /// texture had not changed since the previous capture.
  void frameStored(Uint8List pngBytes) {
    frames++;
    _pngBytes += pngBytes.length;
    var hash = pngBytes.length;
    for (var i = 0; i < pngBytes.length; i += 97) {
      hash = 0x1fffffff & (hash * 31 + pngBytes[i]);
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
        '${_fps(frames - duplicates)} fps, capture ${captureSize ?? '?'} px, '
        'png avg ${frames == 0 ? 0 : _pngBytes ~/ frames ~/ 1024} KB');
    _log('  interval $interval');
    _log('  toImage  $toImage');
    _log('  png      $png');
    _log('  readback $readback (rawRgba only)');
    _log('  write    $write');
    _log('  mpv shot $mpvShot, $mpvShotFailed failed '
        '(screenshot-raw: native res, no overlays)');
  }

  void logProcessing(Duration total) {
    _log('processing: ${(total.inMilliseconds / 1000).toStringAsFixed(1)} s '
        'for $frames frames');
    _log('  decode   $decode');
    _log('  append   $append');
  }

  String get shortSummary => '${_fps(frames)} fps '
      '(${_fps(frames - duplicates)} unique), capture ${captureSize ?? '?'}\n'
      'toImage ${toImage.averageMs.round()} / png ${png.averageMs.round()} / '
      'write ${write.averageMs.round()} ms per frame';
}
