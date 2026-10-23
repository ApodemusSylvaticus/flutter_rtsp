import Flutter
import Foundation

/// The native half of the Wi-Fi-off guard (docs/wifi-off-guard.md). It
/// reads two facts about the phone's network interfaces and decides nothing;
/// the rule is in lib/services/wifi_off_guard.dart.
///
/// Channel `archer_link/wifi_off_guard`, method `readInterfaces`, answer
/// `{"awdl": "up" | "down" | "missing", "wifiAddress": "192.168.100.115" or ""}`:
/// - `awdl`: the state of awdl0, the interface of AirDrop and AirPlay. iOS
///   keeps it up while the Wi-Fi radio is on and takes it down when Wi-Fi is
///   switched off in Settings (gray tile in Control Center). Wi-Fi switched
///   off in Control Center (white tile) leaves the radio on, and awdl0 up.
///   "missing" when the phone has no awdl0 at all.
/// - `wifiAddress`: the IPv4 address of en0, the Wi-Fi interface, or "" when
///   the phone is on no Wi-Fi network.
///
/// A plugin and a file of its own, apart from DeviceWifi, so that the guard
/// comes out whole: see "How to remove" in the doc.
final class WifiOffGuard: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "archer_link/wifi_off_guard", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(WifiOffGuard(), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "readInterfaces":
      result(WifiOffGuard.readInterfaces())
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private static func readInterfaces() -> [String: String] {
    var awdl = "missing"
    var wifiAddress = ""
    var head: UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&head) == 0 else {
      return ["awdl": awdl, "wifiAddress": wifiAddress]
    }
    defer { freeifaddrs(head) }

    // getifaddrs lists an interface once per address; every entry carries
    // the interface's flags.
    var cursor = head
    while let entry = cursor {
      cursor = entry.pointee.ifa_next
      let name = String(cString: entry.pointee.ifa_name)
      if name == "awdl0" {
        awdl = entry.pointee.ifa_flags & UInt32(IFF_UP) != 0 ? "up" : "down"
      } else if name == "en0", let address = entry.pointee.ifa_addr,
        Int32(address.pointee.sa_family) == AF_INET
      {
        var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        if getnameinfo(
          address, socklen_t(address.pointee.sa_len), &host, socklen_t(host.count),
          nil, 0, NI_NUMERICHOST) == 0
        {
          wifiAddress = host.withUnsafeBufferPointer { String(cString: $0.baseAddress!) }
        }
      }
    }
    return ["awdl": awdl, "wifiAddress": wifiAddress]
  }
}
