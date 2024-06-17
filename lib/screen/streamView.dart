import 'dart:async';
import 'dart:io';
import 'package:archer_link/features/notificationCard/index.dart';
import 'package:archer_link/main.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:archer_link/features/StreamViewButtons/index.dart';
import 'package:archer_link/features/loading.dart';
import 'package:archer_link/features/reconnectView.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:wakelock/wakelock.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archer_link/containers/DefaultBg.dart';
import 'dart:convert';

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
  final FijkPlayer player = FijkPlayer();
  bool showReconnectButton = false;
  bool isReconnecting = false;
  bool isLoading = true;
  int value = 0;
  int value2 = 0;
  DateTime lastSnapshotTime = DateTime.now();
  int debounceDurationMillis = 20;

  StreamSubscription<ConnectivityResult>? connectivitySubscription;
  bool isRecording = false;
  Stopwatch stopwatch = Stopwatch();
  List<String> imagePaths = [];

  @override
  void initState() {
    print('init state');
    super.initState();
    player.addListener(() {
      print('player state ${value}, ${player.state}, ${player.value.videoRenderStart}');
      value = value + 1;
      if (player.state == FijkState.started && player.value.videoRenderStart) {
        setState(() {
          isLoading = false;
          setLandscapeOrientation();
        });
      }

      if (player.state == FijkState.error) {
        setState(() {
          showReconnectButton = true;
          isLoading = false;
        });
      }
    });

    if (player.state == FijkState.completed) {
      player.reset();
    }
    initializeDeviceConnection();
  }

  Future<void> initializePlayer() async {
    try {
      player.reset();
      await player.setOption(FijkOption.playerCategory, "fflags", "nobuffer");
      // await player.setOption(FijkOption.formatCategory, "probesize", "32");
      await player.setOption(
          FijkOption.formatCategory, "analyzeduration", "32");
      await player.setOption(FijkOption.playerCategory, "max_delay", "100000");

      await player.setOption(FijkOption.hostCategory, "enable-snapshot", 1);
      await player.setOption(FijkOption.playerCategory, "packet-buffering", 0);
      await player.setOption(FijkOption.playerCategory, "framedrop", 1);
      await player.setVolume(0);

      player.setOption(FijkOption.playerCategory, "flush_packets", 1);
      player.setOption(FijkOption.formatCategory, "rtsp_transport", "tcp");
      await player.setDataSource("rtsp://${widget.streamConfig.streamUrl}",
          autoPlay: true);
      Wakelock.enable();
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
    print('initializeDeviceConnection');
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

        // Listen for data from the socket
        socket.listen((data) {
          // Process the received data
          String response = utf8.decode(data);
          completer.complete(response);
        }, onError: (error) {
          completer.completeError(error);
        }, onDone: () {
          print('onDone');
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    player.release();
    player.dispose();
    connectivitySubscription?.cancel();
    Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultBg(
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

  showNotification(NotificationType notificationType, String msg) {
    InAppNotification.show(
      child: NotificationCard(
        type: notificationType,
        message: msg,
      ),
      context: context,
      onTap: () => print('Notification tapped!'),
      duration: Duration(seconds: 5),
    );
  }

  Widget buildStreamView() {
    double screenWidth = MediaQuery.of(context).size.width;
    double topPadding =
        MediaQuery.of(context).padding.left > MediaQuery.of(context).padding.top
            ? MediaQuery.of(context).padding.left
            : MediaQuery.of(context).padding.top;

    double playerWidth = screenWidth - 280 - 16 - topPadding;
    Widget playerWithScreenRecorder = Container(
      width: playerWidth,
      height: MediaQuery.of(context).size.height,
      child: FijkView(
        player: player,
        color: Colors.transparent,
        panelBuilder: (_, __, ___, ____, _____) => Container(),
      ),
    );

    return StreamViewButtons(
      child: playerWithScreenRecorder,
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

  Future<void> startRecording() async {
    final directory = await getTemporaryDirectory();
    // Clean directory before starting recording
    if (directory.existsSync()) {
      directory.listSync().forEach((entity) {
        if (entity is File) {
          entity.deleteSync();
        }
      });
    } else {
      print('Directory does not exist');
    }
    isRecording = true;
    stopwatch.start();
    int index = 0;

    while (isRecording) {
      try {
        DateTime now = DateTime.now();
        int difference = now.difference(lastSnapshotTime).inMilliseconds -
            debounceDurationMillis;

        if (difference >= debounceDurationMillis) {
          lastSnapshotTime = now;
          Uint8List? imageData = await player.takeSnapShot();
          String fileName = 'image_${index.toString().padLeft(6, '0')}.jpg';
          String filePath = '${directory.path}/$fileName';
          File file = File(filePath);
          await file.writeAsBytes(imageData);
          imagePaths.add(filePath);
          index++;
        } else {
          await Future.delayed(Duration(milliseconds: difference));
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

      Uint8List? imageData = await player.takeSnapShot();
      if (imageData == null || imageData.isEmpty) {
      throw Exception("Failed to take snapshot: No data available.");
    }
      final directory = await getTemporaryDirectory();
      String fileName = 'snapshot_$timestamp.jpg';
      String filePath = '${directory.path}/$fileName';
      File file = File(filePath);
      await file.writeAsBytes(imageData);
      GallerySaver.saveImage(filePath).then((bool? success) {
        if (success == true) {
          print("Snapshot successfully saved to gallery.");
          showNotification(NotificationType.defaultType,
              'Snapshot successfully saved to gallery.');
        } else {
          print("Failed to save snapshot to gallery.");
          showNotification(
              NotificationType.error, 'Failed to save snapshot to gallery.');
        }
      });
    } catch (e) {
      showNotification(
          NotificationType.error, 'Failed to save snapshot to gallery.');
    }
  }

  Future<void> stopRecording() async {
    isRecording = false;
    stopwatch.stop();
    await createVideoFromImages(stopwatch.elapsed.inSeconds);

    // Clear temporary images after creating the video
    imagePaths.forEach((path) {
      File(path).delete();
    });
    imagePaths.clear();
    stopwatch.reset();
  }

  Future<void> createVideoFromImages(int desiredVideoLengthInSeconds) async {
    final directory = await getTemporaryDirectory();

    if (directory.existsSync()) {
      directory.listSync(recursive: true).forEach((entity) {
        print(entity.path);
      });
    } else {
      print('Temporary directory doesnt exist');
    }

    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String outputPath = '${directory.path}/video_$timestamp.mp4';

    String inputPattern = '${directory.path}/image_%06d.jpg';

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
        GallerySaver.saveVideo(outputPath).then((bool? success) {
          if (success == true) {
            print("Video successfully saved to gallery.");
            showNotification(NotificationType.defaultType,
                'Video successfully saved to gallery.');
          } else {
            print("Failed to save video to gallery.");
            showNotification(
                NotificationType.error, 'Failed to save video to gallery.');
          }
        });
      } else {
        print("!_!_!_!_!_!_!_!_!__!!__!_!_!_!_!_!_!_!_");
        print(await session.getFailStackTrace());
        print("!_!_!_!_!_!_!_!_!__!!__!_!_!_!_!_!_!_!_");
        print(await session.getLogsAsString());
      }
    });
  }
}
