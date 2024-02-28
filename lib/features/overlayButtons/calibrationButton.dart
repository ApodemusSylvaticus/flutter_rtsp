import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:one_more_try/features/overlayButtons/style.dart';
import 'package:one_more_try/proto/demo_protocol.pb.dart';

class CalibrationButton extends StatefulWidget {
    final void Function(Uint8List buffer) sendToServer;

  CalibrationButton(this.sendToServer);

  @override
  _CalibrationButtonState createState() => _CalibrationButtonState();
}

class _CalibrationButtonState extends State<CalibrationButton> {

  void _onPress() {
    TriggerCmd triggerCmd = TriggerCmd(cmd: CMDDirect.TRIGGER_FFC);

    Command command = Command(cmdTrigger: triggerCmd);


    ClientPayload clientPayload = ClientPayload(command: command);

    final buffer = clientPayload.writeToBuffer();
    widget.sendToServer(buffer);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _onPress,
      style: CustomButtonStyle.menuButtonStyle,
      child:  Text('Calibration', style: CustomButtonStyle.buttonTextStyle,),
    );
  }
}