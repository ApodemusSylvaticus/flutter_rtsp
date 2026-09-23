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

/// Connection diagnostics: attempts, acks, stalls and restarts. Off by default,
/// turn on with `--dart-define=CONN_DIAG=true` when a reconnect misbehaves.
const bool _connDiag = bool.fromEnvironment('CONN_DIAG');

/// mpv's own verbose log. Off by default, it drowns out everything else.
/// Turn on with `--dart-define=MPV_DIAG=true` when a stream fails silently.
const bool _mpvDiag = bool.fromEnvironment('MPV_DIAG');

/// The only command the device understands. There is no matching "stop":
/// dropping this connection is what makes it stop transmitting.
const String _startCommand = 'CMD_RTSP_TRANS_START';

/// One deadline for a whole attempt: socket, command, ack, player and the
/// first frame. Whatever went wrong, the user gets the Reconnect button
/// instead of an endless loader.
const Duration _attemptTimeout = Duration(seconds: 15);

/// Frames were arriving and stopped: restart the stream.
const Duration _stallTimeout = Duration(seconds: 3);

/// Both have to fit inside [_attemptTimeout].
const Duration _connectTimeout = Duration(seconds: 4);
const Duration _ackTimeout = Duration(seconds: 5);

/// Time for the device to notice that the command connection is gone, before
/// it is asked to start transmitting again.
const Duration _deviceSettleDelay = Duration(seconds: 1);

/// How long a stream has to stay healthy before it earns another automatic
/// restart. Without this, a stream that dies right after every restart would
/// loop forever.
const Duration _autoRestartCooldown = Duration(seconds: 10);

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
  StreamSubscription<PlayerLog>? _logSubscription;

  Socket? _commandSocket;
  StreamSubscription<List<int>>? _commandSubscription;

  Timer? _attemptDeadline;
  Timer? _stallWatchdog;
  int _watchdogTicks = 0;

  Duration _lastPosition = Duration.zero;
  DateTime? _lastFrameAt;
  DateTime? _aliveSince;

  bool _isDisposed = false;
  bool _isHidden = false;
  bool _streamAlive = false;
  bool _autoRestartUsed = false;

  /// Guards against two attempts at once: the device serves a single command
  /// session, and a second one would leave both unanswered.
  bool _attemptInProgress = false;

  /// Invalidates an attempt that is still awaiting something when its deadline
  /// has already fired.
  int _attemptId = 0;

  /// True between `player.open()` and the first decoded frame.
  /// media_kit reports `playing == true` optimistically right inside `open()`,
  /// before any network I/O, so `playing` cannot be used as "stream is up".
  bool _connecting = false;

  StreamPlayerService({
    required this.streamConfig,
    required this.onStateChanged,
  }) {
    player = Player(
      configuration: PlayerConfiguration(
        bufferSize: 32 * 1024,
        logLevel: _mpvDiag ? MPVLogLevel.v : MPVLogLevel.error,
      ),
    );

    videoController = VideoController(
      player,
      configuration: const VideoControllerConfiguration(
        enableHardwareAcceleration: true,
      ),
    );
  }

  void _log(String message) {
    if (_connDiag) print('[CONN] $message');
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
    if (_mpvDiag) {
      _logSubscription = player.stream.log.listen((log) {
        print('[MPV] ${log.level} ${log.prefix}: ${log.text.trim()}');
      });
    }

    _bufferingSubscription = player.stream.buffering.listen((isBuffering) {
      _log('buffering=$isBuffering');
    });

    _playingSubscription = player.stream.playing.listen((playing) {
      _log('playing=$playing');
    });

    // First decoded frame: mpv publishes `video-params`, media_kit turns it
    // into a non-null width. This is the real "stream is up" signal.
    _widthSubscription = player.stream.width.listen((width) {
      if (_connecting && width != null && width > 0) {
        _onStreamAlive();
      }
    });

    // Logged only, never acted upon. mpv reports a failed hardware decoder
    // here and then plays the stream perfectly well through the software one,
    // so an error is not a verdict - the attempt deadline is. It also emits
    // noise like "Cannot seek in this stream" on every live stream.
    _errorSubscription = player.stream.error.listen((error) {
      _log('player error (not fatal): $error');
    });

    // The liveness signal: position moves while frames are being decoded and
    // freezes the moment they stop.
    _positionSubscription = player.stream.position.listen((pos) {
      if (pos != _lastPosition) {
        _lastPosition = pos;
        _lastFrameAt = DateTime.now();
      }
    });
  }

  /// Initialize device connection
  Future<void> initializeDeviceConnection() async {
    if (_isDisposed || _attemptInProgress) return;

    _attemptInProgress = true;
    final attempt = ++_attemptId;

    _stallWatchdog?.cancel();
    _stallWatchdog = null;
    _streamAlive = false;
    _connecting = false;
    _lastFrameAt = null;
    _lastPosition = Duration.zero;

    onStateChanged(
      isReconnecting: true,
      isLoading: true,
      showReconnectButton: false,
    );

    _attemptDeadline?.cancel();
    _attemptDeadline = Timer(_attemptTimeout, () {
      if (attempt != _attemptId) return;
      // Abandon whatever this attempt is still waiting for.
      _attemptId++;
      _log('attempt #$attempt: no frames after '
          '${_attemptTimeout.inSeconds}s, giving up');
      _failAttempt();
    });

    _log('attempt #$attempt started');

    try {
      await _closeCommandSocket();
      if (_isDisposed || attempt != _attemptId) return;

      if (streamConfig.shouldRunStreamView) {
        await _sendStartCommand();
        if (_isDisposed || attempt != _attemptId) return;
      }

      await _initializePlayer();
    } catch (e) {
      _log('attempt #$attempt failed: $e');
      if (attempt == _attemptId) _failAttempt();
    } finally {
      onStateChanged(isReconnecting: false);
    }
  }

  /// Full restart of the stream: the device is told to stop the only way it
  /// understands - by losing the command connection - given a moment to
  /// settle, and then asked to start again.
  Future<void> restartStream() async {
    if (_isDisposed || _attemptInProgress) return;

    _attemptInProgress = true;
    _streamAlive = false;
    _connecting = false;
    _stallWatchdog?.cancel();
    _stallWatchdog = null;

    onStateChanged(
      isReconnecting: true,
      isLoading: true,
      showReconnectButton: false,
    );

    // Playback goes first: the device should not still be feeding an RTSP
    // session when it is asked to start a new one.
    try {
      await player.stop();
    } catch (_) {}

    final hadCommandChannel = _commandSocket != null;
    await _closeCommandSocket();

    if (hadCommandChannel) {
      _log('command channel dropped, waiting '
          '${_deviceSettleDelay.inMilliseconds}ms for the device');
      await Future.delayed(_deviceSettleDelay);
    }

    _attemptInProgress = false;
    if (_isDisposed) return;

    await initializeDeviceConnection();
  }

  Future<void> _sendStartCommand() async {
    final address = TcpAddress.parse(streamConfig.tcpCommandUrl);
    final port = int.parse(address.port!);

    final socket =
        await Socket.connect(address.ip, port, timeout: _connectTimeout);
    _commandSocket = socket;

    final ack = Completer<String>();
    _commandSubscription = socket.listen(
      (data) {
        final response = utf8.decode(data).trim();
        _log('device replied: $response');
        if (!ack.isCompleted) ack.complete(response);
      },
      onError: (error) {
        if (!ack.isCompleted) ack.completeError(error);
      },
      cancelOnError: false,
    );

    socket.writeln(_startCommand);
    await socket.flush();

    try {
      await ack.future.timeout(_ackTimeout);
    } catch (e) {
      // Not fatal. The device sometimes ignores a new command session while it
      // still believes an old one is alive, and keeps transmitting anyway.
      // Whether that was good enough is decided by the attempt deadline.
      _log('no ack from the device: $e');
    }

    // The socket stays open on purpose: the device stops transmitting as soon
    // as this connection is dropped.
  }

  Future<void> _closeCommandSocket() async {
    final socket = _commandSocket;
    _commandSocket = null;

    await _commandSubscription?.cancel();
    _commandSubscription = null;

    if (socket == null) return;
    try {
      socket.destroy();
    } catch (_) {}
  }

  Future<void> _initializePlayer() async {
    if (_isDisposed) return;

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

    _lastPosition = Duration.zero;

    final rtspUrl = 'rtsp://${streamConfig.streamUrl}';
    _log('opening $rtspUrl');

    // Set right before open(): stop() above emits its own (stale)
    // width/playing events which must not be taken for this attempt.
    _connecting = true;
    await player.open(
      Media(rtspUrl),
      play: true,
    );
    // The UI stays on the loader until _onStreamAlive() fires or the attempt
    // deadline gives up.
  }

  void _onStreamAlive() {
    _connecting = false;
    _attemptInProgress = false;
    _streamAlive = true;

    _attemptDeadline?.cancel();
    _attemptDeadline = null;

    final now = DateTime.now();
    _lastFrameAt = now;
    _aliveSince = now;
    _startStallWatchdog();

    _log('stream is up');

    WakelockPlus.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    onStateChanged(
      isLoading: false,
      showReconnectButton: false,
    );
  }

  void _failAttempt() {
    _attemptInProgress = false;
    _connecting = false;
    _streamAlive = false;

    _attemptDeadline?.cancel();
    _attemptDeadline = null;
    _stallWatchdog?.cancel();
    _stallWatchdog = null;

    onStateChanged(
      isLoading: false,
      showReconnectButton: true,
    );
  }

  void _startStallWatchdog() {
    _stallWatchdog?.cancel();
    _watchdogTicks = 0;

    _stallWatchdog = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isDisposed || _isHidden || _attemptInProgress) return;

      final lastFrame = _lastFrameAt;
      if (lastFrame == null) return;

      final idle = DateTime.now().difference(lastFrame);

      if (idle < _stallTimeout) {
        _watchdogTicks++;
        final aliveSince = _aliveSince;
        if (_autoRestartUsed &&
            aliveSince != null &&
            DateTime.now().difference(aliveSince) >= _autoRestartCooldown) {
          // Healthy long enough to earn the next automatic restart back.
          _autoRestartUsed = false;
        }
        if (_watchdogTicks % 5 == 0) {
          _log('frames ok, last one ${idle.inMilliseconds}ms ago');
        }
        return;
      }

      _stallWatchdog?.cancel();
      _stallWatchdog = null;

      if (_autoRestartUsed) {
        _log('stalled again after a restart, handing over to the user');
        _failAttempt();
        return;
      }

      _autoRestartUsed = true;
      _log('no frames for ${idle.inMilliseconds}ms, restarting the stream');
      restartStream();
    });
  }

  /// The app went to the background.
  void onHidden() {
    if (_isDisposed) return;

    _isHidden = true;
    _stallWatchdog?.cancel();
    _stallWatchdog = null;
    _log('hidden: stall watchdog paused');

    try {
      player.pause();
    } catch (_) {}
  }

  /// The app came back to the foreground.
  Future<void> onVisible() async {
    if (_isDisposed) return;

    _isHidden = false;

    if (!_streamAlive) {
      // An attempt in flight or the Reconnect button owns the screen.
      _log('visible: no live stream to resume');
      return;
    }

    try {
      await player.play();
    } catch (_) {}

    // Whatever piled up while we were away is replayed first, so give the
    // stream a fresh window before the stall rule may fire.
    final now = DateTime.now();
    _lastFrameAt = now;
    _aliveSince = now;
    _startStallWatchdog();
    _log('visible: stall watchdog resumed');
  }

  /// Release resources
  Future<void> dispose() async {
    _isDisposed = true;

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    _attemptDeadline?.cancel();
    _stallWatchdog?.cancel();
    _playingSubscription?.cancel();
    _bufferingSubscription?.cancel();
    _positionSubscription?.cancel();
    _widthSubscription?.cancel();
    _errorSubscription?.cancel();
    _logSubscription?.cancel();

    await _closeCommandSocket();

    try {
      await player.stop();
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 100));
    player.dispose();
    WakelockPlus.disable();
  }
}
