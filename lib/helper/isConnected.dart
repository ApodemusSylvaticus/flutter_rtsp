import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:wifi_iot/wifi_iot.dart';

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
    return false;
  }

  List<String> octets = ipFromUrl.split('.');
  final actualIp = await WiFiForIoTPlugin.getIP();

  if (actualIp == null || actualIp == '0.0.0.0' || actualIp == '0.0.0') {
    return false;
  }
  final actualOctets = actualIp.split('.');

  if (actualOctets.length < 3) {
    return false;
  }

  if (octets[0] == actualOctets[0] &&
      octets[1] == actualOctets[1] &&
      octets[2] == actualOctets[2]) {
    return true;
  }
  return false;
}
