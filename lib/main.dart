import 'package:archer_link/services/device_wifi.dart';
import 'package:archer_link/utils/trace.dart';
import 'dart:async';
import 'dart:io' show Platform;
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

/// Diagnostics only: `--dart-define=NO_STREAM=true` keeps the app on the
/// Connect page after the phone joins the imager's Wi-Fi, so the Wi-Fi path
/// can be watched without a stream running. Off by default.
const bool kNoStream = bool.fromEnvironment('NO_STREAM');

/// iOS: when the phone joins the imager on its own (the network is known,
/// the imager was just switched on) it re-uses its cached DHCP address; a
/// restarted imager does not confirm it and iOS drops the address ~8 s after
/// the join, killing every open connection. The imager then keeps the dead
/// WebSocket session for ~60 s and refuses a new one. The stream is cheap to
/// restart, the WebSocket is not, so after such a join the WebSocket is not
/// opened for this long; once the address has survived, or has dropped and
/// come back, it connects at once. Not applied after a Connect-button join
/// (the cache is cleared there) nor after a short blip (the imager cannot
/// have restarted in under [kImagerRestartMinimum]; measured 2026-10-13: a
/// full power cycle brought the Wi-Fi back in 19 s, and its access point
/// blinked once more 2 s after the phone joined). After a long absence a
/// restart is suspected for [kRestartSuspicion]; blinks inside that window
/// re-arm the hold, and the ~4.5 s gap that follows the ~8 s address drop
/// is recognised as the drop itself and ends the suspicion.
const Duration kControlsHold = Duration(seconds: 10);
const Duration kImagerRestartMinimum = Duration(seconds: 5);
const Duration kRestartSuspicion = Duration(seconds: 90);

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
    DeviceWifi.listenToNativeTrace();
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

 

  /// When the imager's network was last lost, and whether the first poll
  /// of this run has happened (a network already present at launch has no
  /// history to judge by).
  DateTime? _imagerLostAt;
  DateTime? _imagerAppearedAt;
  DateTime? _restartSuspectedUntil;
  bool _firstPollDone = false;

  /// Until when the stream page must keep the WebSocket closed; null = no
  /// hold. Kept here because the page is recreated on connectivity events.
  DateTime? _controlsHoldUntil;

  Future<void> getNetworkData() async {
    // В демо-режиме не проверяем сеть — конфиг уже задан
    if (isDemoMode) return;

    StreamConfig actualStreamConfig = await getStreamConfig();
    final firstPoll = !_firstPollDone;
    _firstPollDone = true;

    if (actualStreamConfig.streamUrl != streamConfig.streamUrl &&
        streamConfig.streamUrl != 'stream.trailcam.link:8554/mystream') {
      trace('HOME', 'stream config changed: "${streamConfig.streamUrl}" -> '
          '"${actualStreamConfig.streamUrl}"; checking connection');
      final imagerAppeared = actualStreamConfig.shouldRunStreamView &&
          !streamConfig.shouldRunStreamView;
      final imagerLost = streamConfig.shouldRunStreamView &&
          !actualStreamConfig.shouldRunStreamView;
      if (imagerAppeared) {
        _controlsHoldUntil = _decideControlsHold(firstPoll);
        _imagerAppearedAt = DateTime.now();
      }
      if (imagerLost) {
        _imagerLostAt = DateTime.now();
        _controlsHoldUntil = null;
      }
      setState(() {
        streamConfig = actualStreamConfig;
        isLoading = false;
      });
      checkConnection();
    }
  }

  /// See [kControlsHold].
  DateTime? _decideControlsHold(bool firstPoll) {
    if (!Platform.isIOS) return null;
    final now = DateTime.now();
    final joinRequestedAt = DeviceWifi.lastJoinRequestAt;
    if (joinRequestedAt != null &&
        now.difference(joinRequestedAt) < const Duration(seconds: 40)) {
      _restartSuspectedUntil = null;
      trace('HOME', 'imager appeared after a Connect-button join: no controls hold');
      return null;
    }
    if (firstPoll) {
      trace('HOME', 'imager already present at launch: no controls hold');
      return null;
    }
    final lostAt = _imagerLostAt;
    final away = lostAt == null ? null : now.difference(lostAt);
    final suspectedUntil = _restartSuspectedUntil;
    final suspected = suspectedUntil != null && now.isBefore(suspectedUntil);
    if (away != null && away < kImagerRestartMinimum) {
      if (!suspected) {
        trace('HOME', 'imager back after ${away.inMilliseconds} ms: too short '
            'for a restart, no controls hold');
        return null;
      }
      // A short gap while a restart is suspected: either the imager's access
      // point blinked while booting, or this is the address coming back after
      // the ~8 s DHCP drop (the address then lived 7-12 s).
      final appearedAt = _imagerAppearedAt;
      final lived = appearedAt == null ? null : lostAt!.difference(appearedAt);
      if (lived != null &&
          lived >= const Duration(seconds: 7) &&
          lived <= const Duration(seconds: 12)) {
        _restartSuspectedUntil = null;
        trace('HOME', 'imager back after ${away.inMilliseconds} ms following '
            '${lived.inMilliseconds} ms of address: that was the DHCP drop, '
            'address is clean now, no controls hold');
        return null;
      }
      trace('HOME', 'imager back after ${away.inMilliseconds} ms while a '
          'restart is suspected (address lived ${lived?.inMilliseconds} ms): '
          'holding the WebSocket for ${kControlsHold.inSeconds} s again');
      return now.add(kControlsHold);
    }
    _restartSuspectedUntil = now.add(kRestartSuspicion);
    trace('HOME', 'imager appeared on its own '
        '${away == null ? 'for the first time this run' : 'after ${away.inSeconds} s away'}'
        ': restart suspected, holding the WebSocket for ${kControlsHold.inSeconds} s');
    return now.add(kControlsHold);
  }

  Future<void> checkConnection() async {
    // В демо-режиме всегда доступно
    if (isDemoMode) return;

    trace('HOME', 'checkConnection: loading page shown');
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
      if (kNoStream && isAvailable) {
        trace('HOME', 'NO_STREAM: imager subnet reachable, staying on the '
            'Connect page on purpose');
        isAvailable = false;
      }

      trace('HOME', 'checkConnection: available=$isAvailable -> '
          '${isAvailable ? 'stream' : 'Connect'} page');
      setState(() {
        isAvailableToConnect = isAvailable;
        isLoading = false;
      });
    } catch (e) {
      trace('HOME', 'checkConnection failed: $e -> Connect page');
      setState(() {
        isAvailableToConnect = false;
        isLoading = false;
      });
    }
  }

void monitorWifiConnection() {
  connectivitySubscription =
      Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
    trace('HOME', 'connectivity changed: $results; checking connection');
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

    return StreamViewPage(streamConfig, openSettings, activateDemoMode,
        controlsHoldUntil: _controlsHoldUntil);
  }
}
