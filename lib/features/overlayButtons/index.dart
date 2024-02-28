import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:one_more_try/features/overlayButtons/calibrationButton.dart';
import 'package:one_more_try/features/overlayButtons/lightModeSelector.dart';
import 'package:one_more_try/features/overlayButtons/modeChangeButton.dart';
import 'package:one_more_try/features/overlayButtons/recordButton.dart';
import 'package:one_more_try/features/overlayButtons/zoomButton.dart';
import 'package:web_socket_channel/io.dart';
import 'package:one_more_try/proto/demo_protocol.pb.dart';

class OverlayButtons extends StatefulWidget {
  final bool isRecording;
  final String commandUrl;

  final Function(bool) onRecordingChanged;

  const OverlayButtons({
    Key? key,
    required this.isRecording,
    required this.onRecordingChanged,
    required this.commandUrl,
  }) : super(key: key);

  @override
  _OverlayButtonsState createState() => _OverlayButtonsState();
}

class _OverlayButtonsState extends State<OverlayButtons> {
  late IOWebSocketChannel _channel;
  bool _isConnected = false;
  HostDevStatus? devStatus;

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  Future<void> _connectToWebSocket() async {
    final wsUrl = Uri.parse('ws://${widget.commandUrl}');
    _channel = IOWebSocketChannel.connect(wsUrl);
    getDevStatus();

    _channel.stream.listen((event) {
      print('resp $event');

      final commandResp = HostPayload.fromBuffer(event);
      print('resp $commandResp');

      if (commandResp.hasDevStatus()) {
        print('resp $commandResp');

        setState(() {
          _isConnected = true;
          devStatus = commandResp.devStatus;
        });
      }

      setState(() {});
    }, onError: (error) {
      setState(() {
        _isConnected = false;
      });
    }, onDone: () {
      setState(() {
        _isConnected = false;
      });
    });
  }

  Future<void> getDevStatus() async {
    GetHostDevStatus getHostDevStatus = GetHostDevStatus();
    Command command = Command(getHostDevStatus: getHostDevStatus);

    final clientPayload = ClientPayload()..command = command;
    final buffer = clientPayload.writeToBuffer();

    _sendToServer(buffer);
  }

  void _sendToServer(Uint8List buffer) {
    _channel.sink.add(buffer);
  }

  Widget buildOverlayButton(
      Alignment alignment, Widget button1, Widget button2) {
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

  @override
  Widget build(BuildContext context) {
    if (devStatus != null) {
      return Stack(
        children: [
          buildOverlayButton(
              Alignment.centerLeft,
              CalibrationButton(_sendToServer),
              ZoomButton(_sendToServer, devStatus!)),
          buildOverlayButton(
              Alignment.centerRight,
              ModeChangeButton(_sendToServer, devStatus!),
              LightModeSelector(_sendToServer, devStatus!)),
          RecordButton(
              isRecording: widget.isRecording,
              onToggle: widget.onRecordingChanged),
        ],
      );
    } else {
      return Center(
        child: Text(
          'Unable to establish a WebSocket connection. Please check your network connection.',
          textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 14, ),
        ),
      );
    }
  }
}
