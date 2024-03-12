import 'package:flutter/material.dart';
import 'package:one_more_try/screen/streamView.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MaterialColor customColor = MaterialColor(0xFFC4A9F1, {
      50: Color(0xFFF0E7FD),
      100: Color(0xFFD3B5F6),
      200: Color(0xFFB77FF0),
      300: Color(0xFF9B49EA),
      400: Color(0xFF862CE6),
      500: Color(0xFF6D00E1),
      600: Color(0xFF5F00C1),
      700: Color(0xFF4F00A1),
      800: Color(0xFF400081),
      900: Color(0xFF320060),
    });

    return MaterialApp(
      title: 'URL Input Demo',
      theme: ThemeData(
        primarySwatch: customColor,
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
  // 192.168.1.117:8554/mystream
  // 192.168.100.1/stream0
  TextEditingController streamUrl =
      TextEditingController(text: '192.168.100.1/stream0');
  TextEditingController commandUrl =
      TextEditingController(text: '192.168.1.117:8085');
  bool isSubmitPressed = false;
  bool shouldRunStreamView = false;

  void resetAll(){
     setState(() {
      isSubmitPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isSubmitPressed
        ? StreamViewPage(streamUrl.text, commandUrl.text, shouldRunStreamView, resetAll)
        : Scaffold(
            backgroundColor: Color.fromRGBO(128, 128, 128, 1),
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
                    TextField(
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                      controller: streamUrl,
                    ),
                    SizedBox(height: 20.0),
                    const Text(
                      'Enter command websocket ip:',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                    TextField(
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                      controller: commandUrl,
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
                        Switch(
                          value: shouldRunStreamView,
                          onChanged: (newValue) {
                            setState(() {
                              shouldRunStreamView = newValue;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: () {
                        String streamUrlText = streamUrl.text;
                        String commandUrlText = commandUrl.text;
                        setState(() {
                          isSubmitPressed = true;
                        });
                      },
                      child: Text('Submit', style: TextStyle(fontSize: 18.0)),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
