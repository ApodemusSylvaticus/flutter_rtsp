import 'package:flutter/material.dart';


class DefaultBg extends StatelessWidget {
  final Widget child;

  DefaultBg({required this.child});

  static const Color backgroundColor = Color.fromRGBO(110, 120, 81, 1);
  static const String backgroundImageAsset = "assets/image.png";
  static const double backgroundImageOpacity = 0.15;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        image: DecorationImage(
                    image: AssetImage(backgroundImageAsset),
                    fit: BoxFit.cover,
                    opacity: backgroundImageOpacity,
      )),
      child: child,
    );
  }
}