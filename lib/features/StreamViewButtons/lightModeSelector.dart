import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:one_more_try/features/StreamViewButtons/customButton.dart';
import 'package:one_more_try/proto/demo_protocol.pb.dart' as demo_protocol;
import 'package:one_more_try/proto/demo_protocol.pbserver.dart';

class LightModeSelector extends StatefulWidget {
  final void Function(Uint8List buffer) sendToServer;
  final demo_protocol.HostDevStatus devStatus;
  LightModeSelector(this.sendToServer, this.devStatus);

  @override
  _LightModeSelectorState createState() => _LightModeSelectorState();
}

class _LightModeSelectorState extends State<LightModeSelector> {
  late demo_protocol.ColorScheme _selectedOption;

  @override
  void initState() {
    super.initState();
    if (widget.devStatus.colorScheme ==
        demo_protocol.ColorScheme.UNKNOWN_COLOR_SHEME) {
      throw ArgumentError(
          'Unknown ColorScheme: ${widget.devStatus.colorScheme}');
    }
    _selectedOption = widget.devStatus.colorScheme;
  }

  void _showMenu(BuildContext context) async {
    final RenderBox overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero);

    final selected = await showMenu(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: Colors.white,
          width: 1.0,
        ),
      ),
      color: Colors.black,
      position: RelativeRect.fromLTRB(
        offset.dx - button.size.width,
        offset.dy,
        offset.dx + button.size.width,
        offset.dy + button.size.height,
      ),
      items: [
        PopupMenuItem(
            value: demo_protocol.ColorScheme.BLACK_HOT,
            child: Text('Black hot',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ))),
        PopupMenuItem(
          value: demo_protocol.ColorScheme.SEPIA,
          child: Text('Sepia',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              )),
        ),
        PopupMenuItem(
          value: demo_protocol.ColorScheme.WHITE_HOT,
          child: Text('White hot',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              )),
        ),
      ],
    );

    if (selected != null) {
      setState(() {
        _selectedOption = selected;
      });

      sendComand(_selectedOption);
    }
  }

  void sendComand(demo_protocol.ColorScheme colorScheme) {
    final setColorScheme = demo_protocol.SetColorScheme(scheme: colorScheme);
    final command = Command(setPallette: setColorScheme);

    final clientPayload = ClientPayload(command: command);

    final buffer = clientPayload.writeToBuffer();
    widget.sendToServer(buffer);
  }

  String convertShemeToText(demo_protocol.ColorScheme colorScheme) {
    switch (colorScheme) {
      case demo_protocol.ColorScheme.BLACK_HOT:
        return "Black Hot";
      case demo_protocol.ColorScheme.SEPIA:
        return "Sepia";
      case demo_protocol.ColorScheme.WHITE_HOT:
        return "White Hot";
      case demo_protocol.ColorScheme.UNKNOWN_COLOR_SHEME:
        throw ArgumentError('Unknown ColorScheme: $colorScheme');
      default:
        throw ArgumentError('Unexpected ColorScheme: $colorScheme');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      onClick: () => _showMenu(context),
      text: 'Color Mode',
      additionalData: Image.asset(
        'assets/actionButtonIcon/colorMode.png',
        width: 20,
        height: 20,
      ),
    );
  }
}
