import 'package:flutter/material.dart';

import '../common_models/warning_notice_record.dart';
import 'input.dart';

class WarningItemCard extends StatelessWidget {
  final WarningApplianceEntry entry;
  final int index;
  final VoidCallback onDelete;

  const WarningItemCard({
    required this.entry,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Item ${index + 1}'),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                ),
              ],
            ),

            Input(
              label: 'Type (boiler/hob/fire/pipework etc.)',
              value: entry.type,
              onChanged: (v) => entry.type = v,
            ),
            Input(
              label: 'Make',
              value: entry.make,
              onChanged: (v) => entry.make = v,
            ),
            Input(
              label: 'Model',
              value: entry.model,
              onChanged: (v) => entry.model = v,
            ),
            Input(
              label: 'Location',
              value: entry.location,
              onChanged: (v) => entry.location = v,
            ),
            Input(
              label: 'Serial number (optional)',
              value: entry.serialNumber,
              onChanged: (v) => entry.serialNumber = v,
            ),

            const SizedBox(height: 8),
            const Text('Classification (ID / AR only)'),

            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('ID'),
                    value: true,
                    groupValue: entry.isID,
                    onChanged: (v) => entry.isID = v!,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('AR'),
                    value: false,
                    groupValue: entry.isID,
                    onChanged: (v) => entry.isID = v!,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),

            Input(
              label: 'Defect / unsafe situation details',
              value: entry.defectDetails,
              maxLines: 3,
              onChanged: (v) => entry.defectDetails = v,
            ),
          ],
        ),
      ),
    );
  }
}
