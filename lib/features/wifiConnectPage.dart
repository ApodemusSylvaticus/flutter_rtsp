import 'package:flutter/material.dart';

class WifiConnectPage extends StatelessWidget {
  final void Function() onConnectToWifi;

  const WifiConnectPage({
    Key? key,
    required this.onConnectToWifi,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Please connect to Wi-Fi to continue.',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: onConnectToWifi,
            child: Text('Connect to Wi-Fi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
        ],
      )),
    );
  }
}
