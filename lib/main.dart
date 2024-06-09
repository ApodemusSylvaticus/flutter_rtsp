import 'package:flutter/material.dart';
import 'package:archer_link/features/loading.dart';
import 'package:archer_link/features/switch/index.dart';
import 'package:archer_link/features/textField/index.dart';
import 'package:archer_link/screen/streamView.dart';
import 'package:archer_link/containers/DefaultBg.dart';
import 'package:wifi_iot/wifi_iot.dart';

void main() {
  runApp(MyApp());
}

Future<Map<String, dynamic>> isSubnetCorrect() async {
  final actualIp = await WiFiForIoTPlugin.getIP();
  if (actualIp == null) {
    return {'isSubnetCorrect': false};
  }
  final actualOctets = actualIp.split('.');
  if (actualOctets.length < 3) {
    return {'isSubnetCorrect': false};
  }

  print(actualOctets);

//TEST
// if ('192' == actualOctets[0] &&
//       '168' == actualOctets[1] &&
//       '1' == actualOctets[2]) {
//     return {
//       'isSubnetCorrect': true,
//       'streamUrlController': 'stream.trailcam.link:8554/mystream',
//       'commandUrlController': 'stream.trailcam.link:8080/websocket',
//       'isTCPsend': false
//     };
//   }

  if ('192' == actualOctets[0] &&
      '168' == actualOctets[1] &&
      '1' == actualOctets[2]) {
    return {
      'isSubnetCorrect': true,
      'streamUrlController': '192.168.1.117:8554/mystream',
      'commandUrlController': '192.168.1.117:8080/websocket',
      'isTCPsend': false
    };
  }

  if ('192' == actualOctets[0] &&
      '168' == actualOctets[1] &&
      '1' == actualOctets[2]) {
    return {
      'isSubnetCorrect': true,
      'streamUrlController': '192.168.1.1:555//ir.sdp',
      'commandUrlController': '192.168.1.1:8080/websocket',
      "tcpUrlController": '',
      'isTCPsend': false
    };
  }

  if ('192' == actualOctets[0] &&
      '168' == actualOctets[1] &&
      '100' == actualOctets[2]) {
    return {
      'isSubnetCorrect': true,
      'streamUrlController': '192.168.100.1/stream0',
      'commandUrlController': '192.168.100.1:8080/websocket',
      "tcpUrlController": '192.168.100.1:8888',
      'isTCPsend': true
    };
  }

  return {'isSubnetCorrect': false};
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
      title: 'Archer Link',
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          selectionHandleColor: Color.fromRGBO(52, 198, 89, 1),
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
  bool isFirstLoading = true;
  TextEditingController streamUrlController =
      TextEditingController(text: 'stream.trailcam.link:8554/mystream');
  TextEditingController commandUrlController =
      TextEditingController(text: 'stream.trailcam.link:8080/websocket');
  TextEditingController tcpUrlController =
      TextEditingController(text: '192.168.100.1:8888');
  bool isSubmitPressed = false;
  bool shouldRunStreamView = false;

  @override
  void initState() {
    super.initState();
    getNetworkData();
  }

  getNetworkData() async {
    final value = await isSubnetCorrect();
    print(value);
    if (value['isSubnetCorrect'] == false) {
      setState(() {
        isFirstLoading = false;
 streamUrlController =
            TextEditingController(text: '');
        commandUrlController =
            TextEditingController(text: '');
        tcpUrlController =
            TextEditingController(text: '');
              isSubmitPressed = true;

      });
    } else {
      setState(() {
        streamUrlController =
            TextEditingController(text: value['streamUrlController']);
        commandUrlController =
            TextEditingController(text: value['commandUrlController']);
        tcpUrlController =
            TextEditingController(text: value['tcpUrlController']);
        isSubmitPressed = true;
        shouldRunStreamView = value['isTCPsend'];
        isFirstLoading = false;
      });
    }
  }

  void resetAll() {
    setState(() {
      isSubmitPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isFirstLoading) {
      return DefaultBg(
        child: const Center(
          child: LoadingIndicator(isLoading: true),
        ),
      );
    }

    return isSubmitPressed
        ? StreamViewPage(streamUrlController.text, commandUrlController.text,
            shouldRunStreamView, resetAll, tcpUrlController.text)
        : Stack(
            children: [
              DefaultBg(
                  child: Scaffold(
                backgroundColor: Colors.transparent,
                body: SafeArea(
                  child: Padding(
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
                            'Enter command websocket URL:',
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
                          if (shouldRunStreamView) ...[
                            SizedBox(height: 20.0),
                            const Text(
                              'Enter TCP URL:',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                            CustomTextField(
                              controller: tcpUrlController,
                            ),
                          ],
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
                ),
              ))
            ],
          );
  }
}
