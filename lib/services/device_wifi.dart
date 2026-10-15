import 'dart:async';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:archer_link/utils/trace.dart';
import 'package:flutter/services.dart';

/// Every thermal imager ships with a Wi-Fi name starting with this (for
/// example ARCHER_TSA_1234). No separator after it, on purpose: any network
/// whose name begins with ARCHER counts as an imager (owner's decision).
/// iOS joins the strongest such network. The owner can rename the
/// network; then the app cannot find it and the user joins it by hand.
const String archerSsidPrefix = 'ARCHER';

/// The imager's factory Wi-Fi password. It is a basic value, the same on
/// every unit, so there is nothing to hide: it lives here in plain text.
/// iOS sends it with the join request; Android does not use it (the user
/// types it in the system Wi-Fi panel, once).
///
/// Some units ship with `123456789` instead, and owners can change it. The
/// app sends only this one by itself; on iOS the user can type the
/// device's own password after a failed join, and the one that worked is
/// used from then on (see [DeviceWifi.joinArcherWifi], docs/connect-button.md).
/// Changing it needs no Xcode rebuild: the value travels to Swift with the
/// call, so a hot restart is enough.
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
///   ios/Runner/DeviceWifi.swift) with [archerWifiPassword], or with the
///   password the user typed after a failed join (see [joinArcherWifi]).
///   Apple does not allow opening the Wi-Fi settings.
/// - Android opens the system Wi-Fi panel ([openWifiPanel]); the user
///   picks the network and types the password there, once: the phone
///   remembers it.
///
/// Android also binds the app's traffic to the imager's Wi-Fi whenever one
/// is up (android/app/src/main/kotlin/com/archer/archerlink/; reported
/// here as [imagerNetworkChanges]). Android keeps mobile data as the
/// default network while a Wi-Fi has no internet, and without the binding
/// the app's sockets would go out over mobile data and time out.
class DeviceWifi {
  /// When [joinArcherWifi] last asked iOS to join. The home page uses it to
  /// tell a join made by the Connect button (cache cleared, DHCP from
  /// scratch, no drop) from one iOS made on its own.
  static DateTime? lastJoinRequestAt;

  static const MethodChannel _channel = MethodChannel('archer_link/device_wifi');

  static final StreamController<bool> _imagerNetworkChanges =
      StreamController<bool>.broadcast();
  static bool _imagerNetworkBound = false;
  static String? _imagerNetworkAddress;

  /// Android only: `true` each time the app gets bound to an imager Wi-Fi
  /// (a Wi-Fi with an address in 192.168.100.0/24 or 192.168.1.0/24),
  /// `false` when that binding is dropped. Never emits on iOS.
  static Stream<bool> get imagerNetworkChanges => _imagerNetworkChanges.stream;

  /// Android only: whether the app's traffic is bound to an imager Wi-Fi
  /// right now. Always false on iOS.
  static bool get imagerNetworkBound => _imagerNetworkBound;

  /// Android only: the phone's address on the imager Wi-Fi the app is bound
  /// to, null when not bound.
  static String? get imagerNetworkAddress => _imagerNetworkAddress;

  /// Handles the calls the native side makes on its own, on both platforms:
  /// - `trace`: a native trace line, printed next to the Dart ones.
  ///   `flutter run` shows neither NSLog output nor logcat from the device,
  ///   so both native sides send each line over the channel.
  /// - `imagerNetwork` (Android): the process binding changed.
  ///
  /// Call once, from main() before runApp. On Android it also asks for the
  /// binding as it is now: the native side starts watching the networks
  /// before Dart runs, and what it reports in that moment is lost.
  static void listenToNative() {
    final platform = Platform.isIOS ? 'iOS' : 'Android';
    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'trace':
          trace(platform, call.arguments as String);
          return null;
        case 'imagerNetwork':
          _onImagerNetwork(call.arguments);
          return null;
        default:
          trace('WIFI', 'unknown call from $platform: ${call.method}');
          throw MissingPluginException('no Dart handler for ${call.method}');
      }
    });
    if (Platform.isAndroid) {
      _channel.invokeMethod<Object?>('imagerNetwork').then(_onImagerNetwork,
          onError: (Object e) => trace('WIFI', 'imagerNetwork state: $e'));
    }
  }

  static void _onImagerNetwork(Object? arguments) {
    final args = arguments is Map ? arguments : const <Object?, Object?>{};
    final bound = args['bound'] == true;
    final address = args['address']?.toString();
    trace('WIFI', bound
        ? 'Android bound the app to the imager Wi-Fi (address $address)'
        : 'Android unbound the app from the imager Wi-Fi');
    _imagerNetworkBound = bound;
    _imagerNetworkAddress = bound ? address : null;
    _imagerNetworkChanges.add(bound);
  }

  /// iOS: the password the user typed for the last join request, kept until
  /// the imager shows up ([rememberJoinedPassword]) or the next request.
  static String? _typedPasswordInUse;

  /// iOS only. Asks the system to join the strongest nearby network whose
  /// name starts with [archerSsidPrefix]. iOS shows its own "wants to join"
  /// question first; Cancel there gives [WifiJoinResult.cancelled].
  ///
  /// The password: [typedPassword] when the user just typed one, otherwise
  /// the one that last worked after the user typed it (kept in the
  /// keychain), otherwise [archerWifiPassword].
  static Future<WifiJoinResult> joinArcherWifi({String? typedPassword}) async {
    assert(Platform.isIOS, 'joinArcherWifi is implemented on iOS only');
    final remembered =
        typedPassword == null ? await _rememberedPassword() : null;
    final passphrase = typedPassword ?? remembered ?? archerWifiPassword;
    final source = typedPassword != null
        ? 'typed by the user'
        : remembered != null
            ? 'remembered'
            : 'factory';
    _typedPasswordInUse = typedPassword;
    final started = DateTime.now();
    lastJoinRequestAt = started;
    trace('WIFI', 'joinByPrefix("$archerSsidPrefix", $source password '
        '${passphrase.length} chars, forgetFirst='
        '$forgetArcherWifiBeforeJoin) -> iOS');
    try {
      final answer = await _channel.invokeMethod<String>(
        'joinByPrefix',
        <String, Object>{
          'prefix': archerSsidPrefix,
          'passphrase': passphrase,
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

  /// iOS only. The imager showed up after a Connect-button join: if that
  /// join used a password the user typed, keep it in the keychain for the
  /// next joins. Only now, so a mistyped password is never kept. The
  /// network's name labels it when iOS gives one (`currentSsid` in
  /// DeviceWifi.swift; today it gives none).
  static Future<void> rememberJoinedPassword() async {
    final typed = _typedPasswordInUse;
    if (!Platform.isIOS || typed == null) return;
    _typedPasswordInUse = null;
    try {
      final ssid = await _channel.invokeMethod<String>('currentSsid');
      final saved = await _channel.invokeMethod<bool>('rememberPassword',
          <String, Object?>{'ssid': ssid, 'passphrase': typed});
      trace('WIFI', 'the typed password worked on ${ssid ?? 'the imager'}: '
          'kept in the keychain ($saved)');
    } catch (e) {
      trace('WIFI', 'could not keep the typed password: $e');
    }
  }

  static Future<String?> _rememberedPassword() async {
    try {
      return await _channel.invokeMethod<String>('rememberedPassword');
    } catch (e) {
      trace('WIFI', 'could not read the remembered password: $e');
      return null;
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
