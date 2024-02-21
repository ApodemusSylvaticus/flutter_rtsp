import 'package:flutter/material.dart';
import 'package:one_more_try/features/overlayButtons/style.dart';

class ZoomButton extends StatefulWidget {
  @override
  _ZoomButtonState createState() => _ZoomButtonState();
}

class _ZoomButtonState extends State<ZoomButton> {
  int _currentZoomIndex = 0;
  final List<int> _zoomValues = [1, 2, 3, 4, 6];

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
      child: Text('Zoom ${_zoomValues[_currentZoomIndex]}', style: CustomButtonStyle.buttonTextStyle),
    );
  }
}
