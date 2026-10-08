import 'package:flutter/material.dart';

/// Shown under the help picture when the user opens the help themselves.
/// The picture already names the network, so the text only says what to
/// do with it. The Connect screen passes its own text after a failed
/// attempt.
const String wifiHelpText =
    "Connect to the device's Wi-Fi network and return to the app.";

/// Opens the Wi-Fi help for one page and closes it again when that page
/// goes away. Keep one per State and call [close] from `dispose()`: the
/// page is swapped for the stream the moment the device is reachable,
/// and the help must not stay on top of the video.
class WifiHelp {
  NavigatorState? _navigator;

  bool get isOpen => _navigator != null;

  void show(BuildContext context, {required String message}) {
    if (_navigator != null) return;
    _navigator = Navigator.of(context, rootNavigator: true);
    showWifiHelp(context, message: message).then((_) {
      _navigator = null;
    });
  }

  /// Closes the help if it is open. Safe to call from `dispose()`: the
  /// pop is deferred to after the current frame, because dispose runs in
  /// the middle of a build and the navigator must not change then.
  void close() {
    final NavigatorState? navigator = _navigator;
    if (navigator == null) return;
    _navigator = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigator.mounted && navigator.canPop()) navigator.pop();
    });
  }
}

/// Full-screen help: the picture of the imager's network in the phone's
/// Wi-Fi list, centred, with [message] right under it. Closed by the
/// cross in the top right corner or a tap anywhere. The returned future
/// completes when the dialog is gone.
Future<void> showWifiHelp(BuildContext context, {required String message}) {
  return showDialog<void>(
    context: context,
    useSafeArea: false,
    builder: (BuildContext dialogContext) {
      void close() => Navigator.of(dialogContext).pop();

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: close,
        child: Container(
          color: Colors.black,
          width: double.infinity,
          height: double.infinity,
          child: SafeArea(
            child: Stack(
              children: [
                LayoutBuilder(
                  builder:
                      (BuildContext context, BoxConstraints constraints) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // The picture is nearly square (1125x1304): on a
                          // phone it fills the width. The cap keeps it from
                          // pushing the text off the screen in landscape.
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: constraints.maxHeight * 0.6,
                            ),
                            child: Image.asset(
                              'assets/wifi_info.png',
                              width: double.infinity,
                              fit: BoxFit.contain,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                            child: Text(
                              message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                decoration: TextDecoration.none,
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // An explicit way out, so nobody has to guess that a tap
                // on the picture closes it.
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: close,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.close, color: Colors.white, size: 40),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
