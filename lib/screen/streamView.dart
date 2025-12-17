import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gal/gal.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:disk_space_2/disk_space_2.dart';
import 'package:flutter_quick_video_encoder/flutter_quick_video_encoder.dart';
import 'package:archer_link/containers/StreamViewContainer.dart';
import 'package:archer_link/features/notificationCard/index.dart';
import 'package:archer_link/main.dart';
import 'package:archer_link/features/StreamViewButtons/index.dart';
import 'package:archer_link/features/loading.dart';
import 'package:archer_link/features/reconnectView.dart';

class ParsedData {
  final String? ipAddress;
  final String? port;
  final String? rest;

  ParsedData({this.ipAddress, this.port, this.rest});

  factory ParsedData.fromString(String input) {
    var regex =
        RegExp(r'^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})(?::(\d+))?(.*)$');
    var match = regex.firstMatch(input);

    if (match != null) {
      var ip = match.group(1);
      var port = match.group(2);
      var link = match.group(3);
      return ParsedData(ipAddress: ip, port: port, rest: link);
    } else {
      return ParsedData();
    }
  }
}

class StreamViewPage extends StatefulWidget {
  final StreamConfig streamConfig;
  final void Function() openSettings;

  const StreamViewPage(this.streamConfig, this.openSettings, {super.key});

  @override
  State<StreamViewPage> createState() => _StreamViewPageState();
}

class _StreamViewPageState extends State<StreamViewPage> {
  late final Player player;
  late final VideoController videoController;

  bool showReconnectButton = false;
  bool isReconnecting = false;
  bool isLoading = true;
  DateTime lastSnapshotTime = DateTime.now();
  int debounceDurationMillis = 20;

  StreamSubscription<ConnectivityResult>? connectivitySubscription;
  StreamSubscription<bool>? playingSubscription;
  StreamSubscription<bool>? bufferingSubscription;
  StreamSubscription<Duration>? positionSubscription;

  Timer? _bufferTimeout;
  Timer? _positionWatchdog;
  Duration _lastPosition = Duration.zero;
  int _stalledCount = 0;

  bool isRecording = false;
  Stopwatch stopwatch = Stopwatch();
  List<String> imagePaths = [];

  final GlobalKey _videoKey = GlobalKey();

  Future<void> _configureLowLatency() async {
    final nativePlayer = player.platform as NativePlayer;

    await nativePlayer.setProperty('cache', 'no');
    await nativePlayer.setProperty(
        'demuxer-lavf-o', 'rtsp_transport=tcp,fflags=nobuffer');
    await nativePlayer.setProperty('demuxer-lavf-analyzeduration', '0');
    await nativePlayer.setProperty('demuxer-lavf-probesize', '32');
    await nativePlayer.setProperty('untimed', 'yes');
    await nativePlayer.setProperty('hwdec', 'mediacodec');
  }

  void _setupStreamMonitoring() {
    bufferingSubscription = player.stream.buffering.listen((isBuffering) {
      _bufferTimeout?.cancel();

      if (isBuffering) {
        _bufferTimeout = Timer(const Duration(seconds: 10), _onStreamLost);
      }
    });

    playingSubscription = player.stream.playing.listen((playing) {
      _positionWatchdog?.cancel();

      if (playing) {
        if (isLoading) {
          setState(() {
            isLoading = false;
            showReconnectButton = false;
            setLandscapeOrientation();
          });
        }
        _startPositionWatchdog();
      }
    });

    positionSubscription = player.stream.position.listen((pos) {
      if (pos != _lastPosition) {
        _lastPosition = pos;
        _stalledCount = 0;
      }
    });
  }

  void _startPositionWatchdog() {
    _stalledCount = 0;
    _positionWatchdog = Timer.periodic(const Duration(seconds: 2), (_) {
      _stalledCount++;

      if (_stalledCount >= 5) {
        _onStreamLost();
      }
    });
  }

  void _onStreamLost() {
    _bufferTimeout?.cancel();
    _positionWatchdog?.cancel();

    print('🔴 Stream lost or stalled for 10+ seconds');
    setState(() {
      showReconnectButton = true;
      isLoading = false;
    });
  }

  void _resetMonitoring() {
    _bufferTimeout?.cancel();
    _positionWatchdog?.cancel();
    _stalledCount = 0;
    _lastPosition = Duration.zero;
  }

  @override
  void initState() {
    super.initState();

    player = Player(
      configuration: const PlayerConfiguration(
        bufferSize: 32 * 1024,
        logLevel: MPVLogLevel.warn,
      ),
    );

    videoController = VideoController(
      player,
      configuration: const VideoControllerConfiguration(
        enableHardwareAcceleration: true,
      ),
    );

    _setupStreamMonitoring();

    _configureLowLatency().then((_) {
      initializeDeviceConnection();
    });
  }

  Future<void> initializePlayer() async {
    try {
      await player.stop();
      await player.setVolume(0);

      final nativePlayer = player.platform as NativePlayer;

      await nativePlayer.setProperty('cache', 'no');
      await nativePlayer.setProperty('cache-pause', 'no');
      await nativePlayer.setProperty('demuxer-lavf-o',
          'rtsp_transport=tcp,analyzeduration=100000,probesize=32000,fflags=nobuffer');
      await nativePlayer.setProperty('untimed', 'yes');
      await nativePlayer.setProperty('profile', 'low-latency');
      await nativePlayer.setProperty('framedrop', 'vo');
      await nativePlayer.setProperty('audio', 'no');

      _resetMonitoring();

      await player.open(
        Media('rtsp://${widget.streamConfig.streamUrl}'),
        play: true,
      );

      WakelockPlus.enable();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

      setState(() {
        showReconnectButton = false;
      });
    } catch (e) {
      print('Failed to connect: $e');
      setState(() {
        showReconnectButton = true;
        isLoading = false;
      });
    } finally {
      setState(() {
        isReconnecting = false;
      });
    }
  }

  Future<void> initializeDeviceConnection() async {
    setState(() {
      isReconnecting = true;
      isLoading = true;
    });

    _resetMonitoring();

    try {
      if (widget.streamConfig.shouldRunStreamView) {
        final parsed =
            ParsedData.fromString(widget.streamConfig.tcpCommandUrl);
        int port = int.parse(parsed.port!);

        var socket = await Socket.connect(parsed.ipAddress, port);
        socket.writeln('CMD_RTSP_TRANS_START');
        await socket.flush();

        Completer<String> completer = Completer<String>();

        socket.listen((data) {
          String response = utf8.decode(data);
          completer.complete(response);
        }, onError: (error) {
          completer.completeError(error);
        });

        try {
          String result = await completer.future;
          print('Received response: $result');
          Future.delayed(Duration(milliseconds: 500), initializePlayer);
        } catch (e) {
          print('Error receiving response: $e');
        }
      } else {
        initializePlayer();
      }
    } catch (e) {
      print('Failed to connect: $e');
      setState(() {
        showReconnectButton = true;
        isLoading = false;
      });
    } finally {
      setState(() {
        isReconnecting = false;
      });
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    _bufferTimeout?.cancel();
    _positionWatchdog?.cancel();
    playingSubscription?.cancel();
    bufferingSubscription?.cancel();
    positionSubscription?.cancel();
    connectivitySubscription?.cancel();

    player.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Streamviewcontainer(
      child: Center(
        child: buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    if (isLoading == true) {
      setPortraitOrientation();
      return LoadingIndicator(isLoading: isLoading);
    } else if (showReconnectButton) {
      setPortraitOrientation();
      return ReconnectView(
        isReconnecting: isReconnecting,
        onReconnect: initializeDeviceConnection,
        openSettings: widget.openSettings,
      );
    } else {
      setLandscapeOrientation();
      return buildStreamView();
    }
  }

  void showNotification(NotificationType notificationType, String msg) {
    InAppNotification.show(
      child: NotificationCard(
        type: notificationType,
        message: msg,
      ),
      context: context,
      onTap: () => print('Notification tapped!'),
      duration: Duration(seconds: 4),
    );
  }

  Widget buildStreamView() {
    double screenWidth = MediaQuery.of(context).size.width;
    double topPadding =
        MediaQuery.of(context).padding.left > MediaQuery.of(context).padding.top
            ? MediaQuery.of(context).padding.left
            : MediaQuery.of(context).padding.top;

    double playerWidth = screenWidth - 240 + 60 - 8 - 8 - topPadding;

    Widget playerWidget = Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: RepaintBoundary(
        key: _videoKey,
        child: SizedBox(
          width: playerWidth,
          height: MediaQuery.of(context).size.height,
          child: Video(
            controller: videoController,
            fill: Colors.transparent,
            controls: NoVideoControls,
          ),
        ),
      ),
    );

    return StreamViewButtons(
      child: playerWidget,
      onRecordingChanged: (value) {
        setState(() {
          isRecording = value;
          if (isRecording) {
            startRecording();
          } else {
            stopRecording();
          }
        });
      },
      isRecording: isRecording,
      commandUrl: widget.streamConfig.commandUrl,
      takePhoto: takeSnapShot,
    );
  }

  void setPortraitOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void setLandscapeOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<Uint8List?> _captureSnapshot() async {
    try {
      final boundary = _videoKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
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
        int difference = now.difference(lastSnapshotTime).inMilliseconds -
            debounceDurationMillis;

        if (difference >= debounceDurationMillis) {
          lastSnapshotTime = now;

          Uint8List? imageData = await _captureSnapshot();
          if (imageData == null) continue;

          String fileName = 'image_${index.toString().padLeft(6, '0')}.png';
          String filePath = '${directory.path}/$fileName';
          File file = File(filePath);

          await file.writeAsBytes(imageData);
          imagePaths.add(filePath);

          int fileSize = await file.length();
          usedSpace += fileSize;

          if (usedSpace >= limit) {
            showNotification(NotificationType.error,
                'Storage limit reached. Stopping recording.');
            stopRecording();
          }

          index++;
        } else {
          await Future.delayed(Duration(milliseconds: difference.abs()));
        }
      } catch (e) {
        showNotification(NotificationType.error,
            'Something went wrong. Video recording stopped.');
        stopRecording();
      }
    }
  }

  Future<void> takeSnapShot() async {
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
        showNotification(NotificationType.defaultType,
            'Snapshot successfully saved to gallery.');
      } catch (e) {
        showNotification(
            NotificationType.error, 'Failed to save snapshot to gallery.');
      }
    } catch (e) {
      showNotification(
          NotificationType.error, 'Failed to save snapshot to gallery.');
    }
  }

  Future<void> stopRecording() async {
    isRecording = false;
    stopwatch.stop();

    // Создаём копию списка ДО обработки
    final pathsCopy = List<String>.from(imagePaths);
    imagePaths.clear(); // Очищаем оригинал сразу

    await createVideoFromImages(pathsCopy, stopwatch.elapsed.inSeconds);

    // Удаляем файлы из копии
    for (var path in pathsCopy) {
      try {
        await File(path).delete();
      } catch (_) {}
    }

    stopwatch.reset();
    setState(() {
      isRecording = false;
    });
  }

  Future<void> createVideoFromImages(
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
      showNotification(
        NotificationType.defaultType,
        'Video successfully saved to gallery.',
      );

      await File(outputPath).delete();
    } catch (e) {
      print("Video creation error: $e");
      showNotification(
        NotificationType.error,
        'Failed to create video.',
      );

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

Widget NoVideoControls(VideoState state) {
  return const SizedBox.shrink();
}
