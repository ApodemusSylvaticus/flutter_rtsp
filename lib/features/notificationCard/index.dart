import 'package:flutter/material.dart';

enum NotificationType { defaultType, error }

class NotificationCard extends StatelessWidget {
  final String message;
  final NotificationType type;

  NotificationCard({
    required this.message,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (type) {
      case NotificationType.error:
        backgroundColor = Colors.red.shade800;
        textColor = Colors.white;
        break;
      case NotificationType.defaultType:
      default:
        backgroundColor = Color(0xFF34C759); // Цвет вашей кнопки
        textColor = Colors.black;
        break;
    }

    return Container(
      margin: EdgeInsets.only(top: 10, left: MediaQuery.of(context).size.width * 0.1, right: MediaQuery.of(context).size.width * 0.1),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
