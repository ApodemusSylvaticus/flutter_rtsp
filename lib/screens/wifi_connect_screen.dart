import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:archer_link/services/device_wifi.dart';
import 'package:archer_link/widgets/default_bg.dart';
import 'package:archer_link/widgets/demo_mode_dialog.dart';
import 'package:archer_link/widgets/wifi_help_dialog.dart';

/// Shown while the phone is not in the thermal imager's subnet.
///
/// The home page polls the subnet every 2 s and swaps this page for the
/// stream on its own, so the Connect button only asks the OS to get onto
/// the imager's Wi-Fi and then waits a little before offering help.
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

class _WifiConnectPageState extends State<WifiConnectPage> {
  /// How long to wait for the imager's subnet after iOS accepted the join
  /// request, or after the user came back from the Android Wi-Fi panel.
  /// The join keeps going in the OS after this; the timer only decides
  /// when to show the help picture.
  static const Duration _subnetTimeout = Duration(seconds: 10);

  /// Android: if the Wi-Fi panel never takes the focus from the app, stop
  /// waiting for it to close after this.
  static const Duration _panelGrace = Duration(seconds: 3);

  static const String _helpText =
      'Could not connect to the thermal imager. Make sure it is turned on '
      "and Wi-Fi is enabled, then join its network in your phone's Wi-Fi "
      'settings and return to the app.';

  bool _connecting = false;
  Timer? _timer;

  // Android: the Wi-Fi panel is a system sheet over the app. The app goes
  // inactive while it is up and resumes when it closes.
  late final AppLifecycleListener _lifecycle;
  bool _waitingForPanel = false;
  bool _leftForeground = false;

  /// Set while the help picture is open, so it can be closed when the
  /// stream appears underneath it.
  NavigatorState? _helpNavigator;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onStateChange: _onLifecycleChange);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _lifecycle.dispose();
    _closeHelp();
    super.dispose();
  }

  Future<void> _connect() async {
    if (_connecting) return;
    setState(() => _connecting = true);
    try {
      if (Platform.isIOS) {
        final result = await DeviceWifi.joinArcherWifi();
        if (!mounted) return;
        if (result == WifiJoinResult.cancelled) {
          _stopConnecting();
          return;
        }
        _waitForSubnet();
      } else {
        await DeviceWifi.openWifiPanel();
        if (!mounted) return;
        _waitingForPanel = true;
        _leftForeground = false;
        _timer?.cancel();
        _timer = Timer(_panelGrace, () {
          if (_waitingForPanel) _onPanelClosed();
        });
      }
    } catch (e) {
      print('[CONNECT] join request failed: $e');
      if (!mounted) return;
      _stopConnecting();
      _showHelp(message: _helpText);
    }
  }

  void _onLifecycleChange(AppLifecycleState state) {
    if (!_waitingForPanel) return;
    if (state != AppLifecycleState.resumed) {
      _leftForeground = true;
    } else if (_leftForeground) {
      _onPanelClosed();
    }
  }

  void _onPanelClosed() {
    _waitingForPanel = false;
    _waitForSubnet();
  }

  void _waitForSubnet() {
    _timer?.cancel();
    _timer = Timer(_subnetTimeout, () {
      if (!mounted) return;
      _stopConnecting();
      _showHelp(message: _helpText);
    });
  }

  void _stopConnecting() {
    _timer?.cancel();
    _waitingForPanel = false;
    if (mounted) setState(() => _connecting = false);
  }

  /// The help picture with [message] under it. Tap anywhere to close.
  void _showHelp({required String message}) {
    if (_helpNavigator != null) return;
    _helpNavigator = Navigator.of(context, rootNavigator: true);
    showWifiHelp(context, message: message).then((_) {
      _helpNavigator = null;
    });
  }

  /// Closes the help picture if it is open. Called when this page goes
  /// away because the stream appeared underneath it.
  void _closeHelp() {
    final navigator = _helpNavigator;
    if (navigator == null) return;
    _helpNavigator = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigator.mounted && navigator.canPop()) navigator.pop();
    });
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
