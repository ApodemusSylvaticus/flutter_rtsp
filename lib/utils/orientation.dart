import 'dart:io' show Platform;

import 'package:flutter/services.dart';

/// The landscape with the phone's camera on the left.
///
/// The stream pages keep clear of the camera cutout on their left side only
/// (StreamViewButtons, DemoStreamViewButtons), so they stay in this one
/// landscape: turned the other way, the camera covers the buttons on the
/// right. The same Flutter name means opposite sides on the two platforms:
/// on iOS [DeviceOrientation.landscapeLeft] is UIKit's landscapeLeft, home
/// indicator on the left and camera on the right; on Android it is the
/// landscape with the top of the phone on the left.
DeviceOrientation get landscapeCameraLeft => Platform.isIOS
    ? DeviceOrientation.landscapeRight
    : DeviceOrientation.landscapeLeft;
