import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'package:archer_link/helper/isConnected.dart';
import 'package:flutter/material.dart';
import 'package:archer_link/features/StreamViewButtons/calibrationButton.dart';
import 'package:archer_link/features/StreamViewButtons/lightModeSelector.dart';
import 'package:archer_link/features/StreamViewButtons/makePhotoButton.dart';
import 'package:archer_link/features/StreamViewButtons/modeChangeButton.dart';
import 'package:archer_link/features/StreamViewButtons/recordButton.dart';
import 'package:archer_link/features/StreamViewButtons/zoomButton.dart';
import 'package:archer_link/proto/archer_protocol.pb.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class StreamViewButtons extends StatefulWidget {
  final bool isRecording;
  final String commandUrl;
  final Function(bool) onRecordingChanged;
  final Widget child;
  final Function() takePhoto;

  const StreamViewButtons({
    required this.isRecording,
    required this.onRecordingChanged,
    required this.commandUrl,
    required this.child,
    required this.takePhoto,
  }) : super();

  @override
  _StreamViewButtonsState createState() => _StreamViewButtonsState();
}

class _StreamViewButtonsState extends State<StreamViewButtons> {
  WebSocketChannel? _channel;
  StreamSubscription? _channelSubscription;
  bool _isConnected = false;
  bool _isTryingToConnect = false;
  HostDevStatus? devStatus;
  Timer? _timer;
  Timer? _reconnectTimer;
  final Queue<Uint8List> _requestQueue = Queue<Uint8List>();

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isConnected && _requestQueue.isEmpty) {
        getDevStatus();
      }
    });

    _reconnectTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_isTryingToConnect && !_isConnected) {
        _connectToWebSocket();
      }
    });
  }

  @override
  void dispose() {
    // Сначала отменяем таймеры, чтобы они не вызывали методы
    _timer?.cancel();
    _reconnectTimer?.cancel();
    
    // Затем отменяем подписку на stream
    _channelSubscription?.cancel();
    
    // И только потом закрываем канал
    _channel?.sink.close();
    
    super.dispose();
  }

  Future<void> _connectToWebSocket() async {
    bool isCorrect = await isConnected(widget.commandUrl);

    if (!isCorrect) {
      return;
    }

    _isTryingToConnect = true;
    final wsUrl = Uri.parse('ws://${widget.commandUrl}');

    _channel = WebSocketChannel.connect(wsUrl);
    try {
      await _channel!.ready;
    } catch (e) {
      _isTryingToConnect = false;
      return;
    }

    // Отменяем предыдущую подписку если она была
    await _channelSubscription?.cancel();

    _channelSubscription = _channel!.stream.listen(
      (event) {
        final commandResp = HostPayload.fromBuffer(event);

        if (_requestQueue.isNotEmpty) {
          _requestQueue.removeLast();
        }

        if (_requestQueue.isNotEmpty) {
          _channel?.sink.add(_requestQueue.last);
        }

        if (commandResp.hasDevStatus()) {
          if (mounted) {
            setState(() {
              devStatus = commandResp.devStatus;
            });
          }
        }

        if (mounted) {
          setState(() {
            _isConnected = true;
          });
        }
        _isTryingToConnect = false;
      },
      onError: (error) {
        _requestQueue.clear();
        if (mounted) {
          setState(() {
            _isConnected = false;
          });
        }
        _isTryingToConnect = false;
      },
      onDone: () {
        _requestQueue.clear();
        if (mounted) {
          setState(() {
            _isConnected = false;
          });
        }
        _isTryingToConnect = false;
      },
      cancelOnError: true,
    );

    getDevStatus();
  }

  Future<void> getDevStatus() async {
    final getHostDevStatus = GetHostDevStatus();
    final command = Command(getHostDevStatus: getHostDevStatus);

    final clientPayload = ClientPayload()..command = command;
    final buffer = clientPayload.writeToBuffer();

    _sendToServer(buffer);
  }

  void _sendToServer(Uint8List buffer) {
    _requestQueue.addFirst(buffer);

    if (_requestQueue.length == 1) {
      _channel?.sink.add(buffer);
    }
  }

  @override
  Widget build(BuildContext context) {
    double topPadding =
        MediaQuery.of(context).padding.left > MediaQuery.of(context).padding.top
            ? MediaQuery.of(context).padding.left
            : MediaQuery.of(context).padding.top;

    if (devStatus != null && _isConnected) {
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
                    onToggle: widget.onRecordingChanged,
                  ),
                ],
              ),
            ),
            Center(child: widget.child),
            SizedBox(
              width: 120,
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LightModeSelector(_sendToServer, devStatus!),
                    SizedBox(height: 10),
                    ModeChangeButton(_sendToServer, devStatus!),
                    SizedBox(height: 10),
                    ZoomButton(_sendToServer, devStatus!),
                    SizedBox(height: 10),
                    CalibrationButton(_sendToServer),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
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
                  SizedBox(height: 40),
                  RecordButton(
                    isRecording: widget.isRecording,
                    onToggle: widget.onRecordingChanged,
                  ),
                ],
              ),
            ),
            Center(child: widget.child),
            SizedBox(
              width: 120,
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Unable to establish a WebSocket connection. Trying to connect...',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.45),
                              fontSize: 12,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
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
}