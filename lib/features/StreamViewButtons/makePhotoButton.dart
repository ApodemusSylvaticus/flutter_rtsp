import 'package:flutter/material.dart';
import 'package:archer_link/features/StreamViewButtons/customButton.dart';

class MakePhotoButton extends StatefulWidget {
  final Function() takePhoto;


  

 const MakePhotoButton({required this.takePhoto,});

  @override
  _CalibrationButtonState createState() => _CalibrationButtonState();
}

class _CalibrationButtonState extends State<MakePhotoButton> {

 

  @override
  Widget build(BuildContext context) {
    return CustomSmallButton(
      onClick: widget.takePhoto,
      text: 'Photo',
      additionalData: Image.asset('assets/actionButtonIcon/takePhoto.png', width: 20, height: 20,),
    );
  }
}