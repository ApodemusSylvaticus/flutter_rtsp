import 'package:archer_link/flutter/packages/flutter/lib/widgets.dart';
import 'package:flutter/material.dart';
import 'package:archer_link/containers/DefaultBg.dart';

class WifiConnectPage extends StatelessWidget {
  final void Function() onConnectToWifi;
  final void Function() resetAll;

  const WifiConnectPage({
    Key? key,
    required this.onConnectToWifi,
    required this.resetAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultBg(
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Please connect to Wi-Fi to continue.',
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
                  onPressed: onConnectToWifi,
                  child: const SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Connect to Wi-Fi',
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
          SafeArea(
            child: Positioned(
                bottom: 10,
                left: 0,
                child: GestureDetector(
                  onTap: resetAll,
                  child: Image.asset(
                    'assets/actionButtonIcon/settings.png',
                    width: 50,
                    height: 50,
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
