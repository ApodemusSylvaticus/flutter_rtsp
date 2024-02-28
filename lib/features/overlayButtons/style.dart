import 'package:flutter/material.dart';

class CustomButtonStyle {
  static final ButtonStyle menuButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.white.withOpacity(0.4), 
    foregroundColor: Colors.green, 
    padding: EdgeInsets.zero,
    minimumSize: Size(100.0, 50.0), 
    side: BorderSide(
      color: Colors.white.withOpacity(0.8), 
      width: 1.0,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4.0), 
    ),
  );

   static final TextStyle buttonTextStyle = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
    color: Colors.green,
  );
}
