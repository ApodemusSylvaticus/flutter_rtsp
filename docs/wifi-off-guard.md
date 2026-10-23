# Wi-Fi-off guard (iOS)

Keeps the Connect button from sending a join request that iOS hangs on. It works around an iOS bug and is meant to be easy to take out once Apple fixes it, or once the sign it relies on stops working.
- **Code:** two files of its own, [lib/services/wifi_off_guard.dart](../lib/services/wifi_off_guard.dart) and [ios/Runner/WifiOffGuard.swift](../ios/Runner/WifiOffGuard.swift).
- **Outside them:** three places, marked `wifi-off-guard` or naming the guard ([How to remove](#how-to-remove)).
- **Archer BC:** has the same guard in `modules/wifi-off-guard`. It was checked there on the same phone on 2026-10-19.
- **Checked in Link** on the same phone on 2026-10-20:
  - gray tile: the help came up and no request was sent;
  - blue tile: the request went to iOS, which answered `code 11` after 3 s because no imager was nearby.

## The iOS bug

Connect joins the imager's Wi-Fi with `NEHotspotConfiguration(ssidPrefix: "ARCHER", passphrase:, isWEP: false)` ([ios/Runner/DeviceWifi.swift](../ios/Runner/DeviceWifi.swift)). When Wi-Fi is switched off in **Settings**, iOS never finishes that request.

The iPhone's system log for one Connect with Wi-Fi off in Settings (2026-10-19 17:29:58, iPhone 16 Pro, iOS 27.0). The request came from Archer BC, but Link makes the same call:

```
wifid  WiFiManagerAddNetworkAsync: adding ssid='ARCHER' bundleId='com.archer.archerBC' ...
wifid  WiFiManagerAddNetworkAsync: Add network async- prompting for user consent
wifid  __WiFiManagerDispatchNextAddNetworkAsyncRequest: add network request using prefix, checking if matching network is nearby
wifid  WiFiDeviceManagerAddNetworkScan: starting forced association scan for <redacted>
wifid  Error initiating scan request: 82
```

With a name prefix, iOS first scans for a matching network. The scan cannot start with the radio off (error 82), and nothing happens after that. iOS shows no question, the app gets no answer, and Connect stays on "Connecting...".

iOS keeps that request open. Every later join request, from any app, fails within milliseconds. The app gets `internal` (code 8), and the system log shows:

```
nehelper  NEHelperHotspotConfigurationManager WiFiManagerClientAddNetworkAsync() failed: 37
```

Error 37 is probably `EALREADY`, "operation already in progress".
- **Doesn't help:** turning Wi-Fi back on, restarting the app, forgetting the network, restarting the imager.
- **Helps:** restarting the phone.
- **Still works meanwhile:** joining the imager in Settings > Wi-Fi.

What Link went through on 2026-10-19:
- **16:49–16:50.** Link's joins failed instantly while a BC request from 16:43 was stuck. The phone was restarted at 16:51, and Link joined at 16:54.
- **Evening.** Link itself, with the gray tile: Connect stayed on "Connecting..." with no question, and joins kept failing until the phone was restarted.

Wi-Fi switched off in **Control Center** (white tile) is not affected. That leaves the radio on: the scan runs, iOS asks to join, and Wi-Fi comes back on.

The bug is public and old, and nobody has a fix:
- [Apple Developer Forums 735642](https://developer.apple.com/forums/thread/735642) (2023, iOS 16.6): with Wi-Fi off in Settings, `apply` with `ssidPrefix` and `isWEP: false` never completes, and later calls return "internal error". It doesn't happen with an exact SSID. Apple didn't answer.
- [react-native-wifi-reborn #206](https://github.com/JuanSeBestia/react-native-wifi-reborn/issues/206) (2021, iOS 13): `connectToProtectedSSIDPrefix` fails with "internal error" after Wi-Fi was switched off in Settings, even once it's back on. Other people kept reporting it until 2023.

Joining by the exact SSID would avoid the bug, but the app does not know the imager's name, so it was not an option.

## How the guard works

iOS has no API that says whether Wi-Fi is switched on ([TN3111](https://developer.apple.com/documentation/technotes/tn3111-ios-wifi-api-overview)). The guard reads the network interfaces just before a join instead ([WifiOffGuard.swift](../ios/Runner/WifiOffGuard.swift), channel `archer_link/wifi_off_guard`):

- `awdl0` is the interface of AirDrop and AirPlay. iOS keeps it up while the Wi-Fi radio is on.
- `en0` is the Wi-Fi interface. Its IPv4 address means the phone is on some Wi-Fi network.

What they showed on 2026-10-19 (iPhone 16 Pro, iOS 27.0):

| Wi-Fi | Control Center tile | en0 | awdl0 |
|---|---|---|---|
| on, no network | blue | up, no address | up |
| on, joined to the imager | blue | up, 192.168.100.115 | up |
| off in Control Center | white | up, no address | up |
| off in Settings | gray | up, no address | **down** |

`en0` stays up in every state, so the guard reads only its address. `awdl0` goes down only in the case that hangs.

The rule ([wifi_off_guard.dart](../lib/services/wifi_off_guard.dart)):

| Reading | Decision |
|---|---|
| en0 has an address | Wi-Fi is on: join |
| awdl0 up | Wi-Fi is on: join |
| no awdl0, or no reading | unknown: join, as before the guard |
| awdl0 down, en0 has no address | off in Settings: no join request |

The check runs at the start of `_connectIos` in [wifi_connect_screen.dart](../lib/screens/wifi_connect_screen.dart), so the Connect button and the retry with a typed password both go through it. When the rule says off, the button returns to "Connect" and the help opens with `wifiOffHelpText` ("Wi-Fi is turned off…") under the usual picture. No request goes to iOS. Once Wi-Fi is on, Connect joins as usual.

The trace for a held-back Connect:

```
[TRACE ... CONNECT] Connect tapped
[TRACE ... WIFI] Wi-Fi-off guard: awdl0 down, Wi-Fi address none -> Wi-Fi is off in Settings, no join request
[TRACE ... CONNECT] Wi-Fi is off in Settings -> help to turn it on
```

### If Apple changes awdl0

- **awdl0 stays up with Wi-Fi off:** the guard lets the join through, and it hangs as before the guard. Then the silence watch in `lib/screens/wifi_connect_screen.dart` (`_noReactionTimeout`) steps in: 15 s with the app in the foreground and nothing from iOS, neither an answer nor its question, bring the button back to "Connect" and open the help. The trace says `no answer and no question from iOS in 15 s -> help`. That watch is not part of the guard and stays if the guard is removed. Archer BC has the same one.
- **awdl0 disappears:** the guard joins, as before the guard.
- **awdl0 goes down with Wi-Fi on and no network joined:** the help wrongly says that Wi-Fi is off. The help also tells the user to join ARCHER_XXXX in Settings > Wi-Fi, and Connect works again whenever the phone is on any Wi-Fi network. This is the only case in which the guard is worse than no guard. It hasn't been seen.

## Checking a new iOS

Run this on every major iOS release, starting with the first beta. It takes a minute with `flutter run` and the trace.

1. Wi-Fi on (blue tile), Connect. Expect `awdl0 up ... -> join`.
2. Wi-Fi off in Control Center (white tile), Connect. Expect `awdl0 up ... -> join`; iOS asks to join and Wi-Fi comes back on.
3. Wi-Fi off in Settings (gray tile), Connect. Expect `awdl0 down, Wi-Fi address none -> Wi-Fi is off in Settings, no join request`, and the help says that Wi-Fi is off.

If step 3 shows `awdl0 up`, the sign no longer works. Switch the guard off or remove it, and look for another sign.

Don't send a join with Wi-Fi off in Settings to see the bug itself (guard off) unless you're ready to restart the phone. The blocked iOS blocks every app, Archer BC too.

## Kill switch

`wifiOffGuardEnabled` in [wifi_off_guard.dart](../lib/services/wifi_off_guard.dart). Set to `false`, Connect asks iOS as it did before the guard. It is Dart only: a hot restart applies it on a dev build, and users get it with an app update.

## How to remove

`grep -rniE "wifi-off-guard|wifi_off_guard|WifiOffGuard" --exclude-dir=build .` finds every place.

1. Delete `lib/services/wifi_off_guard.dart` and `ios/Runner/WifiOffGuard.swift`.
2. `ios/Runner.xcodeproj/project.pbxproj`: delete the four lines that name `WifiOffGuard.swift`, or remove the file from the Runner target in Xcode.
3. `ios/Runner/AppDelegate.swift`: delete the `wifi-off-guard` registration.
4. `lib/screens/wifi_connect_screen.dart`: delete the `wifi_off_guard.dart` import and the `wifi-off-guard` block at the start of `_connectIos`.
5. Docs: delete this file and the README lines about the guard: the Wi-Fi bullet and two table rows, plus `WifiOffGuard` in the AppDelegate row. The 2026-10-20 section of `docs/connect-button.md` can stay as history.
6. Rebuild the iOS app.
