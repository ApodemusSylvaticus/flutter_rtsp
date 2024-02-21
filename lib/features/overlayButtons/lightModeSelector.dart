import 'package:flutter/material.dart';
import 'package:one_more_try/features/overlayButtons/style.dart';

class LightModeSelector extends StatefulWidget {
  @override
  _LightModeSelectorState createState() => _LightModeSelectorState();
}

class _LightModeSelectorState extends State<LightModeSelector> {
  String _selectedOption = 'Option 1';

  void _showMenu(BuildContext context) async {
    final RenderBox overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero);

    final selected = await showMenu(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
        side: BorderSide(
          color: Colors.white.withOpacity(0.9),
          width: 1.0,
        ),
      ),
      color: Color.fromARGB(255, 102, 102, 102),
      position: RelativeRect.fromLTRB(
        offset.dx - button.size.width * 1.15,
        offset.dy + button.size.height,
        offset.dx + button.size.width,
        offset.dy + button.size.height,
      ),
      items: [
        PopupMenuItem(
          value: 'Option 1',
          child: Text('Option 1', style: CustomButtonStyle.buttonTextStyle),
        ),
    
        PopupMenuItem(
          value: 'Option 2',
          child: Text(
            'Option 2',
            style: CustomButtonStyle.buttonTextStyle,
          ),
        ),

        PopupMenuItem(
          value: 'Option 3',
          child: Text(
            'Option 3',
            style: CustomButtonStyle.buttonTextStyle,
          ),
        ),
      ],
    );

    if (selected != null) {
      setState(() {
        _selectedOption = selected as String;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showMenu(context),
      style: CustomButtonStyle.menuButtonStyle,
      child: Text(_selectedOption, style: CustomButtonStyle.buttonTextStyle),
    );
  }
}
