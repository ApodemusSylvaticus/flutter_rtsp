import 'package:flutter/material.dart';

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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
        ),
      ),
    );
  }
}

enum NotificationType { defaultType, error }