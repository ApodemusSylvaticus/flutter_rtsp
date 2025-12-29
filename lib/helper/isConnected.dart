import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';


Future<String?> getDeviceIP() async {
  try {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLinkLocal: false,
    );
    
    print('=== Network Interfaces ===');
    for (var interface in interfaces) {
      print('${interface.name}: ${interface.addresses.map((a) => a.address).join(', ')}');
    }
    print('==========================');
    
    for (var interface in interfaces) {
      if (interface.name.startsWith('lo') || 
          interface.name.startsWith('tun') ||
          interface.name.startsWith('tap')) {
        continue;
      }
      
      for (var addr in interface.addresses) {
        if (!addr.isLoopback) {
          print('Selected IP: ${addr.address} (${interface.name})');
          return addr.address;
        }
      }
    }
    return null;
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
    return false;
  }

  List<String> octets = ipFromUrl.split('.');
  final actualIp = await getDeviceIP();

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
