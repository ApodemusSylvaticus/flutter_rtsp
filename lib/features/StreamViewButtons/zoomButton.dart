import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:archer_link/features/StreamViewButtons/customButton.dart';
import 'package:archer_link/proto/archer_protocol.pb.dart';


class ZoomButton extends StatefulWidget {
  final void Function(Uint8List buffer) sendToServer;
  final HostDevStatus devStatus;
  ZoomButton(this.sendToServer, this.devStatus);


  @override
  _ZoomButtonState createState() => _ZoomButtonState();
}

class _ZoomButtonState extends State<ZoomButton> {
  late int _currentZoomIndex;
  late List<Zoom> _zoomValues;

  @override
  void initState() {
    super.initState();
    _initializeZoomValues();
    _currentZoomIndex = _getValidZoomIndex(widget.devStatus.zoom);
  }

  @override
  void didUpdateWidget(covariant ZoomButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Ignore UNKNOWN_ZOOM_LEVEL — don't change state
    if (widget.devStatus.zoom == Zoom.UNKNOWN_ZOOM_LEVEL) {
      debugPrint('[ZOOM] didUpdateWidget: IGNORED - UNKNOWN_ZOOM_LEVEL');
      return;
    }
    
    // maxZoom changed — reinitialize the list
    if (widget.devStatus.maxZoom != oldWidget.devStatus.maxZoom) {
      setState(() {
        _initializeZoomValues();
        _currentZoomIndex = _getValidZoomIndex(widget.devStatus.zoom);
      });
      return;
    }
    
    // zoom changed — update index
    if (widget.devStatus.zoom != oldWidget.devStatus.zoom) {
      setState(() {
        _currentZoomIndex = _getValidZoomIndex(widget.devStatus.zoom);
      });
    }
  }

  /// Returns index for zoom, or current index if zoom is invalid
  int _getValidZoomIndex(Zoom zoom) {
    if (zoom == Zoom.UNKNOWN_ZOOM_LEVEL) {
      return _currentZoomIndex;
    }
    return convertZoomToIndex(zoom);
  }

  void _initializeZoomValues() {
    switch (widget.devStatus.maxZoom) {
      case Zoom.ZOOM_X1: 
        _zoomValues = [Zoom.ZOOM_X1];
        break;
      case Zoom.ZOOM_X2:
        _zoomValues = [Zoom.ZOOM_X1, Zoom.ZOOM_X2];
        break;
      case Zoom.ZOOM_X3:
        _zoomValues = [Zoom.ZOOM_X1, Zoom.ZOOM_X2, Zoom.ZOOM_X3];
        break;
      case Zoom.ZOOM_X4:
        _zoomValues = [Zoom.ZOOM_X1, Zoom.ZOOM_X2, Zoom.ZOOM_X3, Zoom.ZOOM_X4];
        break;
      case Zoom.ZOOM_X6:
        _zoomValues = [Zoom.ZOOM_X1, Zoom.ZOOM_X2, Zoom.ZOOM_X3, Zoom.ZOOM_X4, Zoom.ZOOM_X6];
        break;
      default:
        _zoomValues = [Zoom.ZOOM_X1, Zoom.ZOOM_X2, Zoom.ZOOM_X3, Zoom.ZOOM_X4, Zoom.ZOOM_X6];
        break;
    }
  }

  void _changeZoom() {
    setState(() {
      _currentZoomIndex = (_currentZoomIndex + 1) % _zoomValues.length;
    });
    sendZoomCommand(_zoomValues[_currentZoomIndex]);
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
      default:
        return 0;
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