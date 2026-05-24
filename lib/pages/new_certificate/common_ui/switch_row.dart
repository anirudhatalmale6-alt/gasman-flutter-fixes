import 'package:flutter/material.dart';

class SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }
}

