package com.archer.archerlink

import android.content.Context
import android.content.pm.ApplicationInfo
import android.net.ConnectivityManager
import android.net.LinkProperties
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.net.Inet4Address

/**
 * The Android side of the channel `archer_link/device_wifi`
 * (lib/services/device_wifi.dart; the iOS side is ios/Runner/DeviceWifi.swift).
 *
 * The user joins the imager's Wi-Fi in the system Wi-Fi panel; this class
 * makes the app actually use it. Android does not trust a Wi-Fi without
 * internet: it keeps mobile data as the default network, so the app's
 * sockets to 192.168.100.1 go out over mobile data and time out (measured on
 * a Galaxy S24+, Android 16: a 4 s timeout and Reconnect on every join, and
 * no stream at all while "switch to mobile data" is on). So while the phone
 * is on a Wi-Fi with an address in a device subnet, the whole process (Dart's
 * sockets and libmpv's alike) is bound to that Wi-Fi, whatever network
 * Android uses as the default. Dart hears about each change through
 * `imagerNetwork` calls, and asks for the current state with the
 * `imagerNetwork` method when it starts (anything sent before Dart runs is
 * lost).
 *
 * Every step is traced: each line goes, through the channel ("trace" calls),
 * to Dart, which prints it next to its own lines, like the iOS side does
 * (not in release builds, see lib/utils/trace.dart). Debuggable builds
 * (debug, profile) also send each line to logcat with the tag TRACE-Android;
 * a release build sends none.
 *
 * Main thread only: the network callbacks are delivered on the main looper.
 */
class DeviceWifi(context: Context, messenger: BinaryMessenger) : MethodChannel.MethodCallHandler {
    companion object {
        private const val CHANNEL = "archer_link/device_wifi"
        private const val TAG = "TRACE-Android"

        /**
         * The phone's address on a device Wi-Fi: 192.168.100.x (the imager is
         * .1) or 192.168.1.x (the other device family). Many home routers hand
         * out 192.168.1.x too; binding to such a Wi-Fi does no harm, since a
         * home Wi-Fi with internet is the default network anyway, and the
         * Dart side tells a device from a router by an RTSP probe.
         */
        private val DEVICE_SUBNET_PREFIXES = listOf("192.168.100.", "192.168.1.")

        /**
         * The instance that may undo the binding. The process outlives the
         * activity; an old activity destroyed after a new one has started must
         * not unbind the new one's network.
         */
        private var current: DeviceWifi? = null
    }

    private val channel = MethodChannel(messenger, CHANNEL)
    private val mainHandler = Handler(Looper.getMainLooper())

    /** Whether trace lines go to logcat too: in debuggable builds (debug, profile) only. */
    private val logcat = (context.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
    private val connectivity: ConnectivityManager =
        requireNotNull(context.getSystemService(ConnectivityManager::class.java)) { "no ConnectivityManager" }

    /** The device Wi-Fi the process is bound to, and the phone's address on it. */
    private var boundNetwork: Network? = null
    private var boundAddress: String? = null

    /** What was last traced, so repeated callbacks do not flood the trace. */
    private val addressesTraced = HashMap<Network, String>()
    private var defaultTraced: String? = null

    /**
     * Follows the Wi-Fi and binds the process to it while it has an address
     * in a device subnet. A request rather than a plain listen: it also tells
     * Android that the app wants this Wi-Fi, so Android does not drop it as
     * unneeded while mobile data is the default. Requested without INTERNET,
     * so a Wi-Fi without internet (the imager's) matches too.
     */
    private val wifiCallback = object : ConnectivityManager.NetworkCallback() {
        override fun onAvailable(network: Network) {
            trace("wifi $network available")
            val previous = boundNetwork
            consider(network, connectivity.getLinkProperties(network))
            // The request follows one Wi-Fi at a time: when Android moves it
            // to another one, the old network gets no onLost here.
            if (previous != null && previous != network && boundNetwork == previous) {
                unbind("the wifi request moved from $previous to $network")
            }
        }

        override fun onLinkPropertiesChanged(network: Network, linkProperties: LinkProperties) {
            consider(network, linkProperties)
        }

        override fun onLost(network: Network) {
            trace("wifi $network lost")
            addressesTraced.remove(network)
            if (network == boundNetwork) unbind("wifi $network was lost")
        }
    }

    /** Trace only: which network Android sends unbound traffic to. */
    private val defaultCallback = object : ConnectivityManager.NetworkCallback() {
        override fun onCapabilitiesChanged(network: Network, caps: NetworkCapabilities) {
            val text = "${describe(caps)} ($network)"
            if (text == defaultTraced) return
            defaultTraced = text
            trace("default network: $text")
        }

        override fun onLost(network: Network) {
            defaultTraced = null
            trace("default network $network lost")
        }
    }

    init {
        current = this
        channel.setMethodCallHandler(this)
        trace(
            "Android ${Build.VERSION.RELEASE} (API ${Build.VERSION.SDK_INT}), " +
                "${Build.MANUFACTURER} ${Build.MODEL}; process bound to " +
                "${connectivity.boundNetworkForProcess ?: "nothing"}",
        )
        val request = NetworkRequest.Builder()
            .addTransportType(NetworkCapabilities.TRANSPORT_WIFI)
            .removeCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
            .build()
        try {
            connectivity.requestNetwork(request, wifiCallback, mainHandler)
            connectivity.registerDefaultNetworkCallback(defaultCallback, mainHandler)
        } catch (e: RuntimeException) {
            trace("could not watch the networks: $e; the app will not bind to the imager Wi-Fi")
        }
    }

    /** Stops watching and unbinds. MainActivity calls it from onDestroy. */
    fun dispose() {
        channel.setMethodCallHandler(null)
        unregister(wifiCallback)
        unregister(defaultCallback)
        if (current !== this) return
        current = null
        if (boundNetwork != null) {
            val ok = connectivity.bindProcessToNetwork(null)
            if (logcat) Log.i(TAG, "bindProcessToNetwork(null) because the activity is destroyed -> $ok")
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "imagerNetwork" -> result.success(imagerNetworkState())
            else -> result.notImplemented()
        }
    }

    /** Binds to [network] when it has an address in a device subnet, unbinds when it no longer has one. */
    private fun consider(network: Network, linkProperties: LinkProperties?) {
        val addresses = linkProperties?.linkAddresses.orEmpty()
            .mapNotNull { (it.address as? Inet4Address)?.hostAddress }
        val text = addresses.joinToString(",", "[", "]")
        if (addressesTraced.put(network, text) != text) trace("wifi $network IPv4: $text")

        val deviceAddress = addresses.firstOrNull { a -> DEVICE_SUBNET_PREFIXES.any { a.startsWith(it) } }
        when {
            deviceAddress != null && network != boundNetwork -> bind(network, deviceAddress)
            deviceAddress != null -> boundAddress = deviceAddress
            network == boundNetwork -> unbind("wifi $network left the device subnets")
        }
    }

    /**
     * Sends every socket the process opens from now on (Dart's and libmpv's,
     * DNS included) over this Wi-Fi, whatever network Android uses as the
     * default. Sockets opened before keep their network.
     */
    private fun bind(network: Network, address: String) {
        val ok = connectivity.bindProcessToNetwork(network)
        trace("bindProcessToNetwork(wifi $network, address $address) -> $ok")
        if (!ok) return // Tried again on the next callback for this network.
        boundNetwork = network
        boundAddress = address
        channel.invokeMethod("imagerNetwork", imagerNetworkState())
    }

    /** Gives the process back to the default network; a binding to a lost network would leave it without any. */
    private fun unbind(why: String) {
        val ok = connectivity.bindProcessToNetwork(null)
        trace("bindProcessToNetwork(null) because $why -> $ok")
        boundNetwork = null
        boundAddress = null
        channel.invokeMethod("imagerNetwork", imagerNetworkState())
    }

    private fun imagerNetworkState() =
        hashMapOf<String, Any?>("bound" to (boundNetwork != null), "address" to boundAddress)

    private fun unregister(callback: ConnectivityManager.NetworkCallback) {
        try {
            connectivity.unregisterNetworkCallback(callback)
        } catch (e: IllegalArgumentException) {
            // Never registered: watching had failed at start.
        }
    }

    private fun describe(caps: NetworkCapabilities): String {
        val transport = when {
            caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> "wifi"
            caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> "cellular"
            caps.hasTransport(NetworkCapabilities.TRANSPORT_VPN) -> "vpn"
            else -> "other"
        }
        return "$transport validated=${caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)}"
    }

    private fun trace(message: String) {
        if (logcat) Log.i(TAG, message)
        channel.invokeMethod("trace", message)
    }
}
