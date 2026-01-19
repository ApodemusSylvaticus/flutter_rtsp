import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:disk_space_2/disk_space_2.dart';
import 'package:flutter_quick_video_encoder/flutter_quick_video_encoder.dart';
import 'package:gal/gal.dart';

/// Notification callback
typedef OnRecorderNotification = void Function(bool isError, String message);

/// Утилита для записи видео и создания снапшотов
class VideoRecorder {
  final GlobalKey videoKey;
  final OnRecorderNotification onNotification;

  bool isRecording = false;
  Stopwatch stopwatch = Stopwatch();
  List<String> _imagePaths = [];
  DateTime _lastSnapshotTime = DateTime.now();
  final int _debounceDurationMillis = 20;

  VideoRecorder({
    required this.videoKey,
    required this.onNotification,
  });

  /// Захват кадра из видео
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

          Uint8List? imageData = await _captureSnapshot();
          if (imageData == null) continue;

          String fileName = 'image_${index.toString().padLeft(6, '0')}.png';
          String filePath = '${directory.path}/$fileName';
          File file = File(filePath);

          await file.writeAsBytes(imageData);
          _imagePaths.add(filePath);

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

    final pathsCopy = List<String>.from(_imagePaths);
    _imagePaths.clear();

    await _createVideoFromImages(pathsCopy, stopwatch.elapsed.inSeconds);

    for (var path in pathsCopy) {
      try {
        await File(path).delete();
      } catch (_) {}
    }

    stopwatch.reset();
  }

  Future<void> _createVideoFromImages(
    List<String> paths,
    int desiredVideoLengthInSeconds,
  ) async {
    if (paths.isEmpty || desiredVideoLengthInSeconds == 0) {
      return;
    }

    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final outputPath = '${directory.path}/video_$timestamp.mp4';

    final double frameDisplayTime = desiredVideoLengthInSeconds / paths.length;
    final int fps = (1 / frameDisplayTime).round().clamp(1, 120);
    print("Video fps: $fps");

    try {
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

      for (final imagePath in paths) {
        final rgba =
            await _loadImageAsRgba(imagePath, adjustedWidth, adjustedHeight);
        await FlutterQuickVideoEncoder.appendVideoFrame(rgba);
      }

      await FlutterQuickVideoEncoder.finish();

      await Gal.putVideo(outputPath);
      onNotification(false, 'Video successfully saved to gallery.');

      await File(outputPath).delete();
    } catch (e) {
      print("Video creation error: $e");
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
}
