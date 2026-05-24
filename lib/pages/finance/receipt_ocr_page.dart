import 'package:flutter/material.dart';

import 'common_ui/outlined_group.dart';
import 'expense_form_page.dart';

class ReceiptOcrPage extends StatelessWidget {
  const ReceiptOcrPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryCtrl = TextEditingController(text: 'Materials');
    final supplierCtrl = TextEditingController();
    final netCtrl = TextEditingController();
    final vatCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime date = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Receipt (OCR)'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: hook to camera OCR.
                  },
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Camera'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: hook to gallery OCR.
                  },
                  icon: const Icon(Icons.photo_outlined),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('No text recognised yet'),
          const SizedBox(height: 12),
          OutlinedGroup(
            label: 'Category',
            child: TextField(
              controller: categoryCtrl,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedGroup(
            label: 'Supplier',
            child: TextField(
              controller: supplierCtrl,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedGroup(
                  label: 'Net (£)',
                  child: TextField(
                    controller: netCtrl,
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedGroup(
                  label: 'VAT (£)',
                  child: TextField(
                    controller: vatCtrl,
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedGroup(
            label: 'Date',
            child: InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2015),
                  lastDate: DateTime(2100),
                  initialDate: date,
                );
                if (picked != null) {
                  date = picked;
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatDate(date)),
                    const Icon(Icons.edit_calendar_outlined, size: 18),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedGroup(
            label: 'Notes',
            child: TextField(
              controller: notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: save expense created from OCR.
            },
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save to Expenses'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
