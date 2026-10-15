import 'package:archer_link/utils/trace.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:archer_link/services/device_wifi.dart';
import 'package:archer_link/widgets/default_bg.dart';
import 'package:archer_link/widgets/demo_mode_dialog.dart';
import 'package:archer_link/widgets/wifi_help_dialog.dart';

/// Shown while the phone is not on the thermal imager's network.
///
/// The home page polls the network every 2 s and swaps this page for the
/// stream on its own once the imager answers, so the Connect button only
/// gets the phone onto the imager's Wi-Fi and then waits a little before
/// offering help:
/// - iOS: one join request (DeviceWifi.joinArcherWifi), then a wait.
/// - Android: the system Wi-Fi panel; the user switches Wi-Fi on if
///   needed, picks the imager's network and types its password, once:
///   the phone remembers it, and the next time a tap on it is enough. An
///   in-app device picker was tried and dropped (docs/connect-button.md).
///
/// The home page keeps this page alive under its loading look (see
/// main.dart), so a network event in the middle of a step does not reset
/// the button or lose the step.
class WifiConnectPage extends StatefulWidget {
  final void Function() openSettings;
  final void Function() onDemoMode;

  const WifiConnectPage({
    Key? key,
    required this.openSettings,
    required this.onDemoMode,
  }) : super(key: key);

  @override
  State<WifiConnectPage> createState() => _WifiConnectPageState();
}

/// Where a Connect attempt is.
enum _Phase {
  /// No attempt, or one between two steps.
  idle,

  /// Waiting for a native answer: the iOS join question, the Android
  /// panel being launched.
  asking,

  /// Android: the Wi-Fi panel is up; the attempt goes on when the app is
  /// back in the foreground.
  inPanel,

  /// Waiting for the imager; help when it does not come.
  waiting,
}

class _WifiConnectPageState extends State<WifiConnectPage> {
  /// How long to wait for the imager after iOS accepted the join request,
  /// or after the user came back from the Android Wi-Fi panel. The join
  /// keeps going in the OS after this; the timer only decides when to show
  /// the help picture.
  static const Duration _subnetTimeout = Duration(seconds: 10);

  /// Android: if the Wi-Fi panel never takes the focus from the app, stop
  /// waiting for it to close after this.
  static const Duration _panelGrace = Duration(seconds: 3);

  static const String _helpText =
      'Could not connect to the device. Make sure it is turned on and '
      "Wi-Fi is enabled, then connect to the device's Wi-Fi network and "
      'return to the app.';

  /// The explanation under the "Could not connect to the device" title of
  /// the help that also asks for the password (iOS).
  static const String _passwordHelpText =
      'Make sure it is turned on, then join its Wi-Fi network in Settings '
      'and return to the app.';

  bool _connecting = false;
  _Phase _phase = _Phase.idle;

  /// Bumped by every new attempt and by [_stopConnecting], so an answer
  /// that arrives for an attempt that is already over is dropped.
  int _attempt = 0;

  /// The panel grace timer or the wait for the imager; one at a time.
  Timer? _timer;

  // Android: the Wi-Fi panel is a system sheet over the app. The app goes
  // inactive while it is up and resumes when it closes.
  late final AppLifecycleListener _lifecycle;
  bool _leftForeground = false;

  /// The wait in progress, kept so it can start over (Android) when the
  /// user comes back from the Wi-Fi panel or settings opened on their own
  /// while it ran.
  Duration _waitDuration = _subnetTimeout;
  void Function() _onWaitOver = () {};
  bool _waitPaused = false;

  /// Closed in dispose(): the stream may appear underneath it.
  final WifiHelp _help = WifiHelp();

  @override
  void initState() {
    super.initState();
    trace('CONNECT', 'Connect page created');
    _lifecycle = AppLifecycleListener(onStateChange: _onLifecycleChange);
  }

  @override
  void dispose() {
    trace('CONNECT', 'Connect page disposed (connecting=$_connecting, '
        'phase=${_phase.name}, '
        'timer=${_timer?.isActive == true ? 'running' : 'none'})');
    _timer?.cancel();
    _lifecycle.dispose();
    _help.close();
    super.dispose();
  }

  /// Whether [attempt] is still the attempt on screen.
  bool _current(int attempt) => mounted && attempt == _attempt;

  Future<void> _connect() async {
    if (_connecting) {
      trace('CONNECT', 'Connect tapped again: ignored, still connecting');
      return;
    }
    trace('CONNECT', 'Connect tapped');
    final attempt = ++_attempt;
    setState(() => _connecting = true);
    try {
      if (Platform.isIOS) {
        await _connectIos(attempt);
      } else {
        await _connectAndroid(attempt);
      }
    } catch (e) {
      // Every step handles its own errors; this only keeps the button from
      // spinning forever if one slips through.
      trace('CONNECT', 'unexpected error: $e -> help');
      if (_current(attempt)) _giveUp();
    }
  }

  /// [typedPassword]: the password the user typed in the help after a
  /// failed join (see [_joinFailedAfterAccept]).
  Future<void> _connectIos(int attempt, {String? typedPassword}) async {
    _phase = _Phase.asking;
    try {
      var answered = false;
      Future<void>.delayed(const Duration(seconds: 20), () {
        if (!answered) trace('CONNECT', 'iOS has not answered after 20 s');
      });
      final result = await DeviceWifi.joinArcherWifi(typedPassword: typedPassword)
          .whenComplete(() => answered = true);
      trace('CONNECT', 'join result: $result (page mounted=$mounted)');
      if (!_current(attempt)) return;
      if (result == WifiJoinResult.cancelled) {
        trace('CONNECT', 'user cancelled the iOS question: back to the button');
        _stopConnecting();
        return;
      }
      _waitForImager(_subnetTimeout, _joinFailedAfterAccept);
    } catch (e) {
      // iOS refused before trying, for instance with no imager in range
      // (measured: an error within ~3 s, no join attempt): plain help.
      trace('CONNECT', 'join request failed: $e -> help');
      if (!_current(attempt)) return;
      _giveUp();
    }
  }

  /// iOS accepted the join but the imager never showed up. iOS reports a
  /// failed join to the user and not to the app; measured with a wrong
  /// password: "accepted" after ~15 s, the phone left its Wi-Fi and came
  /// back without the imager. So most likely the password: some units
  /// ship with another one, and owners change it. The help offers to try
  /// again with the device's own password.
  ///
  /// Not always the password: an imager that is still starting can get
  /// the same answer. Seen on 2026-10-15, Connect ~30 s after an imager
  /// restart: iOS asked and "accepted", but the phone never even left its
  /// Wi-Fi, and the remembered, right password got the password field.
  void _joinFailedAfterAccept() {
    trace('CONNECT', 'iOS accepted the join but the imager never came: '
        'most likely the password -> help with the password field');
    _stopConnecting();
    _showHelp(message: _passwordHelpText, askPassword: true);
  }

  /// iOS: the user typed the device's password in the help.
  void _tryTypedPassword(String password) {
    if (!mounted) return;
    trace('CONNECT', 'trying again with the password the user typed');
    final attempt = ++_attempt;
    setState(() => _connecting = true);
    _connectIos(attempt, typedPassword: password);
  }

  Future<void> _connectAndroid(int attempt) async {
    _phase = _Phase.asking;
    await _openPanel(attempt);
  }

  /// Android: slides the Wi-Fi panel up; the wait for the imager starts
  /// once the user closes it.
  Future<void> _openPanel(int attempt) async {
    _timer?.cancel();
    // Set before the launch: the app may go inactive before the launch
    // call returns, and that must count as the user being in the panel.
    _phase = _Phase.inPanel;
    // An app that is not in the foreground right now (another system
    // sheet still closing) will not see the panel take the focus, so its
    // next resume counts as the panel closing.
    _leftForeground =
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed;
    try {
      await DeviceWifi.openWifiPanel();
    } catch (e) {
      trace('CONNECT', 'Wi-Fi panel did not open: $e -> help');
      if (_current(attempt)) _giveUp();
      return;
    }
    if (!_current(attempt) || _phase != _Phase.inPanel) return;
    trace('CONNECT', 'Wi-Fi panel opened');
    if (_leftForeground) return;
    _timer = Timer(_panelGrace, () {
      // Only if the panel never took the focus: once the app has gone
      // inactive, the user is in the panel and we wait for the resume.
      if (_phase == _Phase.inPanel && !_leftForeground) {
        trace('CONNECT', 'the panel did not take the focus in '
            '${_panelGrace.inSeconds} s: treated as closed');
        _onPanelClosed();
      }
    });
  }

  void _onLifecycleChange(AppLifecycleState state) {
    trace('CONNECT', 'app lifecycle: $state (phase ${_phase.name})');
    final away = state != AppLifecycleState.resumed;
    switch (_phase) {
      case _Phase.inPanel:
        if (away) {
          _leftForeground = true;
          _timer?.cancel(); // the grace timer: the panel is up, nothing to guess
        } else if (_leftForeground) {
          _onPanelClosed();
        }
      case _Phase.waiting:
        // Android: the user opened the Wi-Fi panel (or settings) again
        // while we waited. Help shown now would pop up under the panel, so
        // the wait stops and starts over once the user is back.
        if (!Platform.isAndroid) return;
        if (away && !_waitPaused) {
          _waitPaused = true;
          _timer?.cancel();
          trace('CONNECT', 'app left the foreground while waiting: wait '
              'paused');
        } else if (!away && _waitPaused) {
          _waitPaused = false;
          trace('CONNECT', 'back in the app: the wait starts over');
          _startWaitTimer();
        }
      case _Phase.idle:
      case _Phase.asking:
        break;
    }
  }

  void _onPanelClosed() {
    if (_phase != _Phase.inPanel) return;
    _timer?.cancel();
    trace('CONNECT', 'Wi-Fi panel closed');
    _waitForImager(_subnetTimeout, _giveUp);
  }

  /// Waits [timeout] for the imager: the home page replaces this page with
  /// the stream as soon as it answers, which also cancels the timer. Calls
  /// [onTimeout] otherwise.
  void _waitForImager(Duration timeout, void Function() onTimeout) {
    _phase = _Phase.waiting;
    _waitDuration = timeout;
    _onWaitOver = onTimeout;
    _waitPaused = false;
    _startWaitTimer();
  }

  void _startWaitTimer() {
    trace('CONNECT', 'waiting ${_waitDuration.inSeconds} s for the imager');
    _timer?.cancel();
    final attempt = _attempt;
    _timer = Timer(_waitDuration, () {
      if (!_current(attempt) || _phase != _Phase.waiting) return;
      trace('CONNECT', 'no imager after ${_waitDuration.inSeconds} s');
      _phase = _Phase.idle;
      _onWaitOver();
    });
  }

  void _giveUp() {
    trace('CONNECT', 'giving up -> help');
    _stopConnecting();
    _showHelp(message: _helpText);
  }

  void _stopConnecting() {
    trace('CONNECT', 'button back to "Connect"');
    _timer?.cancel();
    _attempt++;
    _phase = _Phase.idle;
    _waitPaused = false;
    if (mounted) setState(() => _connecting = false);
  }

  /// [askPassword] (iOS only): the help also offers to try again with the
  /// device's own password.
  void _showHelp({required String message, bool askPassword = false}) {
    if (!mounted) return;
    trace('CONNECT', 'help dialog shown');
    _help.show(context,
        message: message,
        onPassword: askPassword && Platform.isIOS ? _tryTypedPassword : null);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultBg(
      onLogoLongPress: () =>
          showDemoModeDialog(context, onConfirm: widget.onDemoMode),
      child: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Please connect your device to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    // Stays enabled while connecting (taps are ignored in
                    // _connect) so the button keeps its light background:
                    // the disabled look is near-transparent and the black
                    // text vanished on the dark page.
                    onPressed: _connect,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      minimumSize: const Size(0, 0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_connecting)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black54,
                            ),
                          )
                        else
                          Image.asset(
                            'assets/actionButtonIcon/connectButtonIcon.png',
                            width: 20,
                            height: 20,
                          ),
                        const SizedBox(width: 8),
                        Text(
                          _connecting ? 'Connecting...' : 'Connect',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 10,
              left: 0,
              child: GestureDetector(
                onTap: widget.openSettings,
                child: Image.asset(
                  'assets/actionButtonIcon/settings.png',
                  width: 50,
                  height: 50,
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              right: 0,
              child: GestureDetector(
                onTap: () => _showHelp(message: wifiHelpText),
                child: Image.asset(
                  'assets/actionButtonIcon/infoIcon.png',
                  width: 50,
                  height: 50,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
