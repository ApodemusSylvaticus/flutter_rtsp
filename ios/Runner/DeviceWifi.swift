import Flutter
import NetworkExtension

/// Joins the thermal imager's Wi-Fi on request from Dart (channel
/// `archer_link/device_wifi`, see lib/services/device_wifi.dart). iOS only:
/// on Android the user joins through the system Wi-Fi panel instead.
///
/// The password comes from Secrets.swift, a gitignored file written by
/// `dart run tool/set_wifi_password.dart`.
final class DeviceWifi: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "archer_link/device_wifi", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(DeviceWifi(), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "joinByPrefix":
      guard let args = call.arguments as? [String: Any],
        let prefix = args["prefix"] as? String, !prefix.isEmpty
      else {
        result(FlutterError(code: "badArgs", message: "prefix is required", details: nil))
        return
      }
      join(prefix: prefix, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// Asks iOS to join the strongest nearby network whose name starts with
  /// `prefix`. iOS first shows its own "wants to join" question.
  ///
  /// The completion fires once iOS has accepted the request, not once the
  /// phone is on the network. A wrong password or no network in range is
  /// reported to the user by an iOS alert and never to the app, so the Dart
  /// side confirms the join by waiting for the imager's subnet.
  ///
  /// Answers: "accepted", "alreadyConnected", "cancelled" (the user tapped
  /// Cancel), or a FlutterError whose code names the iOS error.
  private func join(prefix: String, result: @escaping FlutterResult) {
    let config = NEHotspotConfiguration(
      ssidPrefix: prefix, passphrase: Secrets.archerWifiPassword, isWEP: false)
    // Keep the network in the phone's known list so iOS re-joins it on its
    // own, also after the app returns from the background. With `true`
    // iOS drops the network about 15 s after the app leaves the foreground.
    config.joinOnce = false

    NEHotspotConfigurationManager.shared.apply(config) { error in
      guard let error = error as NSError? else {
        result("accepted")
        return
      }
      switch error.code {
      case NEHotspotConfigurationError.alreadyAssociated.rawValue:
        result("alreadyConnected")
      case NEHotspotConfigurationError.userDenied.rawValue:
        result("cancelled")
      default:
        result(FlutterError(
          code: DeviceWifi.errorName(error.code),
          message: error.localizedDescription, details: nil))
      }
    }
  }

  private static let errorNames: [Int: String] = [
    NEHotspotConfigurationError.invalid.rawValue: "invalid",
    NEHotspotConfigurationError.invalidSSID.rawValue: "invalidSSID",
    NEHotspotConfigurationError.invalidWPAPassphrase.rawValue: "invalidWPAPassphrase",
    NEHotspotConfigurationError.invalidWEPPassphrase.rawValue: "invalidWEPPassphrase",
    NEHotspotConfigurationError.invalidEAPSettings.rawValue: "invalidEAPSettings",
    NEHotspotConfigurationError.invalidHS20Settings.rawValue: "invalidHS20Settings",
    NEHotspotConfigurationError.invalidHS20DomainName.rawValue: "invalidHS20DomainName",
    NEHotspotConfigurationError.userDenied.rawValue: "userDenied",
    NEHotspotConfigurationError.internal.rawValue: "internal",
    NEHotspotConfigurationError.pending.rawValue: "pending",
    NEHotspotConfigurationError.systemConfiguration.rawValue: "systemConfiguration",
    NEHotspotConfigurationError.unknown.rawValue: "unknown",
    NEHotspotConfigurationError.joinOnceNotSupported.rawValue: "joinOnceNotSupported",
    NEHotspotConfigurationError.alreadyAssociated.rawValue: "alreadyAssociated",
    NEHotspotConfigurationError.applicationIsNotInForeground.rawValue: "applicationIsNotInForeground",
    NEHotspotConfigurationError.invalidSSIDPrefix.rawValue: "invalidSSIDPrefix",
  ]

  private static func errorName(_ code: Int) -> String {
    errorNames[code] ?? "unknown(\(code))"
  }
}
