import Flutter
import Network
import NetworkExtension
import UIKit

/// Joins the thermal imager's Wi-Fi on request from Dart (channel
/// `archer_link/device_wifi`, see lib/services/device_wifi.dart). iOS only:
/// on Android the user joins through the system Wi-Fi panel instead.
///
/// The SSID prefix and the password come with the call; both are constants
/// in lib/services/device_wifi.dart.
///
/// Everything here is traced: each line goes to NSLog and, through the
/// channel ("trace" calls), to Dart, which prints it as `[TRACE ... iOS]`
/// next to its own lines. `flutter run` does not show NSLog from the
/// device, so without the channel the native side would be invisible.
final class DeviceWifi: NSObject, FlutterPlugin {
  private static let wifiPath = NWPathMonitor(requiredInterfaceType: .wifi)
  private static let defaultPath = NWPathMonitor()
  private static let pathQueue = DispatchQueue(label: "archer_link.device_wifi.paths")
  private static var channel: FlutterMethodChannel?

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "archer_link/device_wifi", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(DeviceWifi(), channel: channel)
    DeviceWifi.channel = channel
    startPathTrace()
  }

  /// Logs every change of the Wi-Fi path and of the default path: the first
  /// shows when the phone gets onto a Wi-Fi, the second when that Wi-Fi
  /// becomes the route the app's traffic takes.
  private static func startPathTrace() {
    wifiPath.pathUpdateHandler = { path in trace("wifi path: \(describe(path))") }
    defaultPath.pathUpdateHandler = { path in trace("default path: \(describe(path))") }
    wifiPath.start(queue: pathQueue)
    defaultPath.start(queue: pathQueue)
  }

  private static func describe(_ path: Network.NWPath) -> String {
    let interfaces = path.availableInterfaces
      .map { "\($0.name)(\($0.type))" }.joined(separator: ",")
    let gateways = path.gateways.map { "\($0)" }.joined(separator: ",")
    return "status=\(path.status) interfaces=[\(interfaces)] gateways=[\(gateways)]"
      + " ipv4=\(path.supportsIPv4) expensive=\(path.isExpensive)"
  }

  static func trace(_ message: String) {
    NSLog("[TRACE-iOS] %@", message)
    DispatchQueue.main.async {
      channel?.invokeMethod("trace", arguments: message)
    }
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "joinByPrefix":
      guard let args = call.arguments as? [String: Any],
        let prefix = args["prefix"] as? String, !prefix.isEmpty,
        let passphrase = args["passphrase"] as? String, !passphrase.isEmpty
      else {
        DeviceWifi.trace("joinByPrefix: bad arguments \(String(describing: call.arguments))")
        result(FlutterError(
          code: "badArgs", message: "prefix and passphrase are required", details: nil))
        return
      }
      // Missing flag = forget, the behaviour the Dart side defaults to.
      let forgetFirst = args["forgetFirst"] as? Bool ?? true
      join(prefix: prefix, passphrase: passphrase, forgetFirst: forgetFirst, result: result)
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
  private func join(
    prefix: String, passphrase: String, forgetFirst: Bool, result: @escaping FlutterResult
  ) {
    // The completion may arrive on any queue; Flutter wants replies on the
    // main thread.
    let reply: (Any?) -> Void = { value in DispatchQueue.main.async { result(value) } }

    DeviceWifi.trace(
      "joinByPrefix(\"\(prefix)\", password \(passphrase.count) chars, forgetFirst=\(forgetFirst))"
        + " on iOS " + UIDevice.current.systemVersion)
    DeviceWifi.trace("wifi path now: \(DeviceWifi.describe(DeviceWifi.wifiPath.currentPath))")
    DeviceWifi.trace("default path now: \(DeviceWifi.describe(DeviceWifi.defaultPath.currentPath))")
    let config = NEHotspotConfiguration(
      ssidPrefix: prefix, passphrase: passphrase, isWEP: false)
    // Keep the network in the phone's known list so iOS re-joins it on its
    // own, also after the app returns from the background. With `true`
    // iOS drops the network about 15 s after the app leaves the foreground.
    config.joinOnce = false

    NEHotspotConfigurationManager.shared.getConfiguredSSIDs { ssids in
      DeviceWifi.trace("networks this app has configured before: \(ssids)")
      // iOS keeps the DHCP lease of a known network and asks the imager to
      // confirm it on the next join (DHCP INIT-REBOOT). The imager forgets
      // its leases when it restarts and stays silent on that request, so
      // iOS drops the address ~8 s after the join and every session dies.
      // Forgetting the network first makes iOS start from DHCPDISCOVER,
      // which the imager always answers (verified by hand on 2026-10-12).
      // The switch lives in Dart: `forgetArcherWifiBeforeJoin`.
      if forgetFirst {
        for ssid in ssids where ssid.hasPrefix(prefix) {
          DeviceWifi.trace("removing saved configuration \"\(ssid)\" so DHCP starts from DISCOVER")
          NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: ssid)
        }
      } else {
        DeviceWifi.trace("keeping saved configurations: forgetFirst is off")
      }
      DeviceWifi.apply(config, reply: reply)
    }
  }

  private static func apply(_ config: NEHotspotConfiguration, reply: @escaping (Any?) -> Void) {
    let started = Date()
    DeviceWifi.trace("apply() called (joinOnce=\(config.joinOnce))")
    NEHotspotConfigurationManager.shared.apply(config) { error in
      let ms = Int(Date().timeIntervalSince(started) * 1000)
      guard let error = error as NSError? else {
        DeviceWifi.trace("apply() completed without error after \(ms) ms -> accepted")
        DeviceWifi.traceCurrentNetwork()
        reply("accepted")
        return
      }
      let name = error.domain == NEHotspotConfigurationErrorDomain
        ? DeviceWifi.errorName(error.code) : "\(error.domain)#\(error.code)"
      DeviceWifi.trace(
        "apply() failed after \(ms) ms: domain=\(error.domain) code=\(error.code) (\(name))"
          + " description=\"\(error.localizedDescription)\" userInfo=\(error.userInfo)")
      DeviceWifi.traceCurrentNetwork()
      guard error.domain == NEHotspotConfigurationErrorDomain else {
        reply(FlutterError(code: name, message: error.localizedDescription, details: nil))
        return
      }
      switch error.code {
      case NEHotspotConfigurationError.alreadyAssociated.rawValue:
        DeviceWifi.trace("-> alreadyConnected")
        reply("alreadyConnected")
      case NEHotspotConfigurationError.userDenied.rawValue:
        DeviceWifi.trace("-> cancelled")
        reply("cancelled")
      default:
        DeviceWifi.trace("-> error \(name)")
        reply(FlutterError(
          code: name,
          message: "\(error.domain) code \(error.code): \(error.localizedDescription)",
          details: nil))
      }
    }
  }

  /// The network the phone is on, as far as the app may see it: without
  /// location access iOS only names networks this app configured itself.
  private static func traceCurrentNetwork() {
    NEHotspotNetwork.fetchCurrent { network in
      guard let network = network else {
        trace("current Wi-Fi: none visible to the app")
        return
      }
      trace(
        "current Wi-Fi: ssid=\"\(network.ssid)\" bssid=\(network.bssid)"
          + " signal=\(network.signalStrength) secure=\(network.isSecure)")
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
