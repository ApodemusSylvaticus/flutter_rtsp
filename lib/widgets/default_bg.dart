import 'package:flutter/material.dart';


class DefaultBg extends StatelessWidget {
  final Widget child;
  final VoidCallback? onLogoLongPress;

  DefaultBg({required this.child, this.onLogoLongPress});

  static const Color backgroundColorStart = Color.fromRGBO(85, 107, 47, 1);
  static const Color backgroundColorEnd = Color.fromRGBO(0, 0, 0, 1);
  static const String backgroundImageAsset = "assets/appName.png";

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [backgroundColorStart, backgroundColorEnd],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        Positioned(
          top: MediaQuery.of(context).padding.top > 10 ? MediaQuery.of(context).padding.top : MediaQuery.of(context).padding.top + 8,
          left: 0,
          right: 0,
          child: GestureDetector(
            onLongPress: onLogoLongPress,
            child: Image.asset(
              backgroundImageAsset,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Контент
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: child,
        ),
      ],
    );
  }
}
