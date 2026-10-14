import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'package:archer_link/utils/connectivity_checker.dart';
import 'package:archer_link/utils/trace.dart';
import 'package:flutter/material.dart';
import 'package:archer_link/widgets/stream_view/calibration_button.dart';
import 'package:archer_link/widgets/stream_view/light_mode_selector.dart';
import 'package:archer_link/widgets/stream_view/make_photo_button.dart';
import 'package:archer_link/widgets/stream_view/mode_change_button.dart';
import 'package:archer_link/widgets/stream_view/record_button.dart';
import 'package:archer_link/widgets/stream_view/zoom_button.dart';
import 'package:archer_link/proto/archer_protocol.pb.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class StreamViewButtons extends StatefulWidget {
  final bool isRecording;
  final bool isProcessing;
  final String commandUrl;
  final Function(bool) onRecordingChanged;
  final Widget child;
  final Function() takePhoto;

  /// Do not open the WebSocket before this moment (see main.dart). Null =
  /// connect at once.
  final DateTime? controlsHoldUntil;

  const StreamViewButtons({
    required this.isRecording,
    required this.onRecordingChanged,
    required this.commandUrl,
    required this.child,
    required this.takePhoto,
    this.isProcessing = false,
    this.controlsHoldUntil,
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
  Timer? _holdTimer;
  final Queue<Uint8List> _requestQueue = Queue<Uint8List>();

  /// Delays between reconnect attempts in seconds; the last one repeats.
  /// After the phone's address drops, the imager keeps the dead session and
  /// refuses a new one for ~60 s whatever the app does: measured on
  /// 2026-10-13 with 1 s knocking (accepted 59 s after the drop) and with a
  /// 1/2/3/5/8/10 s schedule (accepted 70 s after the drop, the first try
  /// after the imager let go). So knock every second: it costs nothing and
  /// picks up the connection within a second of the imager freeing it.
  static const List<int> _reconnectDelays = [1];
  int _reconnectAttempt = 0;
  DateTime? _lostAt;

  /// A connection that stopped answering is treated as dead after this
  /// long. Without it a half-open socket (phone walked out of range, Wi-Fi
  /// blinked without the address changing, phone slept) never raises an
  /// error: `_isConnected` stays true, the unanswered status request sits
  /// in the queue, no further requests go out and nothing ever reconnects.
  /// The imager answers a status request within ~100 ms, so 5 s is five
  /// missed answers in a row.
  static const Duration _replyTimeout = Duration(seconds: 5);
  DateTime? _lastMessageAt;

  @override
  void initState() {
    super.initState();

    final holdUntil = widget.controlsHoldUntil;
    final hold = holdUntil?.difference(DateTime.now());
    if (hold != null && hold > Duration.zero) {
      trace('WS', 'holding the first connect for ${hold.inMilliseconds} ms');
      _holdTimer = Timer(hold, () {
        if (!mounted) return;
        trace('WS', 'hold over: connecting');
        _connectToWebSocket();
      });
    } else {
      _connectToWebSocket();
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      // Also while trying: a handshake that succeeded but whose first
      // request is never answered must be dropped too, or the retry chain
      // would stall with _isTryingToConnect stuck at true.
      if (!_isConnected && !_isTryingToConnect) return;
      final lastMessageAt = _lastMessageAt;
      if (lastMessageAt != null) {
        final silence = DateTime.now().difference(lastMessageAt);
        if (silence > _replyTimeout) {
          _dropSilentConnection(silence);
          return;
        }
      }
      if (_isConnected && _requestQueue.isEmpty) {
        getDevStatus();
      }
    });
  }

  /// The imager has not answered for [_replyTimeout]: close the socket on
  /// our side (if the link is back, the FIN lets the imager free its
  /// session at once) and start reconnecting.
  void _dropSilentConnection(Duration silence) {
    trace('WS', 'no reply for ${silence.inMilliseconds} ms: dropping the '
        'socket and reconnecting');
    _channelSubscription?.cancel();
    _channelSubscription = null;
    _channel?.sink.close();
    _channel = null;
    _requestQueue.clear();
    _lastMessageAt = null;
    if (mounted) {
      setState(() {
        _isConnected = false;
      });
    } else {
      _isConnected = false;
    }
    _isTryingToConnect = false;
    _scheduleReconnect();
  }

  /// One-shot retry according to [_reconnectDelays]; rescheduled by each
  /// failure, reset by the first message of a working connection.
  void _scheduleReconnect() {
    if (!mounted || _isConnected || _isTryingToConnect) return;
    _lostAt ??= DateTime.now();
    final delay = _reconnectDelays[
        _reconnectAttempt < _reconnectDelays.length
            ? _reconnectAttempt
            : _reconnectDelays.length - 1];
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: delay), () {
      if (!mounted || _isConnected || _isTryingToConnect) return;
      _reconnectAttempt++;
      trace('WS', 'retry #$_reconnectAttempt after $delay s, '
          '${DateTime.now().difference(_lostAt!).inMilliseconds} ms since the loss');
      _connectToWebSocket();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _reconnectTimer?.cancel();
    _holdTimer?.cancel();
    _channelSubscription?.cancel();
    _channel?.sink.close();
    super.dispose();
  }

  Future<void> _connectToWebSocket() async {
    // No silence clock while the socket is being connected: the watchdog
    // starts counting from the handshake (set below) or the first message.
    _lastMessageAt = null;
    print('[WS] _connectToWebSocket() called, url=${widget.commandUrl}');
    bool isCorrect = await isConnected(widget.commandUrl);
    // The home page recreates this widget on connectivity events; a connect
    // that outlives its widget would open a socket nobody closes, and the
    // imager serves one command session only.
    if (!mounted) return;

    if (!isCorrect) {
      print('[WS] isConnected() returned false — aborting connection');
      _scheduleReconnect();
      return;
    }

    _isTryingToConnect = true;
    final wsUrl = Uri.parse('ws://${widget.commandUrl}');
    print('[WS] Connecting to $wsUrl ...');

    _channel = WebSocketChannel.connect(wsUrl);
    try {
      await _channel!.ready;
      print('[WS] Channel ready — connection established');
    } catch (e) {
      trace('WS', 'channel ready FAILED: $e');
      _isTryingToConnect = false;
      _scheduleReconnect();
      return;
    }
    if (!mounted) {
      // dispose() already closed this channel's sink; do not listen or send.
      _channel?.sink.close();
      return;
    }

    await _channelSubscription?.cancel();

    _channelSubscription = _channel!.stream.listen(
      (event) {
        _lastMessageAt = DateTime.now();
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
            if (!_isConnected) {
              trace('WS', 'connected: first message received'
                  '${_lostAt == null ? '' : ', ${DateTime.now().difference(_lostAt!).inMilliseconds} ms after the loss, attempt #$_reconnectAttempt'}');
              _reconnectAttempt = 0;
              _lostAt = null;
            }
            _isConnected = true;
          });
        }
        _isTryingToConnect = false;
      },
      onError: (error) {
        trace('WS', 'onError: $error');
        _requestQueue.clear();
        if (mounted) {
          setState(() {
            _isConnected = false;
          });
        }
        _isTryingToConnect = false;
        _scheduleReconnect();
      },
      onDone: () {
        trace('WS', 'onDone: connection closed (closeCode=${_channel?.closeCode}, closeReason=${_channel?.closeReason})');
        _requestQueue.clear();
        if (mounted) {
          setState(() {
            _isConnected = false;
          });
        }
        _isTryingToConnect = false;
        _scheduleReconnect();
      },
      cancelOnError: true,
    );

    // From here the imager owes us an answer within _replyTimeout.
    _lastMessageAt = DateTime.now();
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
    if (_channel == null) {
      print('[WS] _sendToServer: channel is null, dropping message');
      return;
    }
    if (!_isConnected) {
      print('[WS] _sendToServer: not connected, queuing message (queue=${_requestQueue.length})');
    }
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
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white54,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Connecting to device controls...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
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
