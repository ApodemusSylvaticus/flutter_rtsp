import 'package:flutter/material.dart';


class CustomButton extends StatelessWidget {
  final VoidCallback onClick;
  final String text;
  final Widget additionalData;

  const CustomButton({
    Key? key,
    required this.onClick,
    required this.additionalData,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 120,
      child: ElevatedButton(
        onPressed: onClick,
        style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromRGBO(70, 69, 69, 1),
            padding: EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            )),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700),
            ),
            Expanded(child: Container()),
            additionalData
          ],
        ),
      ),
    );
  }
}

class CustomSmallButton extends StatelessWidget {
  final VoidCallback onClick;
  final String text;
  final Widget additionalData;

  const CustomSmallButton({
    Key? key,
    required this.onClick,
    required this.additionalData,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: 56,
      child: ElevatedButton(
        onPressed: onClick,
        style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromRGBO(70, 69, 69, 1),
            padding: EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700),
            ),
            Expanded(child: Container()),
            additionalData
          ],
        ),
      ),
    );
  }
}
