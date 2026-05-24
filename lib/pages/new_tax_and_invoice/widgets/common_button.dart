import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const CommonButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      child: Text(text),
    );
  }
}