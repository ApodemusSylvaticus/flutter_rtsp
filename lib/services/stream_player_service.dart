import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter/services.dart';
import 'package:archer_link/models/tcp_address.dart';
import 'package:archer_link/models/stream_config.dart';

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
  StreamSubscription<int?>? _widthSubscription;
  StreamSubscription<String>? _errorSubscription;

  Timer? _bufferTimeout;
  Timer? _positionWatchdog;
  Duration _lastPosition = Duration.zero;
  int _stalledCount = 0;

  bool _isDisposed = false;
  bool _tcpResponseReceived = false;

  /// True between `player.open()` and the first decoded frame (or a failure).
  /// media_kit reports `playing == true` optimistically right inside `open()`,
  /// before any network I/O, so `playing` cannot be used as "stream is up".
  bool _connecting = false;

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
      if (!playing) {
        _positionWatchdog?.cancel();
      }
    });

    // First decoded frame: mpv publishes `video-params`, media_kit turns it
    // into a non-null width. This is the real "stream is up" signal.
    _widthSubscription = player.stream.width.listen((width) {
      if (_connecting && width != null && width > 0) {
        _onStreamAlive();
      }
    });

    // mpv reports open failures (e.g. "tcp: ... Connection refused") within
    // milliseconds; without this we would wait for the 10s buffer timeout.
    // Only acted upon while connecting: decoder errors during playback are
    // handled by the buffer/position watchdogs instead.
    _errorSubscription = player.stream.error.listen((error) {
      if (_connecting) {
        _onStreamLost();
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

  void _onStreamAlive() {
    _connecting = false;
    _positionWatchdog?.cancel();
    _startPositionWatchdog();

    WakelockPlus.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    onStateChanged(
      isLoading: false,
      showReconnectButton: false,
    );
  }

  void _onStreamLost() {
    _connecting = false;
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
      // Set right before open(): stop() above emits its own (stale)
      // width/playing events which must not be taken for this attempt.
      _connecting = true;
      await player.open(
        Media(rtspUrl),
        play: true,
      );
      // The UI stays on the loader (isLoading == true) until _onStreamAlive()
      // or _onStreamLost() fires from the stream subscriptions.
    } catch (e) {
      _connecting = false;
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
    if (_isDisposed) return;
    try {
      player.pause();
    } catch (_) {}
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
  Future<void> dispose() async {
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
    _widthSubscription?.cancel();
    _errorSubscription?.cancel();

    try {
      await player.stop();
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 100));
    player.dispose();
    WakelockPlus.disable();
  }
}
