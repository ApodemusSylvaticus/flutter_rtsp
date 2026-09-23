import 'package:archer_link/screens/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:archer_link/widgets/default_bg.dart';
import 'package:archer_link/widgets/demo_mode_dialog.dart';

class ReconnectView extends StatelessWidget {
  final bool isReconnecting;
  final VoidCallback onReconnect;
  final void Function() openSettings;
  final void Function() onDemoMode;

  const ReconnectView({
    Key? key,
    required this.isReconnecting,
    required this.onReconnect,
    required this.openSettings,
    required this.onDemoMode,
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

@override
  Widget build(BuildContext context) {
    return DefaultBg(
      onLogoLongPress: () => showDemoModeDialog(context, onConfirm: onDemoMode),
      child: SafeArea(
        child: Stack(
        children: [
          if (isReconnecting)
            const LoadingIndicator(isLoading: true)
          else
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  const Text(
                    'Check your connection and try again',
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
                    onPressed: onReconnect,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      minimumSize: Size(0, 0), 
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/actionButtonIcon/reconnectButtonIcon.png',
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Reconnect',
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
              onTap: openSettings,
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
          )
        ],

        ),
      ),
    );
  }
}
   