import 'package:flutter/material.dart';

class DateRow extends StatelessWidget {
  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  const DateRow({
    required this.label,
    required this.date,
    required this.onChanged,
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
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                firstDate: DateTime(2010),
                lastDate: DateTime(2100),
                initialDate: date,
              );
              if (picked != null) {
                onChanged(picked);
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(
                filled: true,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'),
                  const Icon(Icons.edit_calendar_outlined, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
