import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:archer_link/widgets/stream_view/stream_view_container.dart';
import 'package:archer_link/widgets/notification_card.dart';
import 'package:archer_link/widgets/stream_view/stream_view_buttons.dart';
import 'package:archer_link/models/stream_config.dart';
import 'package:archer_link/screens/loading_screen.dart';
import 'package:archer_link/widgets/default_bg.dart';
import 'package:archer_link/screens/reconnect_screen.dart';
import 'package:archer_link/mixins/app_lifecycle_mixin.dart';
import 'package:archer_link/services/stream_player_service.dart';
import 'package:archer_link/utils/video_recorder.dart';

class StreamViewPage extends StatefulWidget {
  final StreamConfig streamConfig;
  final void Function() openSettings;
  final void Function() onDemoMode;

  const StreamViewPage(this.streamConfig, this.openSettings, this.onDemoMode,
      {super.key});

  @override
  State<StreamViewPage> createState() => _StreamViewPageState();
}

class _StreamViewPageState extends State<StreamViewPage>
    with AppLifecycleMixin {
  late final StreamPlayerService _playerService;
  late final VideoRecorder _videoRecorder;

  final GlobalKey _videoKey = GlobalKey();

  bool showReconnectButton = false;
  bool isReconnecting = false;
  bool isLoading = true;
  bool isRecording = false;
  bool isProcessing = false;

  StreamSubscription<List<ConnectivityResult>>? _networkChanges;

  @override
  void initState() {
    super.initState();

    _playerService = StreamPlayerService(
      streamConfig: widget.streamConfig,
      onStateChanged: _handleStateChanged,
    );

    // The first attempt often starts too early on Android: the imager's
    // address is already on wlan0, but the phone still routes the app
    // through mobile data, because a Wi-Fi without internet becomes the
    // default network only after Android's checks give up (measured: 8 s
    // after the address appeared, 4 s after the attempt had timed out).
    // That switch arrives here as a connectivity change, so retry on it
    // instead of waiting for a tap on Reconnect.
    _networkChanges =
        Connectivity().onConnectivityChanged.listen(_onNetworkChanged);

    _videoRecorder = VideoRecorder(
      videoKey: _videoKey,
      player: _playerService.player,
      onNotification: _handleRecorderNotification,
      onProcessingChanged: (processing) {
        setState(() => isProcessing = processing);
      },
    );

    _playerService.initialize();
  }

  void _handleStateChanged({
    bool? isLoading,
    bool? showReconnectButton,
    bool? isReconnecting,
  }) {
    // An attempt that was in flight when the screen went away still
    // reports its end; there is nobody left to show it to.
    if (!mounted) return;
    setState(() {
      if (isLoading != null) this.isLoading = isLoading;
      if (showReconnectButton != null) {
        this.showReconnectButton = showReconnectButton;
      }
      if (isReconnecting != null) this.isReconnecting = isReconnecting;

      if (this.isLoading == false && this.showReconnectButton == false) {
        setLandscapeOrientation();
      }
    });
  }

  void _onNetworkChanged(List<ConnectivityResult> results) {
    if (!mounted || !showReconnectButton || isReconnecting) return;
    // The imager is only ever reachable over Wi-Fi. A change to mobile or
    // to nothing is the network going away, and the home page replaces
    // this screen for that; an attempt started now would outlive it.
    if (!results.contains(ConnectivityResult.wifi)) return;
    _playerService.initializeDeviceConnection();
  }

  void _handleRecorderNotification(bool isError, String message) {
    showNotification(
      isError ? NotificationType.error : NotificationType.defaultType,
      message,
    );
  }

  @override
  void onAppResumed() {
    _videoRecorder.onAppVisible();
    _playerService.onVisible();
  }

  @override
  void onAppPaused() {
    // Recording stops with the app: the recorder saves the file and tells the
    // user about it on return.
    if (isRecording) setState(() => isRecording = false);
    _videoRecorder.onAppHidden();
    _playerService.onHidden();
  }

  @override
  void dispose() {
    _networkChanges?.cancel();
    _playerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      setPortraitOrientation();
      return DefaultBg(child: LoadingIndicator(isLoading: isLoading));
    } else if (showReconnectButton) {
      setPortraitOrientation();
      return ReconnectView(
        isReconnecting: isReconnecting,
        onReconnect: _playerService.initializeDeviceConnection,
        openSettings: widget.openSettings,
        onDemoMode: widget.onDemoMode,
      );
    }

    setLandscapeOrientation();
    return Streamviewcontainer(
      child: Center(
        child: _buildStreamView(),
      ),
    );
  }

  Widget _buildStreamView() {
    double screenWidth = MediaQuery.of(context).size.width;
    double topPadding =
        MediaQuery.of(context).padding.left > MediaQuery.of(context).padding.top
            ? MediaQuery.of(context).padding.left
            : MediaQuery.of(context).padding.top;

    double playerWidth = screenWidth - 240 + 60 - 8 - topPadding;

    Widget video = Video(
      controller: _playerService.videoController,
      fill: Colors.transparent,
      controls: NoVideoControls,
      fit: BoxFit.contain,
    );

    // Recordings and snapshots capture exactly the RepaintBoundary, so it hugs
    // the picture: around the whole box it would record black bars too.
    final videoWidth = _playerService.player.state.width;
    final videoHeight = _playerService.player.state.height;
    video = videoWidth != null &&
            videoHeight != null &&
            videoWidth > 0 &&
            videoHeight > 0
        ? AspectRatio(aspectRatio: videoWidth / videoHeight, child: video)
        : SizedBox.expand(child: video);

    Widget playerWidget = SizedBox(
      width: playerWidth,
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: RepaintBoundary(
          key: _videoKey,
          child: video,
        ),
      ),
    );

    Widget view = StreamViewButtons(
      child: playerWidget,
      onRecordingChanged: (value) {
        setState(() {
          isRecording = value;
          if (isRecording) {
            _videoRecorder.startRecording();
          } else {
            _videoRecorder.stopRecording();
          }
        });
      },
      isRecording: isRecording,
      isProcessing: isProcessing,
      commandUrl: widget.streamConfig.commandUrl,
      takePhoto: _videoRecorder.takeSnapshot,
    );

    if (isProcessing) {
      view = Stack(
        children: [
          view,
          _buildProgressOverlay(),
        ],
      );
    }

    return view;
  }

  Widget _buildProgressOverlay() {
    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Processing...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }

  void showNotification(NotificationType notificationType, String msg) {
    InAppNotification.show(
      child: NotificationCard(
        type: notificationType,
        message: msg,
      ),
      context: context,
      onTap: () {},
      duration: const Duration(seconds: 4),
    );
  }

  void setPortraitOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void setLandscapeOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}

Widget NoVideoControls(VideoState state) {
  return const SizedBox.shrink();
}
