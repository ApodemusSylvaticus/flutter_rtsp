package com.archer.archerlink

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

/**
 * The app's only activity. Besides hosting Flutter it owns [DeviceWifi], the
 * native side of the `archer_link/device_wifi` channel, which binds the app's
 * traffic to the imager's Wi-Fi.
 */
class MainActivity : FlutterActivity() {
    private var deviceWifi: DeviceWifi? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        deviceWifi?.dispose()
        deviceWifi = DeviceWifi(this, flutterEngine.dartExecutor.binaryMessenger)
    }

    /** Stops the network watch and unbinds the process while the engine is still attached. */
    override fun onDestroy() {
        deviceWifi?.dispose()
        deviceWifi = null
        super.onDestroy()
    }
}
