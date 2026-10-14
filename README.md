# Archer Link

Flutter app that shows the live video of an Archer thermal imager over its
Wi-Fi and controls it.

## Thermal imager Wi-Fi (the Connect button)

The imager's Wi-Fi name starts with `ARCHER_` and always has a password.

- **Android:** Connect opens the system Wi-Fi panel. The user picks the
  imager's network and types the password there; Android saves the network
  and re-joins it on its own later. Android does not use the password: the user types it in the system Wi-Fi panel.
- **iOS:** Apple does not allow opening the Wi-Fi settings, so the app joins
  the network itself (`NEHotspotConfiguration`, prefix `ARCHER_`) with the
  factory password. The prefix and the password are constants in
  `lib/services/device_wifi.dart`; the password is a basic value, the same on
  every imager, so it is kept in plain text.
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
