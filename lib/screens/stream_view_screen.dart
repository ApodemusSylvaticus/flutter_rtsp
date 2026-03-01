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

  const StreamViewPage(this.streamConfig, this.openSettings, {super.key});

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
  int _progressCurrent = 0;
  int _progressTotal = 0;

  @override
  void initState() {
    super.initState();

    _playerService = StreamPlayerService(
      streamConfig: widget.streamConfig,
      onStateChanged: _handleStateChanged,
    );

    _videoRecorder = VideoRecorder(
      videoKey: _videoKey,
      onNotification: _handleRecorderNotification,
      onProgress: (current, total) {
        setState(() {
          _progressCurrent = current;
          _progressTotal = total;
        });
      },
      onProcessingChanged: (processing) {
        setState(() {
          isProcessing = processing;
          if (processing) {
            _progressCurrent = 0;
            _progressTotal = 0;
          }
        });
      },
    );

    _playerService.initialize();
  }

  void _handleStateChanged({
    bool? isLoading,
    bool? showReconnectButton,
    bool? isReconnecting,
  }) {
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

  void _handleRecorderNotification(bool isError, String message) {
    showNotification(
      isError ? NotificationType.error : NotificationType.defaultType,
      message,
    );
  }

  @override
  void onAppResumed() {
    _playerService.reconnectAfterResume();
  }

  @override
  void onAppPaused() {
    _playerService.pause();
  }

  @override
  void dispose() {
    _playerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Streamviewcontainer(
      child: Center(
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      setPortraitOrientation();
      return DefaultBg(child: LoadingIndicator(isLoading: isLoading));
    } else if (showReconnectButton) {
      setPortraitOrientation();
      return ReconnectView(
        isReconnecting: isReconnecting,
        onReconnect: _playerService.initializeDeviceConnection,
        openSettings: widget.openSettings,
      );
    } else {
      setLandscapeOrientation();
      return _buildStreamView();
    }
  }

  Widget _buildStreamView() {
    double screenWidth = MediaQuery.of(context).size.width;
    double topPadding =
        MediaQuery.of(context).padding.left > MediaQuery.of(context).padding.top
            ? MediaQuery.of(context).padding.left
            : MediaQuery.of(context).padding.top;

    double playerWidth = screenWidth - 240 + 60 - 8 - topPadding;

    Widget playerWidget = RepaintBoundary(
      key: _videoKey,
      child: SizedBox(
        width: playerWidth,
        height: MediaQuery.of(context).size.height,
        child: Video(
          controller: _playerService.videoController,
          fill: Colors.transparent,
          controls: NoVideoControls,
          fit: BoxFit.contain,
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
    final text = _progressTotal > 0
        ? 'Processing $_progressCurrent/$_progressTotal...'
        : 'Processing...';

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
          child: Text(
            text,
            style: const TextStyle(
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
