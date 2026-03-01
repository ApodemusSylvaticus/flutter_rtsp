import 'dart:typed_data';
import 'package:archer_link/proto/archer_protocol.pb.dart';

/// Mock command service for demo mode.
/// Simulates device communication by maintaining internal state
/// and responding to protobuf commands like the real device would.
class MockCommandService {
  // Internal mutable state
  Zoom _zoom = Zoom.ZOOM_X1;
  ColorScheme _colorScheme = ColorScheme.WHITE_HOT;
  AGCMode _agcMode = AGCMode.AUTO_1;
  final int _charge = 85;
  final int _distance = 100;

  /// Current device status as protobuf object
  HostDevStatus get currentDevStatus => HostDevStatus(
        charge: _charge,
        zoom: _zoom,
        airTemp: 22,
        airHum: 45,
        airPress: 1013,
        powderTemp: 20,
        windDir: 0,
        windSpeed: 0,
        pitch: 0,
        cant: 0,
        distance: _distance,
        currentProfile: 1,
        colorScheme: _colorScheme,
        modAGC: _agcMode,
        maxZoom: Zoom.ZOOM_X6,
      );

  /// Process an incoming command buffer (same format as WebSocket sends).
  /// Returns serialized HostPayload with updated devStatus.
  Uint8List processCommand(Uint8List buffer) {
    try {
      final clientPayload = ClientPayload.fromBuffer(buffer);

      if (clientPayload.hasCommand()) {
        final command = clientPayload.command;

        switch (command.whichOneofCommand()) {
          case Command_OneofCommand.setZoom:
            _zoom = command.setZoom.zoomLevel;
            break;
          case Command_OneofCommand.setPallette:
            _colorScheme = command.setPallette.scheme;
            break;
          case Command_OneofCommand.setAgc:
            _agcMode = command.setAgc.mode;
            break;
          case Command_OneofCommand.getHostDevStatus:
            // Just return current status, no state change
            break;
          case Command_OneofCommand.cmdTrigger:
            // Calibration — acknowledge, no state change
            break;
          default:
            // Other commands — acknowledge without change
            break;
        }
      }
    } catch (_) {
      // Malformed buffer — return current status anyway
    }

    final hostPayload = HostPayload(devStatus: currentDevStatus);
    return Uint8List.fromList(hostPayload.writeToBuffer());
  }
}
