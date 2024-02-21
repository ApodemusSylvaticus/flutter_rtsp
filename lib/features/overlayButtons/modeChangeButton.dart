import 'package:flutter/material.dart';
import 'package:one_more_try/features/overlayButtons/style.dart';

class ModeChangeButton extends StatefulWidget {
  @override
  _ModeChangeButton createState() => _ModeChangeButton();
}

class _ModeChangeButton extends State<ModeChangeButton> {
  int _currentZoomIndex = 0;
  final List<int> _zoomValues = [1, 2, 3];

  void _changeZoom() {
    setState(() {
      _currentZoomIndex = (_currentZoomIndex + 1) % _zoomValues.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _changeZoom,
      style: CustomButtonStyle.menuButtonStyle,
      child: Text('Mode ${_zoomValues[_currentZoomIndex]}', style: CustomButtonStyle.buttonTextStyle),
    );
  }
}