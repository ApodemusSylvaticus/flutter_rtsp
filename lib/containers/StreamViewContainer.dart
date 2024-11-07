import 'package:flutter/material.dart';


class Streamviewcontainer extends StatelessWidget {
  final Widget child;

  Streamviewcontainer({required this.child});


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity, color: Colors.black,
      
        ),

      
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: child,
        ),
      ],
    );
  }
}