import 'package:flutter/material.dart';

class CommonTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const CommonTextField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(hintText: hint),
    );
  }
}