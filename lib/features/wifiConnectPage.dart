import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:archer_link/containers/DefaultBg.dart';
import 'package:url_launcher/url_launcher.dart';

class WifiConnectPage extends StatelessWidget {
  final void Function() openSettings;
  const WifiConnectPage({
    Key? key,
    required this.openSettings,
  }) : super(key: key);

  void func(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
            color: Colors.black,
            child: Center(
              child: Image.asset('assets/wifi_info.png'),
            ),
          ),
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: DefaultBg(
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Please connect your device to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: openWifiSettings,
                  child: const SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Connect',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
              bottom: 10,
              left: 0,
              child: GestureDetector(
                onTap: () => openSettings(),
                child: Image.asset(
                  'assets/actionButtonIcon/settings.png',
                  width: 50,
                  height: 50,
                ),
              )),
          Positioned(
            bottom: 10,
            right: 0,
            child: GestureDetector(
              onTap: () => func(context),
              child: Image.asset(
                'assets/actionButtonIcon/infoIcon.png',
                width: 50,
                height: 50,
              ),
            ),
          )
        ],
      ),
    ));
  }
}
