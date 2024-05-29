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
import 'package:web_socket_channel/io.dart';
import 'package:archer_link/proto/archer_protocol.pb.dart';

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
  late IOWebSocketChannel _channel;
  bool _isConnected = false;
  HostDevStatus? devStatus;
  late Timer _timer;
  final Queue<Uint8List> _requestQueue = Queue<Uint8List>();

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isConnected && _requestQueue.length == 0) {
        getDevStatus();
      }
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    _timer.cancel(); // Cancel the timer when disposing the widget
    super.dispose();
  }

  Future<void> _connectToWebSocket() async {
    bool isCorrect = await isConnected(widget.commandUrl);
    if(isCorrect == false){
      return;
    }

    final wsUrl = Uri.parse('ws://${widget.commandUrl}');


    _channel = IOWebSocketChannel.connect(wsUrl);
    getDevStatus();
  



    _channel.stream.listen((event) {
      final commandResp = HostPayload.fromBuffer(event);

      _requestQueue.removeLast();

      if (_requestQueue.length != 0) {
        _channel.sink.add(_requestQueue.last);
      }

      if (commandResp.hasDevStatus()) {
        setState(() {
          devStatus = commandResp.devStatus;
        });
      }

      setState(() {
        _isConnected = true;
      });
    }, onError: (error) {

      print('onError ${error}');
      _requestQueue.clear();
      setState(() {
        _isConnected = false;
      });
    }, onDone: () {

      print('onDone');
      _requestQueue.clear();

      setState(() {
        _isConnected = false;
      });
    });
  }

  Future<void> getDevStatus() async {
    print('getDevStatus');
    GetHostDevStatus getHostDevStatus = GetHostDevStatus();
    Command command = Command(getHostDevStatus: getHostDevStatus);

    final clientPayload = ClientPayload()..command = command;
    final buffer = clientPayload.writeToBuffer();

    _sendToServer(buffer);
  }

  void _sendToServer(Uint8List buffer) {
    print('_sendToServer, ${buffer}');
    _requestQueue.addFirst(buffer);
    print('_requestQueue, ${_requestQueue}');

    if (_requestQueue.length == 1) {
      _channel.sink.add(buffer);
    }
  }

  @override
  Widget build(BuildContext context) {
        double topPadding = MediaQuery.of(context).padding.left > MediaQuery.of(context).padding.top ? MediaQuery.of(context).padding.left : MediaQuery.of(context).padding.top;

    if (devStatus != null && _isConnected) {
      
      return Padding(padding:  EdgeInsets.only(left: topPadding), child: Row(
        children: [
          SizedBox(
            width: 140,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MakePhotoButton(takePhoto: widget.takePhoto),
                  SizedBox(height: 10),
                  RecordButton(
                    isRecording: widget.isRecording,
                    onToggle: widget.onRecordingChanged,
                  ),
                ],
              ),
            ),
          ),
          Center(child: widget.child),
          SizedBox(
            width: 140,
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
                  CalibrationButton(_sendToServer)
                ],
              ),
            ),
          ),
        ],
      ),);
    } else {
      return Padding(padding: EdgeInsets.only(left: topPadding), child: Row(
        children: [
          SizedBox(
            width: 140,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MakePhotoButton(takePhoto: widget.takePhoto),
                  SizedBox(height: 10),
                  RecordButton(
                    isRecording: widget.isRecording,
                    onToggle: widget.onRecordingChanged,
                  ),
                ],
              ),
            ),
          ),
          Center(child: widget.child),
          SizedBox(
            width: 140,
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
                          'Unable to establish a WebSocket connection. Please check your command ws URL.',
                          style: TextStyle(
                          
                              color: Colors.white.withOpacity(0.45),
                              fontSize: 12,
                              decoration: TextDecoration.none),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),);
    }
  }
}
