import 'dart:async';
import 'package:archer_link/features/wifiConnectPage.dart';
import 'package:archer_link/helper/isConnected.dart';
import 'package:archer_link/screen/settings.dart';
import 'package:archer_link/screen/streamView.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:archer_link/features/loading.dart';
import 'package:archer_link/containers/DefaultBg.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:flutter/services.dart';
import 'package:in_app_notification/in_app_notification.dart';

void main() {
  runApp(MyApp());
}

class StreamConfig {
  final String streamUrl;
  final String commandUrl;
  final String tcpCommandUrl;
  final bool shouldRunStreamView;

  StreamConfig({
    required this.streamUrl,
    required this.commandUrl,
    required this.tcpCommandUrl,
    required this.shouldRunStreamView,
  });
}

Future<StreamConfig> getStreamConfig() async {
  final actualIp = await WiFiForIoTPlugin.getIP();
  if (actualIp == null) {
    return StreamConfig(
      streamUrl: '',
      commandUrl: '',
      tcpCommandUrl: '',
      shouldRunStreamView: false,
    );
  }

  final actualOctets = actualIp.split('.');
  if (actualOctets.length < 3) {
    return StreamConfig(
      streamUrl: '',
      commandUrl: '',
      tcpCommandUrl: '',
      shouldRunStreamView: false,
    );
  }

   if ('192' == actualOctets[0] &&
      '168' == actualOctets[1] &&
      '1' == actualOctets[2]) {
    return StreamConfig(
      streamUrl: '192.168.1.117:8554/mystream',
      commandUrl: '192.168.1.117:8080/websocket',
      tcpCommandUrl: '',
      shouldRunStreamView: false,
    );
  }

  if ('192' == actualOctets[0] &&
      '168' == actualOctets[1] &&
      '1' == actualOctets[2]) {
    return StreamConfig(
      streamUrl: '192.168.1.1:555//ir.sdp',
      commandUrl: '192.168.1.1:8080/websocket',
      tcpCommandUrl: '',
      shouldRunStreamView: false,
    );
  }

  if ('192' == actualOctets[0] &&
      '168' == actualOctets[1] &&
      '100' == actualOctets[2]) {
    return StreamConfig(
      streamUrl: '192.168.100.1/stream0',
      commandUrl: '192.168.100.1:8080/websocket',
      tcpCommandUrl: '192.168.100.1:8888',
      shouldRunStreamView: true,
    );
  }

  return StreamConfig(
    streamUrl: '',
    commandUrl: '',
    tcpCommandUrl: '',
    shouldRunStreamView: false,
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MaterialColor customColor = MaterialColor(0xFF34C759, {
      50: Color(0xFFF0F9E8),
      100: Color(0xFFDCEDC8),
      200: Color(0xFFCCE5B9),
      300: Color(0xFFB0D68D),
      400: Color(0xFF8CC665),
      500: Color(0xFF69B100),
      600: Color(0xFF5A9B00),
      700: Color(0xFF4A8500),
      800: Color(0xFF3A6F00),
      900: Color(0xFF2C5700),
    });

    return InAppNotification(
      child: MaterialApp(
        title: 'Archer Link',
        theme: ThemeData(
          textSelectionTheme: TextSelectionThemeData(
            selectionHandleColor: Color.fromRGBO(52, 198, 89, 1),
          ),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = false;
  bool isAvailableToConnect = false;
  bool isSettingsOpen = false;
  Timer? _timer;

  StreamConfig streamConfig = StreamConfig(
    commandUrl: '',
    tcpCommandUrl: '',
    shouldRunStreamView: false,
    streamUrl: '',
  );
  StreamSubscription<ConnectivityResult>? connectivitySubscription;

  @override
  void initState() {
    super.initState();
    getNetworkData();
    monitorWifiConnection();
    handleMonitorWifiConnection();
  }

  @override
  void dispose() {
    _timer?.cancel();
    connectivitySubscription?.cancel();
    super.dispose();
  }

  void handleMonitorWifiConnection() {
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      getNetworkData();
    });
  }

  void setPortraitOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

 

  Future<void> getNetworkData() async {
    StreamConfig actualStreamConfig = await getStreamConfig();
    print('getNetworkData, ${actualStreamConfig.streamUrl} !== ${streamConfig.streamUrl }');

    if (actualStreamConfig.streamUrl != streamConfig.streamUrl &&
        streamConfig.streamUrl != 'stream.trailcam.link:8554/mystream') {
      setState(() {
        streamConfig = actualStreamConfig;
        isLoading = false;
      });
      print('checkConnection');
      checkConnection();
    }
  }

  Future<void> checkConnection() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (streamConfig.streamUrl == 'stream.trailcam.link:8554/mystream') {
        bool isAvailable = await connectivityCheck();

        setState(() {
          isAvailableToConnect = isAvailable;
          isLoading = false;
        });
        return;
      }

      bool isAvailable = await isConnected(streamConfig.streamUrl);

      setState(() {
        isAvailableToConnect = isAvailable;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isAvailableToConnect = false;
        isLoading = false;
      });
    }
  }

  void monitorWifiConnection() {
    connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((ConnectivityResult _) {
      checkConnection();
    });
  }

  void openSettings() {
    setState(() => isSettingsOpen = true);
  }

  void closeSettings() {
    setState(() => isSettingsOpen = false);
  }

  void resetAll(StreamConfig newStreamConfig) {
    closeSettings();
    setState(() => streamConfig = newStreamConfig);
    checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    if (isSettingsOpen) {
      setPortraitOrientation();

      return SettingsPage(streamConfig, resetAll, closeSettings);
    }

    if (isLoading) {
      setPortraitOrientation();

      return DefaultBg(
        child: const Center(
          child: LoadingIndicator(isLoading: true),
        ),
      );
    }

    if (isAvailableToConnect == false) {
      setPortraitOrientation();

      return WifiConnectPage(
        openSettings: openSettings,
      );
    }

    return StreamViewPage(streamConfig, openSettings);
  }
}
