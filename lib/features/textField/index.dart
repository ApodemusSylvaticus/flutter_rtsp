import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;

  const CustomTextField({
    required this.controller,
    
  });


  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(
          color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
      cursorColor: Color.fromRGBO(52, 198, 89, 1),
      decoration: const InputDecoration(
        
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(224, 224, 224, 1)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(52, 198, 89, 1)), 
        ), 

        
     
      ),
    );
  }
}
