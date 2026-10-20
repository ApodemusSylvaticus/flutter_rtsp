import 'dart:io';

import 'package:archer_link/utils/trace.dart';
import 'package:flutter/services.dart';

// Wi-Fi-off guard, iOS only. The story, the evidence, the check for a new
// iOS and how to remove the guard: docs/wifi-off-guard.md.
//
// In short: Connect asks iOS to join the imager's Wi-Fi by the name prefix
// ARCHER (ios/Runner/DeviceWifi.swift). With Wi-Fi switched off in
// Settings, iOS never answers that request, and then refuses every later
// join, of any app, until the phone restarts. iOS has no API that says
// whether Wi-Fi is on, so the guard reads the network interfaces instead
// (ios/Runner/WifiOffGuard.swift), and holds the request back only when
// they say "off".

/// Kill switch: `false` turns the guard off, and Connect always asks iOS,
/// as before the guard. Dart only: a hot restart is enough on a dev build;
/// users get it with an app update.
const bool wifiOffGuardEnabled = true;

/// The help text when the guard holds a join back. The help picture under
/// it still shows how to join by hand.
const String wifiOffHelpText =
    'Wi-Fi is turned off. Turn it on in Settings > Wi-Fi, come back and tap '
    'Connect. If Wi-Fi is already on, join the ARCHER_XXXX network in '
    'Settings > Wi-Fi.';

const MethodChannel _channel = MethodChannel('archer_link/wifi_off_guard');

/// Whether Wi-Fi is switched off in Settings, read just before a join:
/// - a Wi-Fi address (en0): Wi-Fi is on, whatever awdl0 says;
/// - awdl0 up: the radio is on (also with Wi-Fi switched off in Control
///   Center);
/// - no awdl0, or no reading at all: unknown, treated as on, so Connect
///   behaves as before the guard;
/// - awdl0 down and no Wi-Fi address: off.
///
/// Only the last case returns true. Every reading goes to the trace.
Future<bool> isWifiSwitchedOff() async {
  if (!wifiOffGuardEnabled || !Platform.isIOS) return false;
  Map<Object?, Object?>? reading;
  try {
    reading = await _channel.invokeMapMethod<Object?, Object?>('readInterfaces');
  } catch (e) {
    trace('WIFI', 'Wi-Fi-off guard: no reading ($e) -> join');
    return false;
  }
  final awdl = reading?['awdl']?.toString() ?? 'missing';
  final address = reading?['wifiAddress']?.toString() ?? '';
  final off = address.isEmpty && awdl == 'down';
  trace(
      'WIFI',
      'Wi-Fi-off guard: awdl0 $awdl, Wi-Fi address '
          '${address.isEmpty ? 'none' : address} -> '
          '${off ? 'Wi-Fi is off in Settings, no join request' : 'join'}');
  return off;
}
