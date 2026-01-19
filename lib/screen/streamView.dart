import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:archer_link/containers/StreamViewContainer.dart';
import 'package:archer_link/features/notificationCard/index.dart';
import 'package:archer_link/main.dart';
import 'package:archer_link/features/StreamViewButtons/index.dart';
import 'package:archer_link/features/loading.dart';
import 'package:archer_link/features/reconnectView.dart';
import 'package:archer_link/mixins/appLifecycleMixin.dart';
import 'package:archer_link/services/streamPlayerService.dart';
import 'package:archer_link/utils/videoRecorder.dart';

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
        child: buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    if (isLoading) {
      setPortraitOrientation();
      return LoadingIndicator(isLoading: isLoading);
    } else if (showReconnectButton) {
      setPortraitOrientation();
      return ReconnectView(
        isReconnecting: isReconnecting,
        onReconnect: _playerService.initializeDeviceConnection,
        openSettings: widget.openSettings,
      );
    } else {
      setLandscapeOrientation();
      return buildStreamView();
    }
  }

  void showNotification(NotificationType notificationType, String msg) {
    InAppNotification.show(
      child: NotificationCard(
        type: notificationType,
        message: msg,
      ),
      context: context,
      onTap: () => print('Notification tapped!'),
      duration: const Duration(seconds: 4),
    );
  }

  Widget buildStreamView() {
    double screenWidth = MediaQuery.of(context).size.width;
    double topPadding =
        MediaQuery.of(context).padding.left > MediaQuery.of(context).padding.top
            ? MediaQuery.of(context).padding.left
            : MediaQuery.of(context).padding.top;

    double playerWidth = screenWidth - 240 + 60 - 8 - topPadding;

    Widget playerWidget = Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: RepaintBoundary(
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
      ),
    );

    return StreamViewButtons(
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
      commandUrl: widget.streamConfig.commandUrl,
      takePhoto: _videoRecorder.takeSnapshot,
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
