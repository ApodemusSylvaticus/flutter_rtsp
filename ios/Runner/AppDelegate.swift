import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "DeviceWifi") {
      DeviceWifi.register(with: registrar)
    }
    // wifi-off-guard: tells Connect whether Wi-Fi is switched off in
    // Settings (docs/wifi-off-guard.md)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "WifiOffGuard") {
      WifiOffGuard.register(with: registrar)
    }
  }
}
