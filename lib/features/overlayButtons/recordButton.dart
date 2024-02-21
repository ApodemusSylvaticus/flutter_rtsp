import 'package:flutter/material.dart';

class RecordButton extends StatelessWidget {
  final bool isRecording;
  final Function(bool) onToggle;



  const RecordButton({
    Key? key,
    required this.isRecording,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: GestureDetector(
          onTap: () {
            onToggle(!isRecording);
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 250),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 0, 0, 0.8),
              borderRadius: BorderRadius.circular(isRecording? 5.0 :25),
            ),
          ),
        ),
      ),
    );
  }
}