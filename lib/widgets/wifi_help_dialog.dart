import 'package:flutter/material.dart';

/// Shown under the help picture when the user opens the help themselves.
/// The picture already names the network, so the text only says what to
/// do with it. The Connect screen passes its own text after a failed
/// attempt.
const String wifiHelpText =
    "Join this network in your phone's Wi-Fi settings, then return to the app.";

/// Full-screen help: the picture of the imager's network in the phone's
/// Wi-Fi list, centred, with [message] right under it. Tap anywhere to
/// close. The returned future completes when the dialog is gone.
Future<void> showWifiHelp(BuildContext context, {required String message}) {
  return showDialog<void>(
    context: context,
    useSafeArea: false,
    builder: (BuildContext dialogContext) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(dialogContext).pop(),
        child: Container(
          color: Colors.black,
          width: double.infinity,
          height: double.infinity,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
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
          ),
        ),
      );
    },
  );
}
