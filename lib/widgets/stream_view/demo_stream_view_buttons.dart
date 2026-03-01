import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:archer_link/widgets/stream_view/calibration_button.dart';
import 'package:archer_link/widgets/stream_view/light_mode_selector.dart';
import 'package:archer_link/widgets/stream_view/make_photo_button.dart';
import 'package:archer_link/widgets/stream_view/mode_change_button.dart';
import 'package:archer_link/widgets/stream_view/record_button.dart';
import 'package:archer_link/widgets/stream_view/zoom_button.dart';
import 'package:archer_link/proto/archer_protocol.pb.dart';
import 'package:archer_link/services/mock_command_service.dart';

class DemoStreamViewButtons extends StatefulWidget {
  final bool isRecording;
  final bool isProcessing;
  final Function(bool) onRecordingChanged;
  final Widget child;
  final Function() takePhoto;
  final void Function(HostDevStatus) onDevStatusChanged;
  final VoidCallback? onCalibrationTriggered;
  final bool isCalibrating;

  const DemoStreamViewButtons({
    required this.isRecording,
    required this.onRecordingChanged,
    required this.child,
    required this.takePhoto,
    required this.onDevStatusChanged,
    this.onCalibrationTriggered,
    this.isCalibrating = false,
    this.isProcessing = false,
  }) : super();

  @override
  _DemoStreamViewButtonsState createState() => _DemoStreamViewButtonsState();
}

class _DemoStreamViewButtonsState extends State<DemoStreamViewButtons> {
  late final MockCommandService _mockService;
  late HostDevStatus devStatus;

  @override
  void initState() {
    super.initState();
    _mockService = MockCommandService();
    devStatus = _mockService.currentDevStatus;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onDevStatusChanged(devStatus);
      }
    });
  }

  void _sendCommand(Uint8List buffer) {
    final responseBytes = _mockService.processCommand(buffer);
    final commandResp = HostPayload.fromBuffer(responseBytes);
    if (commandResp.hasDevStatus() && mounted) {
      setState(() {
        devStatus = commandResp.devStatus;
      });
      widget.onDevStatusChanged(devStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    double topPadding =
        MediaQuery.of(context).padding.left > MediaQuery.of(context).padding.top
            ? MediaQuery.of(context).padding.left
            : MediaQuery.of(context).padding.top;

    return Padding(
      padding: EdgeInsets.only(left: topPadding),
      child: Row(
        children: [
          Container(
            width: 60,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MakePhotoButton(takePhoto: widget.takePhoto),
                SizedBox(height: 30),
                RecordButton(
                  isRecording: widget.isRecording,
                  isProcessing: widget.isProcessing,
                  onToggle: widget.onRecordingChanged,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: widget.child,
            ),
          ),
          SizedBox(
            width: 120,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LightModeSelector(_sendCommand, devStatus),
                  SizedBox(height: 10),
                  ModeChangeButton(_sendCommand, devStatus),
                  SizedBox(height: 10),
                  ZoomButton(_sendCommand, devStatus),
                  SizedBox(height: 10),
                  IgnorePointer(
                    ignoring: widget.isCalibrating,
                    child: Opacity(
                      opacity: widget.isCalibrating ? 0.4 : 1.0,
                      child: CalibrationButton((buffer) {
                        _sendCommand(buffer);
                        widget.onCalibrationTriggered?.call();
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
