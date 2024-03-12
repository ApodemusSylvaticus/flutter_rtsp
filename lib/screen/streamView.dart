import 'dart:async';
import 'dart:io';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:one_more_try/features/loading.dart';
import 'package:one_more_try/features/overlayButtons/index.dart';
import 'package:one_more_try/features/reconnectView.dart';
import 'package:one_more_try/features/wifiConnectPage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:wakelock/wakelock.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ParsedData {
  final String? ipAddress;
  final String? host;
  final String? rest;

  ParsedData({this.ipAddress, this.host, this.rest});

  factory ParsedData.fromString(String input) {
    var regex =
        RegExp(r'^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})(?::(\d+))?(.*)$');
    var match = regex.firstMatch(input);
    if (match != null) {
      var ip = match.group(1);
      var host = match.group(2) != null ? match.group(2) : null;
      var link = match.group(3);
      return ParsedData(ipAddress: ip, host: host, rest: link);
    } else {
      throw FormatException('Invalid input format');
    }
  }
}

class StreamViewPage extends StatefulWidget {
  final String streamUrl;
  final String commandUrl;
  final bool shouldRunStreamView;
  final void Function() resetAll;

  const StreamViewPage(
      this.streamUrl, this.commandUrl, this.shouldRunStreamView, this.resetAll,
      {super.key});

  @override
  State<StreamViewPage> createState() => _StreamViewPageState();
}

class _StreamViewPageState extends State<StreamViewPage> {
  final FijkPlayer player = FijkPlayer();
  bool showReconnectButton = false;
  bool isReconnecting = false;
  bool isLoading = true;

  StreamSubscription<ConnectivityResult>? connectivitySubscription;
  bool isConnectedToWifi = true;
  bool isRecording = false;
  Stopwatch stopwatch = Stopwatch();
  List<String> imagePaths = [];

  @override
  void initState() {
    super.initState();
    monitorWifiConnection();
    checkWifiAndInitializePlayer();
  }

  void monitorWifiConnection() {
    connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.wifi) {
        if (!isConnectedToWifi) {
          checkWifiAndInitializePlayer();
        }
        setState(() {
          isConnectedToWifi = true;
        });
      } else {
        setState(() {
          isConnectedToWifi = false;
        });
        if (isRecording) {
          stopRecording();
        }
        setPortraitOrientation();
        Wakelock.disable();
      }
    });
  }

  void openWifiSettings() async {
    if (Platform.isAndroid) {
      final AndroidIntent intent = AndroidIntent(
        action: 'android.settings.WIFI_SETTINGS',
      );
      await intent.launch();
    } else if (Platform.isIOS) {
      // For iOS, try to open Wi-Fi settings URL
      // Note: This may not always work due to iOS restrictions
      const String url = 'App-Prefs:root=WIFI';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        // Consider showing an alert or some other indication that the Wi-Fi settings couldn't be opened
        print('Could not launch $url');
      }
    }
  }

  Future<void> checkWifiAndInitializePlayer() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi) {
      // If connected to Wi-Fi
      setState(() {
        isConnectedToWifi = true;
      });

      initializePlayer();
    } else {
      // Not connected to Wi-Fi
      setState(() {
        isConnectedToWifi = false;
      });
    }
  }

  Future<void> initializePlayer() async {
    setState(() {
      isReconnecting = true;
      isLoading = true;
    });
    final parsed = ParsedData.fromString(widget.streamUrl);

    try {
      if (widget.shouldRunStreamView) {
        var socket = await Socket.connect(parsed.ipAddress, 8888);
        socket.writeln('CMD_RTSP_TRANS_START');
        await socket.flush();
      }

      player.addListener(() {
        print("player.state ${player.state}");

        if (player.state == FijkState.prepared) {
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
      await player.setOption(FijkOption.hostCategory, "enable-snapshot", 1);
      await player.setOption(FijkOption.playerCategory, "packet-buffering", 0);
      await player.setOption(FijkOption.playerCategory, "framedrop", 1);
      await player.setVolume(0);

      player.setOption(FijkOption.playerCategory, "flush_packets", 1);
      player.setOption(FijkOption.formatCategory, "rtsp_transport", "tcp");

      await player.setDataSource(
          "rtsp://${parsed.ipAddress}${parsed.host != null ? ':${parsed.host}' : ''}${parsed.rest != null ? '${parsed.rest}' : ''}",
          autoPlay: true);
      // Player configuration

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
        if (player.state == FijkState.completed) {
          setState(() {
            setLandscapeOrientation();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    player.release();
    connectivitySubscription?.cancel();
    Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    if (!isConnectedToWifi) {
      return WifiConnectPage(
        onConnectToWifi: openWifiSettings,
        resetAll: widget.resetAll,
      );
    } else if (isLoading == true) {
      return LoadingIndicator(isLoading: isLoading);
    } else if (showReconnectButton) {
      return ReconnectView(
        isReconnecting: isReconnecting,
        onReconnect: checkWifiAndInitializePlayer,
        resetAll: widget.resetAll,
      );
    } else {
      return buildStreamView();
    }
  }

  Widget buildStreamView() {
    double screenWidth = MediaQuery.of(context).size.width;
    double playerWidth =
        screenWidth * 1; // Assuming you want the player to be full screen width

    // The player wrapped with ScreenRecorder
    Widget playerWithScreenRecorder = Container(
      width: playerWidth,
      height: MediaQuery.of(context).size.height,
      child: FijkView(
        player: player,
        color: Colors.black,
        panelBuilder: (_, __, ___, ____, _____) => Container(),
      ),
    );

    return Stack(
      children: [
        Center(child: playerWithScreenRecorder),
        OverlayButtons(
          commandUrl: widget.commandUrl,
          isRecording: isRecording,
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
        ),
      ],
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
   isRecording = true;
      stopwatch.start();
      int index = 0;

      while (isRecording) {
        Uint8List? imageData = await player.takeSnapShot();
        final directory = await getTemporaryDirectory();
        String fileName = 'image_${index.toString().padLeft(6, '0')}.jpg';
        String filePath = '${directory.path}/$fileName';
        File file = File(filePath);
        await file.writeAsBytes(imageData);
        imagePaths.add(filePath);
        index++;
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
      print('Каталог не существует');
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
          } else {
            print("Failed to save video to gallery.");
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
