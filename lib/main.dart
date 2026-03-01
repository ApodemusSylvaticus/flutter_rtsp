import 'dart:async';
import 'package:archer_link/screens/wifi_connect_screen.dart';
import 'package:archer_link/utils/connectivity_checker.dart';
import 'package:archer_link/utils/demo_mode.dart';
import 'package:archer_link/screens/settings_screen.dart';
import 'package:archer_link/screens/stream_view_screen.dart';
import 'package:archer_link/screens/demo_stream_view_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:archer_link/screens/loading_screen.dart';
import 'package:archer_link/widgets/default_bg.dart';
import 'package:media_kit/media_kit.dart';
import 'package:flutter/services.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:archer_link/models/stream_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(MyApp());
}

Future<StreamConfig> getStreamConfig() async {
  final actualIp = await getDeviceIP();
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

  //  if ('192' == actualOctets[0] &&
  //     '168' == actualOctets[1] &&
  //     '1' == actualOctets[2]) {
  //   return StreamConfig(
  //     streamUrl: '192.168.1.117:8554/mystream',
  //     commandUrl: '192.168.1.117:8080/websocket',
  //     tcpCommandUrl: '',
  //     shouldRunStreamView: false,
  //   );
  // }

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
StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;

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
    // В демо-режиме не проверяем сеть — конфиг уже задан
    if (isDemoMode) return;

    StreamConfig actualStreamConfig = await getStreamConfig();

    if (actualStreamConfig.streamUrl != streamConfig.streamUrl &&
        streamConfig.streamUrl != 'stream.trailcam.link:8554/mystream') {
      setState(() {
        streamConfig = actualStreamConfig;
        isLoading = false;
      });
      checkConnection();
    }
  }

  Future<void> checkConnection() async {
    // В демо-режиме всегда доступно
    if (isDemoMode) return;

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
      Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
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

  void activateDemoMode() {
    isDemoMode = true;
    setState(() {
      isLoading = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        streamConfig = StreamConfig(
          streamUrl: 'demo',
          commandUrl: 'demo',
          tcpCommandUrl: '',
          shouldRunStreamView: false,
        );
        isAvailableToConnect = true;
        isLoading = false;
      });
    });
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
        child: const LoadingIndicator(isLoading: true),
      );
    }

    if (isAvailableToConnect == false) {
      setPortraitOrientation();

      return WifiConnectPage(
        openSettings: openSettings,
        onDemoMode: activateDemoMode,
      );
    }

    if (isDemoMode) {
      return DemoStreamViewPage(openSettings: openSettings);
    }

    return StreamViewPage(streamConfig, openSettings);
  }
}
