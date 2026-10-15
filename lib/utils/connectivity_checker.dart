import 'package:archer_link/services/device_wifi.dart';
import 'package:archer_link/utils/trace.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Last interface snapshot that was logged; the poll runs every 2 s and
/// only changes are worth a line.
String? _lastInterfaceSnapshot;

Future<String?> getDeviceIP() async {
  // Android: the Wi-Fi the app's traffic is bound to (see DeviceWifi) is
  // the one that counts; the interface list below cannot tell which
  // address the app's sockets actually use.
  if (Platform.isAndroid) {
    final bound = DeviceWifi.imagerNetworkAddress;
    if (bound != null) return bound;
  }
  try {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLinkLocal: false,
    );
    final snapshot = interfaces
        .map((i) => '${i.name}=${i.addresses.map((a) => a.address).join('/')}')
        .join(' ');
    if (snapshot != _lastInterfaceSnapshot) {
      _lastInterfaceSnapshot = snapshot;
      trace('NET', 'IPv4 interfaces: ${snapshot.isEmpty ? '(none)' : snapshot}');
    }
    
    // Log all interfaces
    // print('=== Network Interfaces ===');
    // for (var interface in interfaces) {
    //   print('${interface.name}: ${interface.addresses.map((a) => a.address).join(', ')}');
    // }
    // print('==========================');
    
    // Priority: Wi-Fi interfaces
    final wifiNames = ['en0', 'en1', 'wlan0', 'wlan1'];
    
    // Skip system/service interfaces
    final skipPrefixes = ['lo', 'tun', 'tap', 'pdp_ip', 'ipsec', 'utun', 'rmnet'];
    
    String? wifiIP;
    String? fallbackIP;
    
    for (var interface in interfaces) {
      final name = interface.name;
      
      for (var addr in interface.addresses) {
        if (addr.isLoopback) continue;
        
        final ip = addr.address;
        
        // Wi-Fi interface — save as priority
        if (wifiNames.contains(name)) {
          wifiIP = ip;
        }
        // Non-service interface — save as fallback
        else if (!skipPrefixes.any((p) => name.startsWith(p))) {
          fallbackIP ??= ip;
        }
      }
    }
    
    final selectedIP = wifiIP ?? fallbackIP;

    
    return selectedIP;
  } catch (e) {
    print('Error getting IP: $e');
    return null;
  }
}

String? extractIP(String input) {
  final RegExp ipRegex = RegExp(
      r'\b((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b');

  final Match? match = ipRegex.firstMatch(input);

  return match?.group(0);
}


Future<bool> connectivityCheck() async {
  List<ConnectivityResult> results = await Connectivity().checkConnectivity();
  
  return results.contains(ConnectivityResult.wifi) ||
      results.contains(ConnectivityResult.ethernet) ||
      results.contains(ConnectivityResult.vpn) ||
      results.contains(ConnectivityResult.mobile);
}

Future<bool> isConnected(
  String url,
) async {
  final ipFromUrl = extractIP(url);
  if (ipFromUrl == null) {
    print('[CONN] isConnected: could not extract IP from url=$url');
    return false;
  }

  List<String> octets = ipFromUrl.split('.');
  final actualIp = await getDeviceIP();

  if (actualIp == null || actualIp == '0.0.0.0' || actualIp == '0.0.0') {
    print('[CONN] isConnected: device IP invalid or null (actualIp=$actualIp, targetIp=$ipFromUrl)');
    return false;
  }
  final actualOctets = actualIp.split('.');

  if (actualOctets.length < 3) {
    print('[CONN] isConnected: actualIp has <3 octets ($actualIp)');
    return false;
  }

  if (octets[0] == actualOctets[0] &&
      octets[1] == actualOctets[1] &&
      octets[2] == actualOctets[2]) {
    print('[CONN] isConnected: subnet match OK (device=$actualIp, target=$ipFromUrl)');
    return true;
  }
  print('[CONN] isConnected: subnet MISMATCH (device=$actualIp, target=$ipFromUrl)');
  return false;
}

/// Port the player connects to when the stream URL names none.
const int _defaultRtspPort = 554;

/// One deadline for the whole probe: connect, request and reply. The
/// imager answers in 130-200 ms (measured on the S24+ on 2026-10-14); a
/// home router refuses at once.
const Duration _rtspProbeTimeout = Duration(milliseconds: 1500);

const String _rtspReplyStart = 'RTSP/1.0';

/// Host and port of the RTSP server behind [streamUrl], written the way
/// StreamConfig keeps it, without the scheme ('192.168.100.1/stream0',
/// '192.168.1.1:555//ir.sdp'). Null when it cannot be parsed.
({String host, int port})? rtspEndpoint(String streamUrl) {
  if (streamUrl.isEmpty) return null;
  try {
    final uri = Uri.parse('rtsp://$streamUrl');
    if (uri.host.isEmpty) return null;
    return (host: uri.host, port: uri.hasPort ? uri.port : _defaultRtspPort);
  } on FormatException {
    return null;
  }
}

/// Whether an RTSP server really answers behind [streamUrl]: sends the one
/// request the player would send first, `OPTIONS rtsp://<streamUrl>`, and
/// accepts only a reply that starts with `RTSP/1.0`.
///
/// Why: being in a device subnet is not enough. Many home routers are
/// 192.168.1.1 too, and the app then showed the stream page (and only a
/// Reconnect button) on a home network. A router refuses the port at once;
/// the imager answers. OPTIONS opens no session on the imager, unlike a
/// WebSocket, which the imager would hold for about a minute.
///
/// Gives up after [_rtspProbeTimeout] in total and always closes the
/// socket. Never throws.
Future<bool> probeRtsp(String streamUrl) async {
  final endpoint = rtspEndpoint(streamUrl);
  if (endpoint == null) {
    trace('NET', 'RTSP probe: cannot read host and port from "$streamUrl"');
    return false;
  }
  final target = '${endpoint.host}:${endpoint.port}';
  final watch = Stopwatch()..start();
  Socket? socket;
  StreamSubscription<List<int>>? subscription;
  var answered = false;
  String outcome;
  try {
    // Socket.connect cancels the attempt itself when its timeout fires, so
    // nothing is left connecting behind the probe.
    socket = await Socket.connect(endpoint.host, endpoint.port,
        timeout: _rtspProbeTimeout);
    // A write error also completes `done` with that error; it is reported
    // through the reply below, not as an unhandled error.
    socket.done.ignore();
    final reply = Completer<String>();
    final received = <int>[];
    subscription = socket.listen(
      (List<int> data) {
        received.addAll(data);
        if (received.length >= _rtspReplyStart.length && !reply.isCompleted) {
          reply.complete(latin1.decode(received));
        }
      },
      onError: (Object e) {
        if (!reply.isCompleted) reply.completeError(e);
      },
      onDone: () {
        if (!reply.isCompleted) reply.complete(latin1.decode(received));
      },
      cancelOnError: true,
    );
    socket.write('OPTIONS rtsp://$streamUrl RTSP/1.0\r\nCSeq: 1\r\n\r\n');
    final left = _rtspProbeTimeout - watch.elapsed;
    final head =
        await reply.future.timeout(left.isNegative ? Duration.zero : left);
    answered = head.startsWith(_rtspReplyStart);
    var firstLine = head.split('\r\n').first;
    if (firstLine.length > 60) firstLine = '${firstLine.substring(0, 60)}...';
    outcome = answered
        ? 'answered "$firstLine"'
        : head.isEmpty
            ? 'closed without a reply'
            : 'not RTSP: "$firstLine"';
  } on TimeoutException {
    outcome = 'no reply';
  } on SocketException catch (e) {
    outcome = e.osError?.message ?? e.message;
  } catch (e) {
    outcome = '$e';
  } finally {
    await subscription?.cancel();
    socket?.destroy();
  }
  trace('NET', 'RTSP probe $target ${answered ? 'OK' : 'FAILED'}: $outcome '
      '(${watch.elapsedMilliseconds} ms)');
  return answered;
}
