import 'package:archer_link/utils/trace.dart';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/services.dart';

/// Every thermal imager ships with a Wi-Fi name starting with this
/// (for example ARCHER_TSA_1234). The owner can rename it; then the app
/// cannot find it and the user joins it by hand.
const String archerSsidPrefix = 'ARCHER_';

/// The imager's factory Wi-Fi password. It is a basic value, the same on
/// every unit, so there is nothing to hide: it lives here in plain text.
/// iOS sends it with the join request; Android does not use it (the user
/// types it in the system Wi-Fi panel).
///
/// Some units ship with `123456789` instead. The app tries only this one;
/// see docs/connect-button.md. Changing it needs no Xcode rebuild: the value
/// travels to Swift with the call, so a hot restart is enough.
const String archerWifiPassword = '12345678';

/// iOS only. Before asking iOS to join, forget the imager networks this app
/// joined before, so that iOS starts DHCP from scratch (DHCPDISCOVER) instead
/// of re-requesting its cached address (DHCP INIT-REBOOT).
///
/// Why: the imager's DHCP server forgets its leases when the imager restarts
/// and stays silent on INIT-REBOOT. iOS then puts the cached address up at
/// once, waits ~8 s for the confirmation that never comes, and drops the
/// address for ~4 s: the stream, the command socket and the WebSocket all
/// die, and the imager keeps the dead sessions for about a minute.
/// Verified on 2026-10-12: with `true` no drop in 2 of 2 re-joins after an
/// imager restart, with the old behaviour a drop in 2 of 2. The price is
/// ~5 s more until the address on every re-join (the imager answers the
/// second DHCPDISCOVER only). `false` restores the old behaviour, for
/// instance once the imager firmware answers INIT-REBOOT. Travels to Swift
/// with the call, so no Xcode change is needed to flip it.
const bool forgetArcherWifiBeforeJoin = true;


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
///   ios/Runner/DeviceWifi.swift) with [archerWifiPassword]. Apple does not
///   allow opening the Wi-Fi settings.
/// - Android opens the system Wi-Fi panel; the user picks the network and
///   types the password there.
class DeviceWifi {
  /// When [joinArcherWifi] last asked iOS to join. The home page uses it to
  /// tell a join made by the Connect button (cache cleared, DHCP from
  /// scratch, no drop) from one iOS made on its own.
  static DateTime? lastJoinRequestAt;

  static const MethodChannel _channel = MethodChannel('archer_link/device_wifi');

  /// Prints the iOS side's trace lines next to the Dart ones. `flutter run`
  /// does not show NSLog output from the device, so DeviceWifi.swift sends
  /// each line over the channel. Call once at start-up; no-op on Android.
  static void listenToNativeTrace() {
    if (!Platform.isIOS) return;
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'trace') trace('iOS', call.arguments as String);
    });
  }

  /// iOS only. Asks the system to join the strongest nearby network whose
  /// name starts with [archerSsidPrefix]. iOS shows its own "wants to join"
  /// question first; Cancel there gives [WifiJoinResult.cancelled].
  static Future<WifiJoinResult> joinArcherWifi() async {
    assert(Platform.isIOS, 'joinArcherWifi is implemented on iOS only');
    final started = DateTime.now();
    lastJoinRequestAt = started;
    trace('WIFI', 'joinByPrefix("$archerSsidPrefix", password '
        '${archerWifiPassword.length} chars, forgetFirst='
        '$forgetArcherWifiBeforeJoin) -> iOS');
    try {
      final answer = await _channel.invokeMethod<String>(
        'joinByPrefix',
        <String, Object>{
          'prefix': archerSsidPrefix,
          'passphrase': archerWifiPassword,
          'forgetFirst': forgetArcherWifiBeforeJoin,
        },
      );
      trace('WIFI', 'iOS answered "$answer" after '
          '${DateTime.now().difference(started).inMilliseconds} ms');
      switch (answer) {
        case 'alreadyConnected':
          return WifiJoinResult.alreadyConnected;
        case 'cancelled':
          return WifiJoinResult.cancelled;
        default:
          return WifiJoinResult.accepted;
      }
    } on PlatformException catch (e) {
      trace('WIFI', 'iOS refused after '
          '${DateTime.now().difference(started).inMilliseconds} ms: '
          'code=${e.code} message=${e.message}');
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
