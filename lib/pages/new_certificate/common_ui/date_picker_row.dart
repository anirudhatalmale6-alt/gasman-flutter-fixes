import 'package:flutter/material.dart';

class DatePickerRow extends StatelessWidget {
  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  const DatePickerRow({
    required this.label,
    required this.date,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              firstDate: DateTime(2010),
              lastDate: DateTime(2100),
              initialDate: date,
            );
            if (picked != null) onChanged(picked);
          },
          child: InputDecorator(
            decoration: InputDecoration(
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${date.day}/${date.month}/${date.year}'),
                const Icon(Icons.edit_calendar_outlined),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

