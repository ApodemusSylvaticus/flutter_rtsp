import 'package:flutter/material.dart';

/// What the help picture shows. Used under it when the user opens the
/// help themselves; the Connect screen passes its own text after a
/// failed attempt.
const String wifiHelpText =
    "Connect your phone to the thermal imager's Wi-Fi network. "
    'Its name starts with ARCHER_ followed by the last 4 digits of the '
    'serial number.';

/// Full-screen help: the picture of the imager's network in the phone's
/// Wi-Fi list at the top, [message] under it. Tap anywhere to close.
/// The returned future completes when the dialog is gone.
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
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Column(
                children: [
                  // The picture is nearly square (1125x1304). On a phone
                  // it fills the width and takes a bit over half of the
                  // height; the cap keeps it from pushing the text out in
                  // landscape.
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: constraints.maxHeight * 0.6,
                    ),
                    child: Image.asset(
                      'assets/wifi_info.png',
                      width: double.infinity,
                      fit: BoxFit.contain,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                  Expanded(
                    child: SafeArea(
                      top: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
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
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}
