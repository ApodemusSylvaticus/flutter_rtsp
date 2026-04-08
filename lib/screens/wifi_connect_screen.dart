import 'dart:async';
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:archer_link/widgets/default_bg.dart';
import 'package:archer_link/utils/demo_mode.dart';

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
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return _DemoModeDialog(
          onConfirm: () {
            Navigator.of(dialogContext).pop();
            widget.onDemoMode();
          },
        );
      },
    );
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

/// Модалка ввода пароля для демо-режима
class _DemoModeDialog extends StatefulWidget {
  final VoidCallback onConfirm;

  const _DemoModeDialog({required this.onConfirm});

  @override
  State<_DemoModeDialog> createState() => _DemoModeDialogState();
}

class _DemoModeDialogState extends State<_DemoModeDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isPasswordCorrect = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final correct = _controller.text == demoPassword;
    if (correct != _isPasswordCorrect) {
      setState(() {
        _isPasswordCorrect = correct;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromRGBO(30, 30, 30, 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Заголовок + крестик
            Stack(
              alignment: Alignment.center,
              children: [
                const Center(
                  child: Text(
                    'Demo Mode',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white54,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Поле ввода пароля
            TextField(
              controller: _controller,
              obscureText: false,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter password',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color.fromRGBO(50, 50, 50, 1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Кнопка входа
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isPasswordCorrect ? widget.onConfirm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(85, 107, 47, 1),
                  disabledBackgroundColor: const Color.fromRGBO(60, 60, 60, 1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Enter Demo Mode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _isPasswordCorrect ? Colors.white : Colors.white38,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

