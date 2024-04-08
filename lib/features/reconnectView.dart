import 'package:flutter/material.dart';
import 'package:one_more_try/containers/DefaultBg.dart';

class ReconnectView extends StatelessWidget {
  final bool isReconnecting;
  final VoidCallback onReconnect;
  final void Function() resetAll;

  const ReconnectView({
    Key? key,
    required this.isReconnecting,
    required this.onReconnect,
    required this.resetAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultBg(
      child: Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isReconnecting)
            CircularProgressIndicator()
          else ...[
            Text(
              'Check your connection and try again.',
              style: TextStyle(
                 decoration: TextDecoration.none,
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: onReconnect,
              child: Text(
                'Reconnect',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: resetAll,
              child: Text('Reset',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
            ),
          ],
        ],
      )),
    );
  }
}
