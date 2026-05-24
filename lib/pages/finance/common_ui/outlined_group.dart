import 'package:flutter/material.dart';

class OutlinedGroup extends StatelessWidget {
  final String label;
  final Widget child;

  const OutlinedGroup({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(color: Colors.grey.shade400),
            color: Colors.grey.shade50,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: child,
        ),
      ],
    );
  }
}