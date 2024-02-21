import 'package:flutter/material.dart';

class WifiConnectPage extends StatelessWidget {
  final void Function() onConnectToWifi;

  const WifiConnectPage({
    Key? key,
    required this.onConnectToWifi,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Please connect to Wi-Fi to continue.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: onConnectToWifi,
          child: Text('Connect to Wi-Fi'),
        ),
      ],
    );
  }
}
