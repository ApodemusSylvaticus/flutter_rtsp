import 'package:flutter/material.dart';
import 'package:archer_link/widgets/stream_view/custom_button.dart';


class RecordButton extends StatelessWidget {
  final bool isRecording;
  final bool isProcessing;
  final Function(bool) onToggle;

  const RecordButton({
    Key? key,
    required this.isRecording,
    required this.onToggle,
    this.isProcessing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isProcessing ? 0.4 : 1.0,
      child: CustomSmallButton(
        onClick: isProcessing ? () {} : () => {onToggle(!isRecording)},
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
      ),
    );
  }
}
