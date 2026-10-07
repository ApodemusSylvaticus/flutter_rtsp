import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/services.dart';

/// Every thermal imager ships with a Wi-Fi name starting with this
/// (for example ARCHER_TSA_1234). The owner can rename it; then the app
/// cannot find it and the user joins it by hand.
const String archerSsidPrefix = 'ARCHER_';

/// What iOS answered to a join request. None of these means "joined":
/// iOS only confirms that it accepted the request and reports a failed
/// join (wrong password, network not in range) to the user, not to the
/// app. The caller confirms by waiting for the imager's subnet.
enum WifiJoinResult { accepted, alreadyConnected, cancelled }

/// iOS refused the join request before trying, for example because the
/// Wi-Fi subsystem is stuck (`internal`, only a reboot helps) or another
/// request is still `pending`.
class WifiJoinException implements Exception {
  final String code;
  final String message;

  const WifiJoinException(this.code, this.message);

  @override
  String toString() => 'WifiJoinException($code): $message';
}

/// Gets the phone onto the thermal imager's Wi-Fi.
///
/// The two platforms work differently on purpose:
/// - iOS joins the network itself (NEHotspotConfiguration, see
///   ios/Runner/DeviceWifi.swift) with the factory password compiled into
///   the iOS build. Apple does not allow opening the Wi-Fi settings.
/// - Android opens the system Wi-Fi panel; the user picks the network and
///   types the password there, so the Android build holds no password.
class DeviceWifi {
  static const MethodChannel _channel = MethodChannel('archer_link/device_wifi');

  /// iOS only. Asks the system to join the strongest nearby network whose
  /// name starts with [archerSsidPrefix]. iOS shows its own "wants to join"
  /// question first; Cancel there gives [WifiJoinResult.cancelled].
  static Future<WifiJoinResult> joinArcherWifi() async {
    assert(Platform.isIOS, 'joinArcherWifi is implemented on iOS only');
    try {
      final answer = await _channel.invokeMethod<String>(
        'joinByPrefix',
        <String, String>{'prefix': archerSsidPrefix},
      );
      switch (answer) {
        case 'alreadyConnected':
          return WifiJoinResult.alreadyConnected;
        case 'cancelled':
          return WifiJoinResult.cancelled;
        default:
          return WifiJoinResult.accepted;
      }
    } on PlatformException catch (e) {
      throw WifiJoinException(e.code, e.message ?? '');
    }
  }

  /// Android only. Slides the system Wi-Fi panel up over the app. Returns
  /// once the panel is shown; the app goes inactive while it is up and
  /// resumes when the user closes it.
  static Future<void> openWifiPanel() {
    assert(Platform.isAndroid, 'openWifiPanel is implemented on Android only');
    return const AndroidIntent(action: 'android.settings.panel.action.WIFI')
        .launch();
  }
}
