import 'dart:async';
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:archer_link/widgets/default_bg.dart';
import 'package:archer_link/widgets/demo_mode_dialog.dart';

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
  Timer? _longPressTimer;

  void _onLogoLongPress() {
    _longPressTimer?.cancel();
    _showDemoDialog();
  }

  void _showDemoDialog() {
    showDemoModeDialog(context, onConfirm: widget.onDemoMode);
  }

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

  void openWifiSettings() {
    if (Platform.isIOS) {
      AppSettings.openAppSettings(type: AppSettingsType.settings);
    } else {
      AppSettings.openAppSettings(type: AppSettingsType.wifi);
    }
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultBg(
      onLogoLongPress: _onLogoLongPress,
      child: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
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
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: openWifiSettings,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      minimumSize: Size(0, 0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/actionButtonIcon/connectButtonIcon.png',
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Connect',
                          style: TextStyle(
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
                onTap: () => func(context),
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
