import 'package:flutter/material.dart';

import 'common_models/expense.dart';
import 'expense_form_page.dart';

class ExpensesListPage extends StatelessWidget {
  const ExpensesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: load real expenses.
    final dummyExpenses = <Expense>[
      Expense(
        id: '1',
        category: 'Materials',
        supplier: 'Example Supplier',
        net: 100,
        vat: 0,
        date: DateTime.now(),
      ),
    ];

    double netTotal = dummyExpenses.fold(
        0, (sum, e) => sum + e.net); // VAT & gross can be added similarly.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
      ),
      body: Column(
        children: [
          // YEAR SUMMARY
          Card(
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('This Year'),
                  Text('Net: £${netTotal.toStringAsFixed(2)}'),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: dummyExpenses.length,
              itemBuilder: (context, index) {
                final e = dummyExpenses[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text('${e.category} — £${e.net.toStringAsFixed(2)}'),
                    subtitle: Text(
                        '${e.supplier} • ${formatDate(e.date)} • VAT £${e.vat.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        // TODO: delete expense.
                      },
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ExpenseFormPage(existing: e),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ExpenseFormPage(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}


