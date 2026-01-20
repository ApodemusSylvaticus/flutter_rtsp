import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter/services.dart';
import 'package:archer_link/models/tcpAddress.dart';
import 'package:archer_link/main.dart';

/// Callback for UI state change notifications
typedef OnStreamStateChanged = void Function({
  bool? isLoading,
  bool? showReconnectButton,
  bool? isReconnecting,
});

/// RTSP player and stream monitoring service
class StreamPlayerService {
  late final Player player;
  late final VideoController videoController;

  final StreamConfig streamConfig;
  final OnStreamStateChanged onStateChanged;

  StreamSubscription<bool>? _playingSubscription;
  StreamSubscription<bool>? _bufferingSubscription;
  StreamSubscription<Duration>? _positionSubscription;

  Timer? _bufferTimeout;
  Timer? _positionWatchdog;
  Duration _lastPosition = Duration.zero;
  int _stalledCount = 0;

  bool _isDisposed = false;
  bool _tcpResponseReceived = false;

  StreamPlayerService({
    required this.streamConfig,
    required this.onStateChanged,
  }) {
    player = Player(
      configuration: const PlayerConfiguration(
        bufferSize: 32 * 1024,
        logLevel: MPVLogLevel.warn,
      ),
    );

    videoController = VideoController(
      player,
      configuration: const VideoControllerConfiguration(
        enableHardwareAcceleration: true,
      ),
    );
  }

  /// Initialize service
  Future<void> initialize() async {
    _setupStreamMonitoring();
    await _configureLowLatency();
    await initializeDeviceConnection();
  }

  Future<void> _configureLowLatency() async {
    final nativePlayer = player.platform as NativePlayer;

    await nativePlayer.setProperty('cache', 'no');
    await nativePlayer.setProperty(
        'demuxer-lavf-o', 'rtsp_transport=tcp,fflags=nobuffer');
    await nativePlayer.setProperty('demuxer-lavf-analyzeduration', '0');
    await nativePlayer.setProperty('demuxer-lavf-probesize', '32');
    await nativePlayer.setProperty('untimed', 'yes');
    await nativePlayer.setProperty('hwdec', 'mediacodec');
  }

  void _setupStreamMonitoring() {
    _bufferingSubscription = player.stream.buffering.listen((isBuffering) {
      _bufferTimeout?.cancel();

      if (isBuffering) {
        _bufferTimeout = Timer(const Duration(seconds: 10), _onStreamLost);
      }
    });

    _playingSubscription = player.stream.playing.listen((playing) {
      _positionWatchdog?.cancel();

      if (playing) {
        onStateChanged(
          isLoading: false,
          showReconnectButton: false,
        );
        _startPositionWatchdog();
      }
    });

    _positionSubscription = player.stream.position.listen((pos) {
      if (pos != _lastPosition) {
        _lastPosition = pos;
        _stalledCount = 0;
      }
    });
  }

  void _startPositionWatchdog() {
    _stalledCount = 0;
    _positionWatchdog = Timer.periodic(const Duration(seconds: 2), (_) {
      _stalledCount++;

      if (_stalledCount >= 5) {
        _onStreamLost();
      }
    });
  }

  void _onStreamLost() {
    _bufferTimeout?.cancel();
    _positionWatchdog?.cancel();

    onStateChanged(
      showReconnectButton: true,
      isLoading: false,
    );
  }

  void _resetMonitoring() {
    _bufferTimeout?.cancel();
    _positionWatchdog?.cancel();
    _stalledCount = 0;
    _lastPosition = Duration.zero;
  }

  /// Initialize device connection
  Future<void> initializeDeviceConnection() async {
    if (_isDisposed) return;

    onStateChanged(
      isReconnecting: true,
      isLoading: true,
    );

    _resetMonitoring();

    try {
      if (streamConfig.shouldRunStreamView) {
        final address = TcpAddress.parse(streamConfig.tcpCommandUrl);
        final port = int.parse(address.port!);

        final socket = await Socket.connect(address.ip, port);
        socket.writeln('CMD_RTSP_TRANS_START');
        await socket.flush();

        Completer<String> completer = Completer<String>();
        StreamSubscription<List<int>>? subscription;

        subscription = socket.listen((data) {
          String response = utf8.decode(data);
          _tcpResponseReceived = true;
          if (!completer.isCompleted) {
            completer.complete(response);
          }
        }, onError: (error) {
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        }, onDone: () {});

        // Timeout: 5s if response was received, 30s otherwise
        final timeoutDuration = _tcpResponseReceived
            ? const Duration(seconds: 5)
            : const Duration(seconds: 30);

        try {
          await completer.future.timeout(
            timeoutDuration,
            onTimeout: () {
              throw TimeoutException('TCP response timeout');
            },
          );
          await Future.delayed(const Duration(milliseconds: 500));
          await _initializePlayer();
        } on TimeoutException {
          await subscription.cancel();
          try {
            socket.destroy();
          } catch (_) {}
          await _initializePlayer();
        } catch (e) {
          await subscription.cancel();
          try {
            socket.destroy();
          } catch (_) {}
          await _initializePlayer();
        }
      } else {
        await _initializePlayer();
      }
    } catch (e) {
      onStateChanged(
        showReconnectButton: true,
        isLoading: false,
      );
    } finally {
      onStateChanged(isReconnecting: false);
    }
  }

  Future<void> _initializePlayer() async {
    if (_isDisposed) return;

    try {
      await player.stop();
      await player.setVolume(0);

      final nativePlayer = player.platform as NativePlayer;

      await nativePlayer.setProperty('cache', 'no');
      await nativePlayer.setProperty('cache-pause', 'no');
      await nativePlayer.setProperty('demuxer-lavf-o',
          'rtsp_transport=tcp,analyzeduration=100000,probesize=32000,fflags=nobuffer');
      await nativePlayer.setProperty('untimed', 'yes');
      await nativePlayer.setProperty('profile', 'low-latency');
      await nativePlayer.setProperty('framedrop', 'vo');
      await nativePlayer.setProperty('audio', 'no');

      _resetMonitoring();

      final rtspUrl = 'rtsp://${streamConfig.streamUrl}';
      await player.open(
        Media(rtspUrl),
        play: true,
      );

      WakelockPlus.enable();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

      onStateChanged(showReconnectButton: false);
    } catch (e) {
      onStateChanged(
        showReconnectButton: true,
        isLoading: false,
      );
    } finally {
      onStateChanged(isReconnecting: false);
    }
  }

  /// Pause player
  void pause() {
    player.pause();
  }

  /// Reconnect after returning from background
  Future<void> reconnectAfterResume() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (_isDisposed) return;

    final isPlaying = player.state.playing;

    if (!isPlaying) {
      await initializeDeviceConnection();
    }
  }

  /// Release resources
  void dispose() {
    _isDisposed = true;

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    _bufferTimeout?.cancel();
    _positionWatchdog?.cancel();
    _playingSubscription?.cancel();
    _bufferingSubscription?.cancel();
    _positionSubscription?.cancel();

    player.dispose();
    WakelockPlus.disable();
  }
}
