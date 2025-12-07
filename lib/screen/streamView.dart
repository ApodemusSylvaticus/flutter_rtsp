import 'dart:async';
import 'dart:io';
import 'package:archer_link/containers/StreamViewContainer.dart';
import 'package:archer_link/features/notificationCard/index.dart';
import 'package:archer_link/main.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:flutter/rendering.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gal/gal.dart';
import 'package:archer_link/features/StreamViewButtons/index.dart';
import 'package:archer_link/features/loading.dart';
import 'package:archer_link/features/reconnectView.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:disk_space_2/disk_space_2.dart';
import 'package:media_kit/src/player/native/player/player.dart';
import 'package:media_kit_video/media_kit_video.dart';

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
  StreamSubscription<String>? errorSubscription;

  bool isRecording = false;
  Stopwatch stopwatch = Stopwatch();
  List<String> imagePaths = [];

  // GlobalKey для захвата скриншотов
  final GlobalKey _videoKey = GlobalKey();

  Future<void> _configureLowLatency() async {
  final nativePlayer = player.platform as NativePlayer;
  
  // Отключаем кэширование — убирает буферизацию
  await nativePlayer.setProperty('cache', 'no');
  
  // RTSP через TCP + отключаем буфер FFmpeg
  await nativePlayer.setProperty('demuxer-lavf-o', 'rtsp_transport=tcp,fflags=nobuffer');
  
  // Минимальное время анализа потока (в микросекундах, 0 = минимум)
  await nativePlayer.setProperty('demuxer-lavf-analyzeduration', '0');
  
  // Минимальный размер данных для определения формата (в байтах)
  await nativePlayer.setProperty('demuxer-lavf-probesize', '32');
  
  // Воспроизводить фреймы сразу, без привязки к таймингу
  await nativePlayer.setProperty('untimed', 'yes');
  
  // Hardware decoding на Android
  await nativePlayer.setProperty('hwdec', 'mediacodec');
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

  // Слушаем состояние плеера
  playingSubscription = player.stream.playing.listen((playing) {
    if (playing && isLoading) {
      setState(() {
        isLoading = false;
        setLandscapeOrientation();
      });
    }
  });

  // Слушаем ошибки
  errorSubscription = player.stream.error.listen((error) {
    if (error.isNotEmpty) {
      print('Player error: $error');
      setState(() {
        showReconnectButton = true;
        isLoading = false;
      });
    }
  });

  // Сначала настраиваем low-latency, потом подключаемся
  _configureLowLatency().then((_) {
    initializeDeviceConnection();
  });
}

  Future<void> initializePlayer() async {
    try {
    await player.stop();
    await player.setVolume(0);

    // Получаем доступ к нативному плееру
    final nativePlayer = player.platform as NativePlayer;
    
    // Устанавливаем mpv опции
    await nativePlayer.setProperty('cache', 'no');
    await nativePlayer.setProperty('cache-pause', 'no');
    await nativePlayer.setProperty('demuxer-lavf-o', 
        'rtsp_transport=tcp,analyzeduration=100000,probesize=32000,fflags=nobuffer');
    await nativePlayer.setProperty('untimed', 'yes');
    await nativePlayer.setProperty('profile', 'low-latency');
    await nativePlayer.setProperty('framedrop', 'vo');
    await nativePlayer.setProperty('audio', 'no');

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

    try {
      if (widget.streamConfig.shouldRunStreamView) {
        final parsed = ParsedData.fromString(widget.streamConfig.tcpCommandUrl);
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
    playingSubscription?.cancel();
    errorSubscription?.cancel();
    player.dispose();
    connectivitySubscription?.cancel();
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
      // setPortraitOrientation();
      // return ReconnectView(
      //   isReconnecting: isReconnecting,
      //   onReconnect: initializeDeviceConnection,
      //   openSettings: widget.openSettings,
      // );
      setLandscapeOrientation();
      return buildStreamView();
    } else {
      setLandscapeOrientation();
      return buildStreamView();
    }
  }

  showNotification(NotificationType notificationType, String msg) {
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

  /// Захват скриншота через RepaintBoundary
  Future<Uint8List?> _captureSnapshot() async {
    try {
      final boundary =
          _videoKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
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
        int difference =
            now.difference(lastSnapshotTime).inMilliseconds - debounceDurationMillis;

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
            showNotification(
                NotificationType.error, 'Storage limit reached. Stopping recording.');
            stopRecording();
          }

          index++;
        } else {
          await Future.delayed(Duration(milliseconds: difference.abs()));
        }
      } catch (e) {
        showNotification(
            NotificationType.error, 'Something went wrong. Video recording stopped.');
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
        showNotification(
            NotificationType.defaultType, 'Snapshot successfully saved to gallery.');
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
    await createVideoFromImages(stopwatch.elapsed.inSeconds);

    for (var path in imagePaths) {
      File(path).delete();
    }
    imagePaths.clear();
    stopwatch.reset();
    setState(() {
      isRecording = false;
    });
  }

  Future<void> createVideoFromImages(int desiredVideoLengthInSeconds) async {
    final directory = await getTemporaryDirectory();

    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String outputPath = '${directory.path}/video_$timestamp.mp4';

    // PNG вместо JPG
    String inputPattern = '${directory.path}/image_%06d.png';

    if (imagePaths.isEmpty || desiredVideoLengthInSeconds == 0) {
      return;
    }

    double frameDisplayTime = desiredVideoLengthInSeconds / imagePaths.length;
    int fps = (1 / frameDisplayTime).round();
    print("Video fps $fps");

    String ffmpegCommand =
        '-framerate $fps -i $inputPattern -c:v mpeg4 -pix_fmt yuv420p -r $fps $outputPath';

    await FFmpegKit.execute(ffmpegCommand).then((session) async {
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        try {
          await Gal.putVideo(outputPath);
          showNotification(
              NotificationType.defaultType, 'Video successfully saved to gallery.');
        } catch (e) {
          showNotification(
              NotificationType.error, 'Failed to save video to gallery.');
        }
      } else {
        print("!_!_!_!_!_!_!_!_!__!!__!_!_!_!_!_!_!_!_");
        print(await session.getFailStackTrace());
        print("!_!_!_!_!_!_!_!_!__!!__!_!_!_!_!_!_!_!_");
        print(await session.getLogsAsString());
      }
    });
  }
}

/// Пустые контролы для Video виджета
Widget NoVideoControls(VideoState state) {
  return const SizedBox.shrink();
}