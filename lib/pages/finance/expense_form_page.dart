import 'package:flutter/material.dart';

import 'common_models/expense.dart';
import 'common_ui/outlined_group.dart';

class ExpenseFormPage extends StatelessWidget {
  final Expense? existing;

  const ExpenseFormPage({super.key, this.existing});

  @override
  Widget build(BuildContext context) {
    final categoryCtrl = TextEditingController(text: existing?.category ?? '');
    final supplierCtrl = TextEditingController(text: existing?.supplier ?? '');
    final netCtrl =
    TextEditingController(text: existing?.net.toStringAsFixed(2) ?? '');
    final vatCtrl =
    TextEditingController(text: existing?.vat.toStringAsFixed(2) ?? '');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');

    final formKey = GlobalKey<FormState>();
    DateTime date = existing?.date ?? DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(existing == null ? 'Add Expense' : 'Edit Expense'),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            OutlinedGroup(
              label: 'Category',
              child: TextFormField(
                controller: categoryCtrl,
                decoration:
                const InputDecoration(border: InputBorder.none, hintText: 'Materials, Fuel, Tools...'),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedGroup(
              label: 'Supplier',
              child: TextFormField(
                controller: supplierCtrl,
                decoration:
                const InputDecoration(border: InputBorder.none),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedGroup(
                    label: 'Net (£)',
                    child: TextFormField(
                      controller: netCtrl,
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedGroup(
                    label: 'VAT (£)',
                    child: TextFormField(
                      controller: vatCtrl,
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
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
              child: TextFormField(
                controller: notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                // TODO: save expense.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                      Text('Expense saved (hook to real logic).')),
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('Save Expense'),
            ),
          ],
        ),
      ),
    );
  }
}





String formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}



