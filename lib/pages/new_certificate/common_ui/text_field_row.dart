import 'package:flutter/material.dart';

class TextFieldRow extends StatelessWidget {
  final String label;
  final String initialValue;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;

  const TextFieldRow({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 4),
          TextFormField(
            initialValue: initialValue,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

