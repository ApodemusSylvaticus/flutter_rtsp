# Archer Link

Flutter app that shows the live video of an Archer thermal imager over its
Wi-Fi and controls it.

## Thermal imager Wi-Fi (the Connect button)

The imager's Wi-Fi name starts with `ARCHER_` and always has a password.

- **Android:** Connect opens the system Wi-Fi panel. The user picks the
  imager's network and types the password there; Android saves the network
  and re-joins it on its own later. The Android build holds no password.
- **iOS:** Apple does not allow opening the Wi-Fi settings, so the app joins
  the network itself (`NEHotspotConfiguration`, prefix `ARCHER_`) with the
  factory password compiled into the iOS build from `ios/Runner/Secrets.swift`.
  That file is **not committed**. Create it once per machine before building
  for iOS:

  ```bash
  dart run tool/set_wifi_password.dart
  ```

  The tool asks for the password in the terminal (not echoed) and writes the
  file with the password XOR-encoded. Without the file the Xcode build fails
  with `Build input file cannot be found: .../Secrets.swift`.
- The iOS join needs the *Hotspot Configuration* capability on the App ID.
  The entitlement is already in `ios/Runner/Runner.entitlements`; if signing
  complains, enable the capability once in Xcode under
  Signing & Capabilities.

On both platforms the app does not learn whether the join succeeded: it waits
10 s for the imager's subnet (`192.168.100.x` or `192.168.1.x`) and otherwise
shows the picture explaining how to join by hand.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
