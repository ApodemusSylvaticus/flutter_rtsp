import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:one_more_try/features/StreamViewButtons/customButton.dart';
import 'package:one_more_try/proto/demo_protocol.pb.dart';

class ZoomButton extends StatefulWidget {
  final void Function(Uint8List buffer) sendToServer;
  final HostDevStatus devStatus;
  ZoomButton(this.sendToServer, this.devStatus);

  @override
  _ZoomButtonState createState() => _ZoomButtonState();
}

class _ZoomButtonState extends State<ZoomButton> {
  late int _currentZoomIndex;
  final List<Zoom> _zoomValues = [Zoom.ZOOM_X1, Zoom.ZOOM_X2, Zoom.ZOOM_X3, Zoom.ZOOM_X4, Zoom.ZOOM_X6];

  void _changeZoom() {
    setState(() {
      _currentZoomIndex = (_currentZoomIndex + 1) % _zoomValues.length;
    });
    sendZoomCommand(_zoomValues[_currentZoomIndex]);
  }

  @override
  void initState() {
    super.initState();
    _currentZoomIndex = convertZoomToIndex(widget.devStatus.zoom);
  }

  int convertZoomToIndex(Zoom zoom) {
    switch (zoom) {
      case Zoom.ZOOM_X1:
        return 0;
      case Zoom.ZOOM_X2:
        return 1;
      case Zoom.ZOOM_X3:
        return 2;
      case Zoom.ZOOM_X4:
        return 3;
      case Zoom.ZOOM_X6:
        return 4;
      case Zoom.UNKNOWN_ZOOM_LEVEL:
        throw ArgumentError('Unknown zoom level: $zoom');
      default:
        throw ArgumentError('Unexpected zoom level: $zoom');
    }
  }

 

  void sendZoomCommand(Zoom zoom) {
    final setZoom = SetZoomLevel()..zoomLevel = zoom;

    
    final command = Command()..setZoom = setZoom;

    final clientPayload = ClientPayload()..command = command;

    final buffer = clientPayload.writeToBuffer();
    widget.sendToServer(buffer);
  }

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      onClick: _changeZoom,
      text: 'Zoom',
           additionalData: Image.asset('assets/actionButtonIcon/zoom.png', width: 20, height: 20,),

    );
  }
}
