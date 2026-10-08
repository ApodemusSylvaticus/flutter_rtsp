import 'package:archer_link/screens/reconnect_screen.dart';
import 'package:archer_link/screens/wifi_connect_screen.dart';
import 'package:archer_link/widgets/wifi_help_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stands in for the home page: shows [page] until [showStream] is
/// called, then the stand-in for the player.
class _Host extends StatefulWidget {
  final WidgetBuilder page;

  const _Host({required this.page});

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  bool _stream = false;

  void showStream() => setState(() => _stream = true);

  @override
  Widget build(BuildContext context) {
    return _stream ? const Text('stream') : widget.page(context);
  }
}

Finder _infoButton() => find.byWidgetPredicate((Widget w) =>
    w is Image &&
    w.image is AssetImage &&
    (w.image as AssetImage).assetName == 'assets/actionButtonIcon/infoIcon.png');

Future<void> _expectHelpClosesWithPage(
    WidgetTester tester, WidgetBuilder page) async {
  await tester.pumpWidget(MaterialApp(home: _Host(page: page)));

  await tester.tap(_infoButton());
  await tester.pumpAndSettle();
  expect(find.text(wifiHelpText), findsOneWidget);

  tester.state<_HostState>(find.byType(_Host)).showStream();
  await tester.pumpAndSettle();

  expect(find.text('stream'), findsOneWidget);
  expect(find.text(wifiHelpText), findsNothing);
}

void main() {
  testWidgets('Connect screen: help closes when the stream replaces it',
      (WidgetTester tester) async {
    await _expectHelpClosesWithPage(
      tester,
      (_) => WifiConnectPage(openSettings: () {}, onDemoMode: () {}),
    );
  });

  testWidgets('Reconnect screen: help closes when the stream replaces it',
      (WidgetTester tester) async {
    await _expectHelpClosesWithPage(
      tester,
      (_) => ReconnectView(
        isReconnecting: false,
        onReconnect: () {},
        openSettings: () {},
        onDemoMode: () {},
      ),
    );
  });

  testWidgets('the cross closes the help', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: _Host(
        page: (_) => WifiConnectPage(openSettings: () {}, onDemoMode: () {}),
      ),
    ));

    await tester.tap(_infoButton());
    await tester.pumpAndSettle();
    expect(find.text(wifiHelpText), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text(wifiHelpText), findsNothing);
  });
}
