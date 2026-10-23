import 'dart:io' show Platform;

import 'package:archer_link/utils/trace.dart';
import 'package:flutter/material.dart';

/// Shown under the help picture when the user opens the help themselves.
/// The picture already names the network, so the text only says what to
/// do with it. The Connect screen passes its own text after a failed
/// attempt.
///
/// Android gets a second paragraph. Android does not trust a Wi-Fi without
/// internet: it keeps mobile data as the default network and does not
/// rejoin such a network by itself later. The app no longer needs the
/// trust to show the stream (it binds its traffic to the imager's Wi-Fi),
/// but the automatic rejoin comes only from the user's answer to Android's
/// "no internet" question. Samsung asks it only when the network is tapped
/// in the full Wi-Fi settings, not in the quick panel (measured on the
/// S24+, One UI 8.5, 2026-10-14).
String get wifiHelpText => Platform.isAndroid
    ? '$_wifiJoinText\n\n$_androidAutoReconnectText'
    : _wifiJoinText;

const String _wifiJoinText =
    "Connect to the device's Wi-Fi network and return to the app.";

const String _androidAutoReconnectText =
    'To make the phone reconnect to the device by itself, open Settings > '
    "Wi-Fi (the full settings screen, not the quick panel), tap the device's "
    'network and, when the phone warns that the network may have no '
    'internet, choose "Always connect".';

/// Opens the Wi-Fi help for one page and closes it again when that page
/// goes away. Keep one per State and call [close] from `dispose()`: the
/// page is swapped for the stream the moment the device is reachable,
/// and the help must not stay on top of the video.
class WifiHelp {
  NavigatorState? _navigator;

  bool get isOpen => _navigator != null;

  /// [onPassword]: see [showWifiHelp].
  void show(BuildContext context,
      {required String message, void Function(String password)? onPassword}) {
    if (_navigator != null) {
      trace('HELP', 'help already open');
      return;
    }
    trace('HELP', 'help opened${onPassword != null ? ' with the password field' : ''}');
    _navigator = Navigator.of(context, rootNavigator: true);
    showWifiHelp(context, message: message, onPassword: onPassword).then((_) {
      trace('HELP', 'help gone');
      _navigator = null;
    });
  }

  /// Closes the help if it is open. Safe to call from `dispose()`: the
  /// pop is deferred to after the current frame, because dispose runs in
  /// the middle of a build and the navigator must not change then.
  void close() {
    final NavigatorState? navigator = _navigator;
    if (navigator == null) return;
    trace('HELP', 'help closed by the page going away');
    _navigator = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigator.mounted && navigator.canPop()) navigator.pop();
    });
  }
}

/// Full-screen help: the picture of the imager's network in the phone's
/// Wi-Fi list, centred, with [message] right under it. Closed by the
/// cross in the top right corner or a tap anywhere. The returned future
/// completes when the dialog is gone.
///
/// [onPassword] (iOS, after a join that iOS accepted but that never reached
/// the imager, most likely the password): the help becomes a small form
/// instead, see [_PasswordHelp]. A valid password closes it and goes to
/// [onPassword].
Future<void> showWifiHelp(BuildContext context,
    {required String message, void Function(String password)? onPassword}) {
  return showDialog<void>(
    context: context,
    useSafeArea: false,
    builder: (BuildContext dialogContext) {
      void close(String how) {
        trace('HELP', 'help closed by $how');
        Navigator.of(dialogContext).pop();
      }

      if (onPassword != null) {
        return _PasswordHelp(
          message: message,
          onClose: () => close('the cross'),
          onSubmit: (String password) {
            close('the password form');
            onPassword(password);
          },
        );
      }

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => close('tap'),
        child: Container(
          color: Colors.black,
          width: double.infinity,
          height: double.infinity,
          child: SafeArea(
            child: Stack(
              children: [
                LayoutBuilder(
                  builder:
                      (BuildContext context, BoxConstraints constraints) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // The picture is nearly square (1125x1304): on a
                          // phone it fills the width. The cap keeps it from
                          // pushing the text off the screen in landscape;
                          // Flexible shrinks it further on a small phone,
                          // where the Android text runs to two paragraphs.
                          Flexible(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: constraints.maxHeight * 0.6,
                              ),
                              child: Image.asset(
                                'assets/wifi_info.png',
                                width: double.infinity,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                            child: Text(
                              message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                decoration: TextDecoration.none,
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // An explicit way out, so nobody has to guess that a tap
                // on the picture closes it.
                Positioned(
                  top: 4,
                  right: 4,
                  child: _CloseButton(onTap: () => close('the cross')),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Icon(Icons.close, color: Colors.white, size: 40),
      ),
    );
  }
}

/// The help after a join that iOS accepted but that never reached the
/// imager: what happened, what to check, and a field to try again with the
/// device's own Wi-Fi password. The text does not say "not the factory
/// password": some units ship with another factory password than the one
/// the app knows.
///
/// Layout: the close button on its own row; the picture at full width,
/// cropped below its third row (the rows under the network are blurred
/// filler); then a title, a muted explanation and the form, all on the
/// same 24-point side margins, centred in the height that is left. While
/// the keyboard is up the picture steps aside, so the title, the field and
/// the button are all in sight. Only the cross closes it: a tap meant for
/// the field must not dismiss it.
class _PasswordHelp extends StatelessWidget {
  final String message;
  final VoidCallback onClose;
  final void Function(String password) onSubmit;

  const _PasswordHelp(
      {required this.message, required this.onClose, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    // Read above the Scaffold, which takes the keyboard out of its body's
    // insets.
    final keyboardUp = MediaQuery.viewInsetsOf(context).bottom > 0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: _CloseButton(onTap: onClose),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (!keyboardUp)
                              ClipRect(
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  heightFactor: 0.69,
                                  child: Image.asset(
                                    'assets/wifi_info.png',
                                    width: double.infinity,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Could not connect to the device',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    message,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  _PasswordForm(onSubmit: onSubmit),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordForm extends StatefulWidget {
  final void Function(String password) onSubmit;

  const _PasswordForm({required this.onSubmit});

  @override
  State<_PasswordForm> createState() => _PasswordFormState();
}

class _PasswordFormState extends State<_PasswordForm> {
  final TextEditingController _password = TextEditingController();
  bool _hidden = true;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    final password = _password.text;
    // WPA2 passphrases are 8 to 63 characters; anything else cannot work.
    final error = password.length < 8
        ? 'At least 8 characters'
        : password.length > 63
            ? 'At most 63 characters'
            : null;
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    trace('HELP', 'password typed (${password.length} chars): trying again');
    widget.onSubmit(password);
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Or try again with the device's Wi-Fi password",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _password,
          obscureText: _hidden,
          autocorrect: false,
          enableSuggestions: false,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.go,
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
          onSubmitted: (_) => _submit(),
          style: const TextStyle(color: Colors.white, fontSize: 17),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: 'Wi-Fi password',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF1C1C1E),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            errorText: _error,
            enabledBorder: _border(const Color(0xFF3A3A3C)),
            focusedBorder: _border(Colors.white70),
            errorBorder: _border(const Color(0xFFFF6961)),
            focusedErrorBorder: _border(const Color(0xFFFF6961)),
            suffixIcon: IconButton(
              tooltip: _hidden ? 'Show password' : 'Hide password',
              icon: Icon(
                _hidden ? Icons.visibility : Icons.visibility_off,
                color: Colors.white54,
              ),
              onPressed: () => setState(() => _hidden = !_hidden),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/actionButtonIcon/connectButtonIcon.png',
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Connect',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'The app remembers it for this device.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
      ],
    );
  }
}
