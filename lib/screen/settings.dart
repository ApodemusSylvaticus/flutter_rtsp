import 'package:archer_link/features/switch/index.dart';
import 'package:archer_link/features/textField/index.dart';
import 'package:archer_link/main.dart';
import 'package:flutter/material.dart';
import 'package:archer_link/containers/DefaultBg.dart';

class SettingsPage extends StatefulWidget {
  final StreamConfig actualStreamConfig;
  final void Function(StreamConfig streamConfig) resetAll;
  final void Function() closeSettings;

  const SettingsPage(this.actualStreamConfig, this.resetAll, this.closeSettings,
      {super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController streamUrlController =
      TextEditingController(text: 'stream.trailcam.link:8554/mystream');
  TextEditingController commandUrlController =
      TextEditingController(text: 'stream.trailcam.link:8080/websocket');
  TextEditingController tcpUrlController =
      TextEditingController(text: '192.168.100.1:8888');
  bool shouldRunStreamView = false;

  submit() {
    final res = StreamConfig(
      commandUrl: commandUrlController.text,
      streamUrl: streamUrlController.text,
      tcpCommandUrl: tcpUrlController.text,
      shouldRunStreamView: shouldRunStreamView,
    );
    widget.resetAll(res);
  }

  @override
  void initState() {
    super.initState();
    streamUrlController = widget.actualStreamConfig.streamUrl == ''
        ? TextEditingController(text: '192.168.100.1/stream0')
        : TextEditingController(text: widget.actualStreamConfig.streamUrl);
    commandUrlController = widget.actualStreamConfig.commandUrl == ''
        ? TextEditingController(text: '192.168.100.1:8080/websocket')
        : TextEditingController(text: widget.actualStreamConfig.commandUrl);
    tcpUrlController = widget.actualStreamConfig.commandUrl == ''
        ? TextEditingController(text: '192.168.100.1:8888')
        : TextEditingController(text: widget.actualStreamConfig.tcpCommandUrl);
    shouldRunStreamView = widget.actualStreamConfig.shouldRunStreamView;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Stack(
      children: [
        DefaultBg(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child:Center(
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
                        onPressed: submit,
                        child: Text('Submit',
                            style:
                                TextStyle(fontSize: 18.0, color: Colors.black)),
                      ),
                    ],
                  ),
                ),
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 4,
          child: GestureDetector(
            onTap: widget.closeSettings,
            child: Image.asset(
              'assets/actionButtonIcon/goBack.png',
              width: 50,
              height: 50,
            ),
          ),
        ),
      ],
    ));
  }
}
