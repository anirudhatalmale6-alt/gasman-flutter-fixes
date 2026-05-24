import 'package:flutter/material.dart';
import 'package:the_gas_man_app/theme/app_theme.dart';

import '../account_storage_file.dart';
import '../data_model/all_models.dart';

class DashboardTab extends StatelessWidget {
  final AccountStorage storage;
  const DashboardTab({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfYear = DateTime(now.year, 1, 1);

    bool inMonth(DateTime d) =>
        !d.isBefore(startOfMonth) && !d.isAfter(now);
    bool inYear(DateTime d) =>
        !d.isBefore(startOfYear) && !d.isAfter(now);

    final invoices = storage.invoices.where((i) => !i.isEstimate);
    final expenses = storage.expenses;

    final incomeThisMonth = invoices
        .where((i) => inMonth(i.date))
        .fold(0.0, (sum, i) => sum + i.total);

    final expensesThisMonth = expenses
        .where((e) => inMonth(e.date))
        .fold(0.0, (sum, e) => sum + e.amount);

    final incomeThisYear = invoices
        .where((i) => inYear(i.date))
        .fold(0.0, (sum, i) => sum + i.total);

    final expensesThisYear = expenses
        .where((e) => inYear(e.date))
        .fold(0.0, (sum, e) => sum + e.amount);

    final unpaid = invoices
        .where((i) => i.status != InvoiceStatus.paid)
        .fold(0.0, (sum, i) => sum + i.total);

    return Container(
      color: AppColors.kLightBg,
      padding: const EdgeInsets.all(12),
      child: ListView(
        children: [
          _card(
            'This Month',
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _metric('Income', incomeThisMonth),
                _metric('Expenses', expensesThisMonth),
                _metric('Profit', incomeThisMonth - expensesThisMonth),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _card(
            'This Year',
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _metric('Income', incomeThisYear),
                _metric('Expenses', expensesThisYear),
                _metric('Profit', incomeThisYear - expensesThisYear),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _card(
            'Unpaid Invoices',
            Text(
              '£${unpaid.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          _card(
            'Quick Stats',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total invoices: ${storage.invoices.length}'),
                Text('Estimates: ${storage.invoices.where((i) => i.isEstimate).length}'),
                Text('Expenses: ${storage.expenses.length}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(String title, Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: kSectionTitleStyle),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _metric(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(
          '£${value.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
