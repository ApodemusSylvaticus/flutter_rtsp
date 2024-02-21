import 'package:flutter/material.dart';
import 'package:one_more_try/features/overlayButtons/calibrationButton.dart';
import 'package:one_more_try/features/overlayButtons/lightModeSelector.dart';
import 'package:one_more_try/features/overlayButtons/modeChangeButton.dart';
import 'package:one_more_try/features/overlayButtons/recordButton.dart';
import 'package:one_more_try/features/overlayButtons/zoomButton.dart';

class OverlayButtons extends StatelessWidget {
  final bool isRecording;
  final Function(bool) onRecordingChanged;

  const OverlayButtons({
    Key? key,
    required this.isRecording,
    required this.onRecordingChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        buildOverlayButton(Alignment.centerLeft, CalibrationButton(), ZoomButton()), // Заменяем 'Zoom' на экземпляр ZoomButton
        buildOverlayButton(Alignment.centerRight, ModeChangeButton(), LightModeSelector()),
        RecordButton(isRecording: isRecording, onToggle: onRecordingChanged),
      ],
    );
  }

  Widget buildOverlayButton(Alignment alignment, Widget button1, Widget button2) { // Изменим тип параметра на Widget
    return Align(
      alignment: alignment,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          button1,
          SizedBox(height: 20),
          button2, 
        ],
      ),
    );
  }
}






