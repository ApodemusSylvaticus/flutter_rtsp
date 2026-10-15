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
  // Before runApp, so the native side's calls have a handler from the start;
  // on Android it also asks whether the app is bound to an imager Wi-Fi
  // already.
  DeviceWifi.listenToNative();
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

/// Android: how long a check waits for the app to be bound to the imager's
/// Wi-Fi before it probes. A probe socket opened before the binding goes
/// out over mobile data, the default network while the Wi-Fi has no
/// internet, and fails. The binding normally follows the address at once;
/// the cap is only for a binding report that never comes: the probe then
/// runs anyway and still works whenever Wi-Fi is the default network.
const Duration kImagerBindingWait = Duration(seconds: 3);

/// While the phone is in a device subnet but the stream's RTSP server did
/// not answer, the Connect page stays and the probe runs again quietly at
/// most this often, so an imager whose RTSP server starts a little after
/// its Wi-Fi is still picked up.
const Duration kReprobeInterval = Duration(seconds: 4);

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
  StreamSubscription<bool>? _imagerNetworkSubscription;

  /// Numbers the checks: only the newest one may change the page, so a slow
  /// probe cannot overwrite the result of a check started after it.
  int _checkId = 0;
  int _checksInFlight = 0;
  DateTime? _lastCheckEndedAt;

  @override
  void initState() {
    super.initState();
    _imagerNetworkSubscription =
        DeviceWifi.imagerNetworkChanges.listen(_onImagerNetworkChanged);
    getNetworkData();
    monitorWifiConnection();
    handleMonitorWifiConnection();
  }

  @override
  void dispose() {
    _timer?.cancel();
    connectivitySubscription?.cancel();
    _imagerNetworkSubscription?.cancel();
    super.dispose();
  }

  /// Android: the app was just bound to a Wi-Fi in a device subnet. From
  /// now on a probe reaches the imager, so look at the network at once
  /// instead of at the next poll.
  void _onImagerNetworkChanged(bool bound) {
    if (!bound || isDemoMode || !mounted) return;
    trace('HOME', 'app bound to a device-subnet Wi-Fi: checking the network now');
    getNetworkData(reprobeNow: true);
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

  Future<void> getNetworkData({bool reprobeNow = false}) async {
    // В демо-режиме не проверяем сеть — конфиг уже задан
    if (isDemoMode) return;

    StreamConfig actualStreamConfig = await getStreamConfig();
    if (!mounted) return;
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
    } else if (_shouldReprobe(actualStreamConfig, now: reprobeNow)) {
      checkConnection(quiet: true);
    }
  }

  /// The phone is in a device subnet, but the RTSP probe failed and the
  /// Connect page is shown: probe again, at most every [kReprobeInterval]
  /// ([now]: at once), and never while another check runs.
  bool _shouldReprobe(StreamConfig actual, {required bool now}) {
    if (kNoStream || isAvailableToConnect || isLoading || isSettingsOpen) {
      return false;
    }
    if (actual.streamUrl.isEmpty || actual.streamUrl != streamConfig.streamUrl) {
      return false;
    }
    if (_checksInFlight > 0) return false;
    if (now) return true;
    final lastCheck = _lastCheckEndedAt;
    return lastCheck == null ||
        DateTime.now().difference(lastCheck) >= kReprobeInterval;
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

  /// Decides between the stream page and the Connect page.
  ///
  /// Being in a device subnet is not enough: many home routers are
  /// 192.168.1.1 as well. The stream page is shown only when the stream's
  /// RTSP server answers a probe (see probeRtsp). [quiet]: a re-probe from
  /// the Connect page; no loading page, and a failure changes nothing.
  Future<void> checkConnection({bool quiet = false}) async {
    // В демо-режиме всегда доступно
    if (isDemoMode) return;

    final check = ++_checkId;
    _checksInFlight++;
    if (quiet) {
      trace('HOME', 'checkConnection #$check (quiet): probing the imager '
          'again, the Connect page stays');
    } else {
      trace('HOME', 'checkConnection #$check: loading page shown');
      setState(() {
        isLoading = true;
      });
    }

    try {
      if (streamConfig.streamUrl == 'stream.trailcam.link:8554/mystream') {
        bool isAvailable = await connectivityCheck();

        setState(() {
          isAvailableToConnect = isAvailable;
          isLoading = false;
        });
        return;
      }

      final streamUrl = streamConfig.streamUrl;
      bool isAvailable = await isConnected(streamUrl);
      if (kNoStream && isAvailable) {
        trace('HOME', 'NO_STREAM: imager subnet reachable, staying on the '
            'Connect page on purpose');
        isAvailable = false;
      } else if (isAvailable) {
        if (Platform.isAndroid && !DeviceWifi.imagerNetworkBound) {
          await _waitForImagerBinding();
          if (check != _checkId) {
            trace('HOME', 'checkConnection #$check: superseded by '
                '#$_checkId while waiting for the binding');
            return;
          }
        }
        isAvailable = await probeRtsp(streamUrl);
        if (isAvailable && Platform.isIOS) {
          // The imager answers: a password the user typed for this join
          // worked, keep it (a no-op otherwise).
          unawaited(DeviceWifi.rememberJoinedPassword());
        }
      }

      if (!mounted || isDemoMode) return;
      if (check != _checkId) {
        trace('HOME', 'checkConnection #$check: superseded by #$_checkId, '
            'result dropped');
        return;
      }
      if (quiet && !isAvailable) return;

      trace('HOME', 'checkConnection #$check: available=$isAvailable -> '
          '${isAvailable ? 'stream' : 'Connect'} page');
      setState(() {
        isAvailableToConnect = isAvailable;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted || isDemoMode || check != _checkId) return;
      trace('HOME', 'checkConnection #$check failed: $e -> Connect page');
      setState(() {
        isAvailableToConnect = false;
        isLoading = false;
      });
    } finally {
      _checksInFlight--;
      _lastCheckEndedAt = DateTime.now();
    }
  }

  /// Android: waits for the app to be bound to the imager's Wi-Fi, at most
  /// [kImagerBindingWait]. Event-driven: returns the moment the binding is
  /// reported.
  Future<void> _waitForImagerBinding() async {
    trace('HOME', 'device subnet is up but the app is not bound to it yet: '
        'waiting up to ${kImagerBindingWait.inSeconds} s before probing');
    final watch = Stopwatch()..start();
    final bound = Completer<void>();
    final subscription = DeviceWifi.imagerNetworkChanges.listen((isBound) {
      if (isBound && !bound.isCompleted) bound.complete();
    });
    try {
      await bound.future.timeout(kImagerBindingWait);
      trace('HOME', 'bound after ${watch.elapsedMilliseconds} ms');
    } on TimeoutException {
      trace('HOME', 'not bound after ${kImagerBindingWait.inSeconds} s: '
          'probing anyway');
    } finally {
      await subscription.cancel();
    }
  }

void monitorWifiConnection() {
  connectivitySubscription =
      Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
    if (Platform.isAndroid &&
        isAvailableToConnect &&
        !isLoading &&
        DeviceWifi.imagerNetworkBound) {
      // The app's traffic is bound to the imager Wi-Fi, so a change of the
      // default network (Android accepting the Wi-Fi after its no-internet
      // question, mobile data coming and going) does not touch the stream.
      // A full check here would replace the stream page and restart the
      // video for nothing; losing the imager shows in the poll and in the
      // binding events.
      trace('HOME', 'connectivity changed: $results; bound to the imager, '
          'the stream stays');
      return;
    }
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

    if (isAvailableToConnect == false) {
      setPortraitOrientation();

      // The Connect page stays mounted under the loading look: a network
      // event in the middle of a Connect attempt (Wi-Fi switched on in the
      // panel, Android leaving the home network to join the imager) runs a
      // check, and replacing the page for it would reset the button and
      // drop the attempt (the panel it waits for, the wait after it).
      return Stack(
        fit: StackFit.expand,
        children: [
          Visibility(
            visible: !isLoading,
            maintainState: true,
            child: WifiConnectPage(
              openSettings: openSettings,
              onDemoMode: activateDemoMode,
            ),
          ),
          if (isLoading)
            DefaultBg(
              child: const LoadingIndicator(isLoading: true),
            ),
        ],
      );
    }

    if (isLoading) {
      setPortraitOrientation();

      return DefaultBg(
        child: const LoadingIndicator(isLoading: true),
      );
    }

    if (isDemoMode) {
      return DemoStreamViewPage(openSettings: openSettings);
    }

    return StreamViewPage(streamConfig, openSettings, activateDemoMode,
        controlsHoldUntil: _controlsHoldUntil);
  }
}
