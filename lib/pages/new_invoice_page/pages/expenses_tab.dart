import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:the_gas_man_app/theme/app_theme.dart';

import '../account_storage_file.dart';
import '../data_model/all_models.dart';

class ExpensesTab extends StatefulWidget {
  final AccountStorage storage;
  final VoidCallback onChanged;

  const ExpensesTab({
    super.key,
    required this.storage,
    required this.onChanged,
  });

  @override
  State<ExpensesTab> createState() => _ExpensesTabState();
}

class _ExpensesTabState extends State<ExpensesTab> {
  @override
  Widget build(BuildContext context) {
    final expenses = [...widget.storage.expenses]
      ..sort((a, b) => b.date.compareTo(a.date));

    return Container(
      color: AppColors.kLightBg,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: _addExpenseDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Expense'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (_, i) {
                final e = expenses[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    title: Text('${e.category} • £${e.amount.toStringAsFixed(2)}'),
                    subtitle: Text(
                      '${_fmtDate(e.date)} • ${e.notes.isNotEmpty ? e.notes : e.supplier}',
                    ),

                    // 👉 ADD THIS
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ✏️ Edit Button
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _addExpenseDialog(expense: e);
                            print("Edit ${e.id}");
                          },
                        ),


                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Delete expense?'),
                                content: Text(
                                  'Delete £${e.amount.toStringAsFixed(2)} - ${e.category}?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await widget.storage.deleteExpense(e.id);
                              widget.onChanged();
                            }
                          },
                        ),
                      ],
                    ),

                    // (Optional) keep tap for view
                    onTap: () {
                      print("Open details");
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _addExpenseDialog({Expense? expense}) async {
    final dateController = TextEditingController(
      text: _fmtDate(expense?.date ?? DateTime.now()),
    );

    final categoryController =
    TextEditingController(text: expense?.category ?? '');

    final supplierController =
    TextEditingController(text: expense?.supplier ?? '');

    final amountController = TextEditingController(
      text: expense != null ? expense.amount.toString() : '',
    );

    final notesController =
    TextEditingController(text: expense?.notes ?? '');

    double vatRate = expense?.vatRate ?? 20;

    DateTime parseDate(String s) {
      final parts = s.split('/');
      if (parts.length == 3) {
        final d = int.tryParse(parts[0]) ?? 1;
        final m = int.tryParse(parts[1]) ?? 1;
        final y = int.tryParse(parts[2]) ?? DateTime.now().year;
        return DateTime(y, m, d);
      }
      return DateTime.now();
    }

    Future<void> pickDate() async {
      final initial = parseDate(dateController.text);
      final picked = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(initial.year - 5),
        lastDate: DateTime(initial.year + 5),
      );
      if (picked != null) {
        dateController.text = _fmtDate(picked);
      }
    }

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(expense == null ? 'Add Expense' : 'Edit Expense'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
                onTap: pickDate,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: categoryController,
                decoration:
                const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: supplierController,
                decoration:
                const InputDecoration(labelText: 'Supplier'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration:
                const InputDecoration(labelText: 'Amount (£)'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<double>(
                value: vatRate,
                decoration: const InputDecoration(labelText: 'VAT rate'),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('0%')),
                  DropdownMenuItem(value: 5, child: Text('5%')),
                  DropdownMenuItem(value: 20, child: Text('20%')),
                ],
                onChanged: (v) => vatRate = v ?? 20,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                decoration:
                const InputDecoration(labelText: 'Notes'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final amount =
                  double.tryParse(amountController.text) ?? 0.0;

              if (categoryController.text.trim().isEmpty ||
                  amount <= 0) return;

              final e = Expense(
                id: expense?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                date: parseDate(dateController.text),
                category: categoryController.text.trim(),
                supplier: supplierController.text.trim(),
                amount: amount,
                vatRate: vatRate,
                notes: notesController.text.trim(),
              );

              await widget.storage.saveExpense(e); // same method works
              widget.onChanged();

              if (mounted) Navigator.pop(context);
            },
            child: Text(expense == null ? 'Save' : 'Update'),
          ),
        ],
      ),
    );
  }
}
