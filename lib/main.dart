import 'package:flutter/material.dart';
import 'package:one_more_try/features/switch/index.dart';
import 'package:one_more_try/features/textField/index.dart';
import 'package:one_more_try/screen/streamView.dart';
import 'package:one_more_try/containers/DefaultBg.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MaterialColor customColor = MaterialColor(0xFF34C759, {
      50: Color(0xFFF0F9E8),
      100: Color(0xFFDCEDC8),
      200: Color(0xFFCCE5B9),
      300: Color(0xFFB0D68D),
      400: Color(0xFF8CC665),
      500: Color(0xFF69B100),
      600: Color(0xFF5A9B00),
      700: Color(0xFF4A8500),
      800: Color(0xFF3A6F00),
      900: Color(0xFF2C5700),
    });

    return MaterialApp(
      title: 'URL Input Demo',
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          // cursorColor: Color.fromRGBO(52, 198, 89, 1), // Цвет курсора
          // selectionColor: Color.fromRGBO(52, 198, 89, 1), // Цвет фона выделения
          selectionHandleColor:
              Color.fromRGBO(52, 198, 89, 1), // Цвет индикаторов выделения
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController streamUrlController =
      TextEditingController(text: '192.168.100.1:8888/stream0');
  TextEditingController commandUrlController =
      TextEditingController(text: '192.168.1.117:8080/websocket');
  bool isSubmitPressed = false;
  bool shouldRunStreamView = false;

  void resetAll() {
    setState(() {
      isSubmitPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isSubmitPressed
        ? StreamViewPage(streamUrlController.text, commandUrlController.text,
            shouldRunStreamView, resetAll)
        : Stack(
            children: [
              DefaultBg(
                  child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const Text(
                          'Enter stream URL:',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                        CustomTextField(
                          controller: streamUrlController,
                        ),
                        SizedBox(height: 20.0),
                        const Text(
                          'Enter command websocket ip:',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                        CustomTextField(
                          controller: commandUrlController,
                        ),
                        SizedBox(height: 10.0),
                        Row(
                          children: [
                            const Text(
                              'Should run TRANS_START:',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(width: 10.0),
                            CustomSwitch(
                                value: shouldRunStreamView,
                                onChanged: (newValue) {
                                  setState(() {
                                    shouldRunStreamView = newValue;
                                  });
                                }),
                          ],
                        ),
                        SizedBox(height: 10.0),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isSubmitPressed = true;
                            });
                          },
                          child: Text('Submit',
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black)),
                        ),
                      ],
                    ),
                  ),
                ),
              ))
            ],
          );
  }
}
