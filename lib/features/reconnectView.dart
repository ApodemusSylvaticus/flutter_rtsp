import 'package:flutter/material.dart';

class ReconnectView extends StatelessWidget {
  final bool isReconnecting;
  final VoidCallback onReconnect;

  const ReconnectView({
    Key? key,
    required this.isReconnecting,
    required this.onReconnect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isReconnecting)
          CircularProgressIndicator()
        else ...[
          Text(
            'Check your connection and try again.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: onReconnect,
            child: Text('Reconnect'),
          ),
        ],
      ],
    );
  }
}
