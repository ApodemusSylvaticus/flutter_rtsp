import 'package:flutter/material.dart';
import 'package:one_more_try/containers/DefaultBg.dart';

class LoadingIndicator extends StatelessWidget {
  final bool isLoading;

  const LoadingIndicator({
    Key? key,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? DefaultBg(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator( valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(255, 255, 255, 1))),
                  SizedBox(height: 16),
                  Text(
                    'Trying to connect...',
                    style: TextStyle(
                       decoration: TextDecoration.none,
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          )
        : SizedBox.shrink();
  }
}
