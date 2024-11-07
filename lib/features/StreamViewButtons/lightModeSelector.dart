import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:archer_link/features/StreamViewButtons/customButton.dart';
import 'package:archer_link/proto/archer_protocol.pb.dart' as archer_protocol;

class LightModeSelector extends StatefulWidget {
  final void Function(Uint8List buffer) sendToServer;
  final archer_protocol.HostDevStatus devStatus;
  
  LightModeSelector(this.sendToServer, this.devStatus);

  @override
  _LightModeSelectorState createState() => _LightModeSelectorState();
}

class _LightModeSelectorState extends State<LightModeSelector> {
  late archer_protocol.ColorScheme _selectedOption;

  @override
  void initState() {
    super.initState();
    if (widget.devStatus.colorScheme ==
        archer_protocol.ColorScheme.UNKNOWN_COLOR_SHEME) {
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
            value: archer_protocol.ColorScheme.BLACK_HOT,
            child: Text('Black hot',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ))),
        PopupMenuItem(
          value: archer_protocol.ColorScheme.SEPIA,
          child: Text('Sepia',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              )),
        ),
        PopupMenuItem(
          value: archer_protocol.ColorScheme.WHITE_HOT,
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

  void sendComand(archer_protocol.ColorScheme colorScheme) {
    final setColorScheme = archer_protocol.SetColorScheme(scheme: colorScheme);
    final command = archer_protocol.Command(setPallette: setColorScheme);

    final clientPayload = archer_protocol.ClientPayload(command: command);

    final buffer = clientPayload.writeToBuffer();
    widget.sendToServer(buffer);
  }

  String convertShemeToText(archer_protocol.ColorScheme colorScheme) {
    switch (colorScheme) {
      case archer_protocol.ColorScheme.BLACK_HOT:
        return "Black Hot";
      case archer_protocol.ColorScheme.SEPIA:
        return "Sepia";
      case archer_protocol.ColorScheme.WHITE_HOT:
        return "White Hot";
      case archer_protocol.ColorScheme.UNKNOWN_COLOR_SHEME:
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
