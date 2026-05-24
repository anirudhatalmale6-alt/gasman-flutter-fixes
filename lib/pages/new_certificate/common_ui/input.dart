import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  final String label;
  final String value;
  final int maxLines;
  final ValueChanged<String> onChanged;

  const Input({
    required this.label,
    required this.value,
    required this.onChanged,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 4),
          TextFormField(
            initialValue: value,
            maxLines: maxLines,
            decoration: InputDecoration(
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
