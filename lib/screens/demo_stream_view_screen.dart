import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:archer_link/widgets/stream_view/stream_view_container.dart';
import 'package:archer_link/widgets/notification_card.dart';
import 'package:archer_link/widgets/stream_view/demo_stream_view_buttons.dart';
import 'package:archer_link/screens/loading_screen.dart';
import 'package:archer_link/widgets/default_bg.dart';
import 'package:archer_link/mixins/app_lifecycle_mixin.dart';
import 'package:archer_link/services/demo_player_service.dart';
import 'package:archer_link/utils/video_recorder.dart';
import 'package:archer_link/proto/archer_protocol.pb.dart' as proto;


class DemoStreamViewPage extends StatefulWidget {
  final void Function() openSettings;

  const DemoStreamViewPage({required this.openSettings, super.key});

  @override
  State<DemoStreamViewPage> createState() => _DemoStreamViewPageState();
}

class _DemoStreamViewPageState extends State<DemoStreamViewPage>
    with AppLifecycleMixin {
  late final DemoPlayerService _playerService;
  late final VideoRecorder _videoRecorder;

  final GlobalKey _videoKey = GlobalKey();

  bool isLoading = true;
  bool isRecording = false;
  bool isProcessing = false;
  int _progressCurrent = 0;
  int _progressTotal = 0;

  proto.HostDevStatus? _devStatus;

  int? _videoWidth;
  int? _videoHeight;
  StreamSubscription? _widthSub;
  StreamSubscription? _heightSub;

  // Color mode label animation
  bool _showColorModeLabel = false;
  double _colorModeLabelOpacity = 0.0;
  String _colorModeLabelText = '';
  Timer? _colorModeLabelTimer;

  // AGC mode label animation
  bool _showAgcModeLabel = false;
  double _agcModeLabelOpacity = 0.0;
  String _agcModeLabelText = '';
  Timer? _agcModeLabelTimer;

  // Calibration animation
  bool _isCalibrating = false;
  double _calibrationBlur = 0.0;
  Offset _crosshairOffset = Offset.zero;
  bool _showCalibrationLabel = false;
  double _calibrationLabelOpacity = 0.0;
  Timer? _calibrationTimer;
  Timer? _calibrationTickTimer;
  int _calibrationElapsed = 0;

  static const _osdStyle = TextStyle(
    color: Color(0xFF00FF00),
    fontSize: 14,
    fontWeight: FontWeight.bold,
    fontFamily: 'monospace',
    decoration: TextDecoration.none,
    shadows: [
      Shadow(offset: Offset(1, 1), blurRadius: 2, color: Color(0xAA000000)),
    ],
  );

  @override
  void initState() {
    super.initState();

    _playerService = DemoPlayerService(
      onStateChanged: ({bool? isLoading}) {
        if (isLoading != null) {
          setState(() {
            this.isLoading = isLoading;
            if (!isLoading) setLandscapeOrientation();
          });
        }
      },
    );

    _videoRecorder = VideoRecorder(
      videoKey: _videoKey,
      onNotification: (isError, message) {
        showNotification(
          isError ? NotificationType.error : NotificationType.defaultType,
          message,
        );
      },
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

    // Listen to actual video dimensions from the player
    _widthSub = _playerService.player.stream.width.listen((w) {
      if (w != null && w != _videoWidth) {
        setState(() => _videoWidth = w);
      }
    });
    _heightSub = _playerService.player.stream.height.listen((h) {
      if (h != null && h != _videoHeight) {
        setState(() => _videoHeight = h);
      }
    });

    _playerService.initialize();
  }

  @override
  void onAppResumed() => _playerService.resume();

  @override
  void onAppPaused() => _playerService.pause();

  @override
  void dispose() {
    _colorModeLabelTimer?.cancel();
    _agcModeLabelTimer?.cancel();
    _calibrationTimer?.cancel();
    _calibrationTickTimer?.cancel();
    _widthSub?.cancel();
    _heightSub?.cancel();
    _playerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      setPortraitOrientation();
      return DefaultBg(child: LoadingIndicator(isLoading: true));
    }

    return Streamviewcontainer(
      child: Center(
        child: _buildStreamView(),
      ),
    );
  }

  Widget _buildStreamView() {
    setLandscapeOrientation();

    Widget playerWidget = LayoutBuilder(
      builder: (context, constraints) {
        final availWidth = constraints.maxWidth;
        final availHeight = constraints.maxHeight;

        // Calculate exact video size maintaining native aspect ratio
        double videoW, videoH;
        if (_videoWidth != null && _videoHeight != null &&
            _videoWidth! > 0 && _videoHeight! > 0) {
          final aspectRatio = _videoWidth! / _videoHeight!;
          videoW = availWidth;
          videoH = videoW / aspectRatio;
          if (videoH > availHeight) {
            videoH = availHeight;
            videoW = videoH * aspectRatio;
          }
        } else {
          videoW = availWidth;
          videoH = availHeight;
        }

        // Build video widget with optional color filter and zoom
        Widget videoWidget = Video(
          controller: _playerService.videoController,
          fill: Colors.black,
          controls: NoVideoControls,
          fit: BoxFit.cover,
        );

        if (_devStatus != null) {
          final colorFilter = _getColorFilter(_devStatus!.colorScheme);
          if (colorFilter != null) {
            videoWidget = ColorFiltered(
              colorFilter: colorFilter,
              child: videoWidget,
            );
          }

          // AGC visual effects
          final agcFilter = _getAgcColorFilter(_devStatus!.modAGC);
          if (agcFilter != null) {
            videoWidget = ColorFiltered(
              colorFilter: agcFilter,
              child: videoWidget,
            );
          }

          final scale = _getZoomScale(_devStatus!.zoom);
          videoWidget = ClipRect(
            child: Transform.scale(
              scale: scale,
              child: videoWidget,
            ),
          );

          // AGC blur (mode 2)
          final agcBlur = _getAgcBlurSigma(_devStatus!.modAGC);
          if (agcBlur > 0) {
            videoWidget = ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: agcBlur, sigmaY: agcBlur),
              child: videoWidget,
            );
          }

          // Calibration blur animation
          if (_calibrationBlur > 0.1) {
            videoWidget = ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: _calibrationBlur,
                sigmaY: _calibrationBlur,
              ),
              child: videoWidget,
            );
          }
        }

        // RepaintBoundary wraps video + OSD for screenshots/recording
        return Center(
          child: RepaintBoundary(
            key: _videoKey,
            child: SizedBox(
              width: videoW,
              height: videoH,
              child: Stack(
                children: [
                  Positioned.fill(child: videoWidget),
                  if (_devStatus != null) _buildOsd(videoW, videoH),
                ],
              ),
            ),
          ),
        );
      },
    );

    Widget view = DemoStreamViewButtons(
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
      takePhoto: _videoRecorder.takeSnapshot,
      isCalibrating: _isCalibrating,
      onCalibrationTriggered: _triggerCalibrationAnimation,
      onDevStatusChanged: (devStatus) {
        setState(() {
          final oldScheme = _devStatus?.colorScheme;
          final oldAgc = _devStatus?.modAGC;
          _devStatus = devStatus;

          if (oldScheme != null && oldScheme != devStatus.colorScheme) {
            _triggerColorModeLabel(devStatus.colorScheme);
          }
          if (oldAgc != null && oldAgc != devStatus.modAGC) {
            _triggerAgcModeLabel(devStatus.modAGC);
          }
        });
      },
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

  // --- OSD ---

  Widget _buildOsd(double w, double h) {
    final status = _devStatus!;
    final zoomLabel = _getZoomLabel(status.zoom);

    // Proportions from reference (614x384)
    final pad = h * 0.039;      // ~3.9% of height for edge padding
    final fontSize = h * 0.031; // ~3.1% of height for base font
    final zoomSize = h * 0.052; // zoom label bigger
    final profileCircle = h * 0.047;
    final batW = w * 0.065;     // battery width
    final batH = h * 0.042;     // battery height
    final batFontSize = h * 0.026;
    final wifiSize = h * 0.047;

    final osd = _osdStyle.copyWith(fontSize: fontSize);

    return Stack(
      children: [
        // Crosshair (shifts + blurs during calibration)
        Positioned.fill(
          child: Transform.translate(
            offset: _crosshairOffset,
            child: _calibrationBlur > 0.1
                ? ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: _calibrationBlur * 0.35,
                      sigmaY: _calibrationBlur * 0.35,
                    ),
                    child: CustomPaint(painter: _CrosshairPainter()),
                  )
                : CustomPaint(painter: _CrosshairPainter()),
          ),
        ),

        // Top-right: WiFi + Tumbler + Profile info + zoom
        Positioned(
          top: pad,
          right: pad,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomPaint(
                    size: Size(wifiSize * 1.3, wifiSize),
                    painter: _WifiIconPainter(),
                  ),
                  SizedBox(width: pad * 0.6),
                  CustomPaint(
                    size: Size(profileCircle, profileCircle),
                    painter: _TumblerIconPainter(),
                  ),
                  SizedBox(width: pad * 0.2),
                  Text('1', style: osd),
                  SizedBox(width: pad * 0.6),
                  Text('Profile ${status.currentProfile}', style: osd),
                ],
              ),
              SizedBox(height: pad * 0.15),
              Text('Hornady', style: osd),
              if (zoomLabel != null) ...[
                SizedBox(height: pad * 0.3),
                Text(zoomLabel, style: osd.copyWith(
                  fontSize: zoomSize * 0.8,
                  color: const Color(0xFF00E5CC),
                )),
              ],
            ],
          ),
        ),

        // Color mode label (animated)
        if (_showColorModeLabel)
          Positioned(
            top: h * 0.15,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedOpacity(
                opacity: _colorModeLabelOpacity,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _colorModeLabelText,
                  style: osd.copyWith(fontSize: h * 0.045),
                ),
              ),
            ),
          ),

        // AGC mode label (animated)
        if (_showAgcModeLabel)
          Positioned(
            top: h * 0.15,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedOpacity(
                opacity: _agcModeLabelOpacity,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _agcModeLabelText,
                  style: osd.copyWith(fontSize: h * 0.045),
                ),
              ),
            ),
          ),

        // Calibration label (animated)
        if (_showCalibrationLabel)
          Positioned(
            top: h * 0.15,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedOpacity(
                opacity: _calibrationLabelOpacity,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  'Calibration',
                  style: osd.copyWith(fontSize: h * 0.045),
                ),
              ),
            ),
          ),

        // Bottom-left: distance | wind | temp
        Positioned(
          bottom: pad,
          left: pad,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${status.distance} m', style: osd),

              if (status.windSpeed > 0) ...[
                SizedBox(width: pad),
                Transform.rotate(
                  angle: status.windDir * math.pi / 180,
                  child: CustomPaint(
                    size: Size(fontSize, fontSize),
                    painter: _WindArrowPainter(),
                  ),
                ),
                SizedBox(width: pad * 0.3),
                Text('${status.windSpeed.toDouble()}', style: osd),
              ],

              SizedBox(width: pad * 1.5),
              Text('A${status.airTemp}\u00B0', style: osd),
            ],
          ),
        ),

        // Right side: arrow + 10.0 at 60% from bottom
        Positioned(
          bottom: h * 0.63,
          right: pad,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomPaint(
                size: Size(fontSize * 1.4, fontSize),
                painter: _LeftArrowPainter(),
              ),
              SizedBox(width: pad * 0.3),
              Text('10.0', style: osd),
            ],
          ),
        ),

        // Right side: V058 at 25% from bottom
        Positioned(
          bottom: h * 0.25,
          right: pad,
          child: Text('V058', style: osd),
        ),

        // Bottom-right: 1.5V + battery
        Positioned(
          bottom: pad,
          right: pad,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('1.5V', style: osd),
              SizedBox(width: pad * 0.5),
              SizedBox(
                width: batW,
                height: batH,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size(batW, batH),
                      painter: _BatteryIconPainter(status.charge / 100.0),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: batW * 0.1),
                      child: Text(
                        '${status.charge}%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: batFontSize,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _triggerColorModeLabel(proto.ColorScheme scheme) {
    _colorModeLabelTimer?.cancel();

    _colorModeLabelText = _getColorSchemeLabel(scheme);
    _showColorModeLabel = true;
    _colorModeLabelOpacity = 1.0;

    _colorModeLabelTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _colorModeLabelOpacity = 0.0;
        });
        _colorModeLabelTimer = Timer(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _showColorModeLabel = false;
            });
          }
        });
      }
    });
  }

  void _triggerCalibrationAnimation() {
    _calibrationTimer?.cancel();
    _calibrationTickTimer?.cancel();

    const totalMs = 5000;
    const tickMs = 100;
    _calibrationElapsed = 0;

    // Generate 3 random jump offsets (near center, ±3-6 px)
    final rng = math.Random();
    Offset randomOff() {
      final dx = (rng.nextDouble() * 4 + 6) * (rng.nextBool() ? 1 : -1);
      final dy = (rng.nextDouble() * 4 + 6) * (rng.nextBool() ? 1 : -1);
      return Offset(dx, dy);
    }
    final jumps = [randomOff(), randomOff(), randomOff()];
    // Jump times: ~0.8s, ~2.2s, ~3.6s (normalized)
    const jumpTimes = [0.16, 0.44, 0.72];
    // Return to center at ~4.4s
    const returnTime = 0.88;
    int lastJumpIndex = -1;

    setState(() {
      _isCalibrating = true;
      _showCalibrationLabel = true;
      _calibrationLabelOpacity = 1.0;
    });

    _calibrationTickTimer = Timer.periodic(
      const Duration(milliseconds: tickMs),
      (timer) {
        if (!mounted) { timer.cancel(); return; }

        _calibrationElapsed += tickMs;
        final t = _calibrationElapsed / totalMs; // 0.0 → 1.0

        if (t >= 1.0) {
          timer.cancel();
          setState(() {
            _calibrationBlur = 0.0;
            _crosshairOffset = Offset.zero;
            _calibrationLabelOpacity = 0.0;
          });
          _calibrationTimer = Timer(const Duration(milliseconds: 300), () {
            if (!mounted) return;
            setState(() {
              _showCalibrationLabel = false;
              _isCalibrating = false;
            });
          });
          return;
        }

        // Wavy blur
        double blur;
        if (t < 0.1) {
          blur = (t / 0.1) * 3.0;
        } else if (t < 0.85) {
          final phase = (t - 0.1) / 0.75;
          blur = 2.5 + 1.5 * math.sin(phase * 3 * math.pi);
        } else {
          final phase = (t - 0.85) / 0.15;
          blur = 2.5 * (1.0 - phase);
        }

        // Crosshair jumps — instant snap at jump times
        Offset offset = _crosshairOffset;
        if (t >= returnTime) {
          offset = Offset.zero;
        } else {
          for (int i = jumpTimes.length - 1; i >= 0; i--) {
            if (t >= jumpTimes[i] && lastJumpIndex < i) {
              lastJumpIndex = i;
              offset = jumps[i];
              break;
            }
          }
        }

        setState(() {
          _calibrationBlur = blur.clamp(0.0, 5.0);
          _crosshairOffset = offset;
        });
      },
    );
  }

  void _triggerAgcModeLabel(proto.AGCMode mode) {
    _agcModeLabelTimer?.cancel();

    _agcModeLabelText = _getAgcModeLabel(mode);
    _showAgcModeLabel = true;
    _agcModeLabelOpacity = 1.0;

    _agcModeLabelTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _agcModeLabelOpacity = 0.0;
        });
        _agcModeLabelTimer = Timer(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _showAgcModeLabel = false;
            });
          }
        });
      }
    });
  }

  String _getAgcModeLabel(proto.AGCMode mode) {
    switch (mode) {
      case proto.AGCMode.AUTO_1:
        return 'Auto mod 1';
      case proto.AGCMode.AUTO_2:
        return 'Auto mod 2';
      case proto.AGCMode.AUTO_3:
        return 'Auto mod 3';
      default:
        return '';
    }
  }

  String _getColorSchemeLabel(proto.ColorScheme scheme) {
    switch (scheme) {
      case proto.ColorScheme.WHITE_HOT:
        return 'White Hot';
      case proto.ColorScheme.BLACK_HOT:
        return 'Black Hot';
      case proto.ColorScheme.SEPIA:
        return 'Sepia';
      default:
        return '';
    }
  }

  // --- Helpers ---

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

  // AGC mode 3: more contrast + darker (~11.25%)
  ColorFilter? _getAgcColorFilter(proto.AGCMode mode) {
    if (mode == proto.AGCMode.AUTO_3) {
      // contrast 1.1125, brightness offset ~ -0.1125 * 255 ≈ -29
      const c = 1.1125;
      const b = -29.0;
      return const ColorFilter.matrix(<double>[
        c, 0, 0, 0, b,
        0, c, 0, 0, b,
        0, 0, c, 0, b,
        0, 0, 0, 1, 0,
      ]);
    }
    return null;
  }

  // AGC mode 2: slight blur
  double _getAgcBlurSigma(proto.AGCMode mode) {
    if (mode == proto.AGCMode.AUTO_2) {
      return 2.25;
    }
    return 0;
  }

  ColorFilter? _getColorFilter(proto.ColorScheme scheme) {
    switch (scheme) {
      case proto.ColorScheme.WHITE_HOT:
        return null;
      case proto.ColorScheme.BLACK_HOT:
        return const ColorFilter.matrix(<double>[
          -1, 0, 0, 1, 0,
          0, -1, 0, 1, 0,
          0, 0, -1, 1, 0,
          0, 0, 0, 1, 0,
        ]);
      case proto.ColorScheme.SEPIA:
        return const ColorFilter.matrix(<double>[
          1.2, 0.5, 0.1, 30 / 255, 0,
          0.3, 0.4, 0.1, 0, 0,
          0.0, 0.0, 0.1, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      default:
        return null;
    }
  }

  String? _getZoomLabel(proto.Zoom zoom) {
    switch (zoom) {
      case proto.Zoom.ZOOM_X1:
        return null;
      case proto.Zoom.ZOOM_X2:
        return '2x';
      case proto.Zoom.ZOOM_X3:
        return '3x';
      case proto.Zoom.ZOOM_X4:
        return '4x';
      case proto.Zoom.ZOOM_X6:
        return '6x';
      default:
        return null;
    }
  }

  double _getZoomScale(proto.Zoom zoom) {
    switch (zoom) {
      case proto.Zoom.ZOOM_X1:
        return 1.0;
      case proto.Zoom.ZOOM_X2:
        return 2.0;
      case proto.Zoom.ZOOM_X3:
        return 3.0;
      case proto.Zoom.ZOOM_X4:
        return 4.0;
      case proto.Zoom.ZOOM_X6:
        return 6.0;
      default:
        return 1.0;
    }
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

class _CrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FF00)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;
    const armLength = 14.0;
    const gap = 3.0;

    // Horizontal arms
    canvas.drawLine(Offset(cx - armLength, cy), Offset(cx - gap, cy), paint);
    canvas.drawLine(Offset(cx + gap, cy), Offset(cx + armLength, cy), paint);

    // Vertical arms
    canvas.drawLine(Offset(cx, cy - armLength), Offset(cx, cy - gap), paint);
    canvas.drawLine(Offset(cx, cy + gap), Offset(cx, cy + armLength), paint);

    // Center dot
    canvas.drawCircle(Offset(cx, cy), 1.0, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WifiIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FF00)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final bottom = size.height;

    // Three arcs (small to large)
    for (int i = 1; i <= 3; i++) {
      final radius = i * 4.0;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, bottom), radius: radius),
        -math.pi * 0.8,
        math.pi * 0.6,
        false,
        paint,
      );
    }

    // Bottom dot
    canvas.drawCircle(
      Offset(cx, bottom - 1),
      1.5,
      paint..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BatteryIconPainter extends CustomPainter {
  final double level; // 0.0 to 1.0

  _BatteryIconPainter(this.level);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FF00)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Battery body
    final bodyRect = Rect.fromLTWH(0, 1, size.width - 4, size.height - 2);
    canvas.drawRect(bodyRect, paint);

    // Battery tip (right)
    final tipRect = Rect.fromLTWH(size.width - 4, size.height * 0.25, 4, size.height * 0.5);
    canvas.drawRect(tipRect, paint..style = PaintingStyle.fill);

    // Fill level
    final fillWidth = (size.width - 6) * level.clamp(0.0, 1.0);
    if (fillWidth > 0) {
      final fillRect = Rect.fromLTWH(2, 3, fillWidth, size.height - 6);
      canvas.drawRect(fillRect, paint..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(covariant _BatteryIconPainter oldDelegate) =>
      oldDelegate.level != level;
}

class _TumblerIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FF00)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width * 0.38;

    // Open arc (bottom ~270 degrees, gap at top)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      math.pi * 0.15,  // start just past top-right
      math.pi * 1.7,   // sweep ~270 degrees
      false,
      paint,
    );

    // Pointer line from center at 45° (top-right direction)
    final pointerLen = radius * 1.3;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + pointerLen * math.cos(math.pi / 4), cy - pointerLen * math.sin(math.pi / 4)),
      paint..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LeftArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FF00)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cy = size.height / 2;
    final arrowHeadSize = size.height * 0.35;

    // Shaft
    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), paint);

    // Arrowhead (filled triangle)
    final arrowPath = Path()
      ..moveTo(0, cy)
      ..lineTo(arrowHeadSize, cy - arrowHeadSize)
      ..lineTo(arrowHeadSize, cy + arrowHeadSize)
      ..close();
    canvas.drawPath(arrowPath, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WindArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FF00)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final cy = size.height / 2;

    // Arrow pointing right (→), rotation applied via Transform.rotate
    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), paint);
    canvas.drawLine(Offset(size.width - 4, cy - 3), Offset(size.width, cy), paint);
    canvas.drawLine(Offset(size.width - 4, cy + 3), Offset(size.width, cy), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
