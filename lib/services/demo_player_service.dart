import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter/services.dart';

/// Callback for UI state change notifications
typedef OnDemoStateChanged = void Function({
  bool? isLoading,
});

/// Simple video player for demo mode — plays local asset on loop
class DemoPlayerService {
  late final Player player;
  late final VideoController videoController;
  final OnDemoStateChanged onStateChanged;

  bool _isDisposed = false;

  DemoPlayerService({
    required this.onStateChanged,
  }) {
    player = Player(
      configuration: const PlayerConfiguration(
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

  Future<void> initialize() async {
    if (_isDisposed) return;

    onStateChanged(isLoading: true);

    try {
      await player.setVolume(0);
      await player.open(
        Media('asset:///assets/demo/thermal_demo.mp4'),
        play: true,
      );
      await player.setPlaylistMode(PlaylistMode.loop);

      WakelockPlus.enable();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

      onStateChanged(isLoading: false);
    } catch (e) {
      print('[DEMO] Player error: $e');
      onStateChanged(isLoading: false);
    }
  }

  void pause() {
    if (_isDisposed) return;
    try {
      player.pause();
    } catch (_) {}
  }

  Future<void> resume() async {
    if (_isDisposed) return;
    await Future.delayed(const Duration(milliseconds: 500));
    if (!player.state.playing) {
      await player.play();
    }
  }

  Future<void> dispose() async {
    _isDisposed = true;

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    try {
      await player.stop();
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 100));
    player.dispose();
    WakelockPlus.disable();
  }
}
