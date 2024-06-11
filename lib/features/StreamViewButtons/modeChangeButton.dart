import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:archer_link/features/StreamViewButtons/customButton.dart';
import 'package:archer_link/proto/archer_protocol.pb.dart';


class ModeChangeButton extends StatefulWidget {
  final void Function(Uint8List buffer) sendToServer;
  final HostDevStatus devStatus;

  ModeChangeButton(this.sendToServer, this.devStatus);

  @override
  _ModeChangeButtonState createState() => _ModeChangeButtonState();
}

class _ModeChangeButtonState extends State<ModeChangeButton> {
  late int _currentModeIndex;
  final List<AGCMode> modeList = [
    AGCMode.AUTO_1,
    AGCMode.AUTO_2,
    AGCMode.AUTO_3
  ];

  @override
  void initState() {
    super.initState();
    _initializeMode();
  }

  @override
  void didUpdateWidget(covariant ModeChangeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.devStatus.modAGC != oldWidget.devStatus.modAGC) {
      setState(() {
        _initializeMode();
      });
    }
  }

  void _initializeMode() {
    if (widget.devStatus.modAGC == AGCMode.UNKNOWN_AGC_MODE) {
      throw ArgumentError('Unknown modAGC: ${widget.devStatus.modAGC}');
    }
    _currentModeIndex = modeList.indexOf(widget.devStatus.modAGC);
  }

  void _changeMode() {
    setState(() {
      _currentModeIndex = (_currentModeIndex + 1) % modeList.length;
    });
    sendCommand(modeList[_currentModeIndex]);
  }

  void sendCommand(AGCMode agcMode) {
    final setAgc = SetAgcMode()..mode = agcMode;
    final command = Command()..setAgc = setAgc;
    final clientPayload = ClientPayload()..command = command;
    final buffer = clientPayload.writeToBuffer();
    widget.sendToServer(buffer);
  }

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      onClick: _changeMode,
      text: 'AGC Mode',
      additionalData: Image.asset(
        'assets/actionButtonIcon/agsMode.png',
        width: 20,
        height: 20,
      ),
    );
  }
}
