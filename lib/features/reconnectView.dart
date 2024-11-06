import 'package:archer_link/features/loading.dart';
import 'package:flutter/material.dart';
import 'package:archer_link/containers/DefaultBg.dart';

class ReconnectView extends StatelessWidget {
  final bool isReconnecting;
  final VoidCallback onReconnect;
  final void Function() openSettings;

  const ReconnectView({
    Key? key,
    required this.isReconnecting,
    required this.onReconnect,
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

@override
  Widget build(BuildContext context) {
    return SafeArea(child: DefaultBg(
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isReconnecting)
                  LoadingIndicator(isLoading: true)
                else ...[
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
    ));
  }
}
   