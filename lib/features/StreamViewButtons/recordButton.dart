import 'package:flutter/material.dart';
import 'package:archer_link/features/StreamViewButtons/customButton.dart';


class RecordButton extends StatelessWidget {
  final bool isRecording;
  final Function(bool) onToggle;

  const RecordButton({
    Key? key,
    required this.isRecording,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      onClick: () => {onToggle(!isRecording)},
      text: 'REC',
      additionalData: isRecording
          ? Image.asset(
              'assets/actionButtonIcon/stopRecording.png',
              width: 20,
              height: 20,
            )
          : Image.asset(
              'assets/actionButtonIcon/startRecording.png',
              width: 20,
              height: 20,
            ),
    );
  }
}
