# Archer Link

Flutter app that shows the live video of an Archer thermal imager over its
Wi-Fi and controls it. Published as Archer Link: Android
`com.archer.archerlink`, iOS `com.archer.archerLink`.

## Thermal imager Wi-Fi (the Connect button)

The imager is a Wi-Fi access point without internet. Its network name starts
with `ARCHER`; the factory password is `12345678` (some units ship with
`123456789`). The prefix and the password are constants in
`lib/services/device_wifi.dart`; the password is a basic value, the same on
every imager, so it is kept in plain text.

- **iOS:** Apple does not allow opening the Wi-Fi settings, so the app joins
  the network itself (`NEHotspotConfiguration`, prefix `ARCHER`) with the
  factory password. iOS asks the user first and reports a failed join to the
  user, not to the app. When iOS accepted the join but the imager does not
  come (most likely the password: some units ship with another one, and
  owners can change it), the help comes with a password field. The app
  joins again with the typed password and, once the imager answers, keeps
  it in the Keychain and uses it instead of the factory one from then on.
  The join needs the *Hotspot Configuration*
  capability on the App ID; the entitlement is in
  `ios/Runner/Runner.entitlements`, and if signing complains, enable the
  capability once in Xcode under Signing & Capabilities.
- **Android:** Connect opens the system Wi-Fi panel. The user picks the
  imager's network and types the password there, once: the phone remembers
  it and a tap is enough the next time. Android does not trust a Wi-Fi
  without internet and keeps mobile data as the default network, so the app
  binds its own traffic to the imager's Wi-Fi (`DeviceWifi.kt`); the stream
  does not depend on Android's "no internet" question. The (i) help tells
  the user how to let the phone rejoin the imager by itself.
- **Imager or home router:** being in `192.168.100.x` or `192.168.1.x` is not
  enough, many home routers use these too. Before it shows the stream, the
  app sends one RTSP `OPTIONS` request and needs a reply starting with
  `RTSP/1.0`.
- **Wi-Fi switched off in Settings (iOS):** iOS never answers a join by name
  prefix then, and refuses every later join, of any app, until the phone
  restarts. The Wi-Fi-off guard reads the network interfaces first and, when
  Wi-Fi is off, shows the help instead of sending the request. How it works,
  how to check it on a new iOS and how to remove it:
  `docs/wifi-off-guard.md`. For any other hang, the Connect screen gives up
  and shows the help when iOS sends neither an answer nor its question for
  15 s while the app is on screen.

The app does not learn from the OS whether a join succeeded: it waits 10 s
for the imager and otherwise shows the picture explaining how to join by
hand. Measurements, the reasons behind each choice and the approaches that
were tried and dropped are in `docs/connect-button.md`; the imager's DHCP
bug is described for its firmware in `docs/dhcp-init-reboot-firmware.md`.

### Why it was hard, and why iOS and Android differ

What caused the problems:

- **No internet on the imager's Wi-Fi.** Android keeps mobile data as the
  default network, so the app's traffic went there and the stream timed
  out. It also flags the network "no internet" and does not rejoin it by
  itself; only the user's "Always connect" answer brings it back, and
  Samsung asks that in the full Wi-Fi settings, not over the quick panel.
- **The imager's DHCP bug.** After a restart the imager stays silent when a
  phone rejoins with its old address. iOS keeps that address for ~8 s, then
  drops it for ~4 s: every session dies, and the imager holds the dead ones
  for ~60 s. Android waits for the answer instead and is not hit.
- **The OSes hide the result.** iOS says "accepted" even for a wrong
  password and does not show the app the networks around it. Since
  Android 10 an app cannot switch the phone's Wi-Fi itself; only the
  settings, the Wi-Fi panel and the system's auto-join can.
- **Shared subnets.** Home routers use `192.168.1.x` too, hence the RTSP
  check.

Why the two platforms differ:

- iOS lets an app join a network but not open the settings; Android lets
  it open the Wi-Fi panel but not switch the network. So iOS joins by
  itself and must know the password, while on Android the user picks the
  network and types the password in the panel.
- Each fix targets its own platform's cause. iOS forgets its saved imager
  networks before a join, so DHCP starts fresh and the drop never comes;
  Android binds the app's traffic to the imager's Wi-Fi, so nothing takes
  the mobile-data detour.
- Joining from inside the app on Android (`WifiNetworkSpecifier`, a device
  picker that saves the network) was tried and dropped: a system dialog on
  every join, wrong passwords saved to the phone, and no way to join a
  saved network whose password the app does not know.

## Our native code and the platform folders

`android/` and `ios/` are source code in this project, not generated output:
our own code and settings live there. Do not delete them to recreate them
with `flutter create`. To bring the templates up to date after a Flutter
upgrade, create a fresh project in a temporary folder and carry the
differences over by hand.

Written or changed by hand:

| File | What it is |
| --- | --- |
| `lib/services/device_wifi.dart` | Dart side of the `archer_link/device_wifi` channel |
| `ios/Runner/DeviceWifi.swift` | iOS side of the channel: joins the imager's Wi-Fi, keeps a typed password that worked in the Keychain |
| `lib/services/wifi_off_guard.dart` | Wi-Fi-off guard, Dart side: the rule and its kill switch (`docs/wifi-off-guard.md`) |
| `ios/Runner/WifiOffGuard.swift` | Wi-Fi-off guard, iOS side: reads `awdl0` and the Wi-Fi address |
| `ios/Runner/AppDelegate.swift` | registers `DeviceWifi` and `WifiOffGuard` |
| `ios/Runner/Runner.entitlements` | Hotspot Configuration entitlement (Debug, Profile and Release) |
| `android/app/src/main/kotlin/com/archer/archerlink/DeviceWifi.kt` | Android side of the channel: binds the app's traffic to the imager's Wi-Fi |
| `android/app/src/main/kotlin/com/archer/archerlink/MainActivity.kt` | creates `DeviceWifi` |
| `android/app/src/main/AndroidManifest.xml` | `CHANGE_NETWORK_STATE` permission; alias for the activity's old name `com.example.one_more_try.MainActivity`, which home-screen icons made by older versions point at |
| `packages/flutter_quick_video_encoder/` | our fork of the pub package, see its `FORK.md` |

Never change the store identity: the Android `applicationId`
(`com.archer.archerlink`), the iOS bundle id (`com.archer.archerLink`) and
the signing keys. The Android `namespace` and the Kotlin package may change;
keep the activity alias when they do.

## Stream screen orientation

The stream pages (live and demo) stay in the one landscape with the phone's
camera on the left (`lib/utils/orientation.dart`). Their buttons keep clear
of the camera cutout on the left side only; turned the other way, the
camera covered the right column. Flutter's `DeviceOrientation.landscapeLeft`
puts the camera on opposite sides on the two platforms (on the right on
iOS, on the left on Android), so iOS asks for `landscapeRight` and Android
for `landscapeLeft`.

## Diagnostics

The Connect flow writes `[TRACE hh:mm:ss.mmm TAG]` lines to the log
(`lib/utils/trace.dart`); the native sides send theirs over the channel, so
one `flutter run` shows them all. The trace is on in debug and profile
builds and off in release builds (App Store, Play). The native sides also
write each line to the system log in debug and profile builds only: NSLog
through the `NATIVE_TRACE` compilation condition, which the Runner target
sets for Debug and Profile, and logcat when the app is debuggable.

More detail on request, all off by default:

- `--dart-define=TRACE=true`: the Connect trace in a release build, for a
  problem in the field.
- `--dart-define=CONN_DIAG=true`: stream connection attempts, acks, stalls
  and restarts.
- `--dart-define=MPV_DIAG=true`: mpv's own verbose log.
- `--dart-define=REC_DIAG=true`: video recording timings, real fps and
  decoder state (log prefix `[REC]`, a summary in a notification).
- `--dart-define=NO_STREAM=true`: stays on the Connect page after the phone
  joins the imager, to watch the Wi-Fi without a stream.

On iOS these flags stay in the build settings until the next Flutter
command, and an Archive made in Xcode picks them up: see
[Releasing on iOS](#releasing-on-ios).

## Releasing on iOS

Xcode does not read the version from `pubspec.yaml`. `Info.plist` takes it
from `FLUTTER_BUILD_NAME` and `FLUTTER_BUILD_NUMBER` in
`ios/Flutter/Generated.xcconfig`, a git-ignored file that only Flutter
commands (`flutter run`, `flutter build …`) rewrite. The file also keeps the
`--dart-define` flags of the last such command.

So an Archive made in Xcode after a version bump, or after a `flutter run`
with diagnostic flags, gets the old version and those flags. On 2026-10-20
that gave a `1.0.5 (45)` archive with `CONN_DIAG=true` after the bump to
1.0.6+46. App Store Connect refuses such an archive, because build 45 was
already uploaded.

To release:

1. Raise `version:` in `pubspec.yaml`. The build number after the `+` must
   be higher than the last one uploaded to App Store Connect.
2. Refresh the iOS build settings: `flutter build ios --release --config-only`.
   Or build everything with `flutter build ipa --release`: the archive lands
   in `build/ios/archive/`, the IPA for Transporter in `build/ios/ipa/`.
3. In Xcode, Product > Archive. Skip this step after `flutter build ipa`.
4. In the Organizer, check that the archive shows the new version and build,
   for example `1.0.6 (46)`, before Distribute App > App Store Connect.
