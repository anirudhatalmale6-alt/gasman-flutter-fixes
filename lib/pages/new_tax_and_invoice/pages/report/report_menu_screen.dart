import 'package:flutter/material.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/payroll/vat_summary_page.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/report/balance_sheet_screen.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/report/profit_loss_screen.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/banking/trial_balance_screen.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';

class ReportsMenuScreen extends StatelessWidget {
  const ReportsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reports")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // _ReportTile(
          //   title: "Balance",
          //   subtitle: "Debits / Credits by account",
          //   icon: Icons.balance,
          //   onTap: () => push(TrialBalanceScreen()),
          // ),
          _ReportTile(
            title: "Profit & Loss",
            subtitle: "Income, expense, net profit",
            icon: Icons.show_chart,
            onTap: () => push(ProfitLossScreen()),
          ),
          _ReportTile(
            title: "Balance Sheet",
            subtitle: "Assets, liabilities, equity",
            icon: Icons.account_balance,
            onTap: () => push(BalanceSheetScreen()),
          ),
          _ReportTile(
            title: "VAT Return (Boxes 1–9)",
            subtitle: "UK VAT return summary",
            icon: Icons.receipt_long,
            onTap: () => push(VatSummaryScreen()),
          ),
        ],
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ReportTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

