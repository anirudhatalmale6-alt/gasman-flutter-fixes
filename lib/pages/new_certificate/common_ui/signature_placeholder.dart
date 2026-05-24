import 'package:flutter/material.dart';

class SignaturePlaceholder extends StatelessWidget {
  final String label;
  final bool signed;
  final VoidCallback onTap;

  const SignaturePlaceholder({
    required this.label,
    required this.signed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
    signed ? Colors.green : Colors.grey.shade400;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
              color: Colors.grey.shade50,
            ),
            alignment: Alignment.center,
            child: Text(
              signed ? 'Signature captured' : 'Tap to sign',
              style: TextStyle(
                color: signed ? Colors.green : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

