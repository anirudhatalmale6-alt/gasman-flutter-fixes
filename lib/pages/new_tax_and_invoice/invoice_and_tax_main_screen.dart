
import 'package:flutter/material.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/billing/bill_list_screen.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/invoice_dashboard_screen.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';

import '../../widgets/animated_navbar.dart';
import 'pages/banking/bank_account_list_screen.dart';
import 'pages/invoice/invoice_list_screen.dart';
import 'pages/payroll/payroll_run_list_screen.dart';
import 'pages/report/report_menu_screen.dart';
import 'widgets/quick_action_menu.dart';




class InvoiceAndTaxMainScreen extends StatefulWidget {
  const InvoiceAndTaxMainScreen({super.key});

  @override
  State<InvoiceAndTaxMainScreen> createState() => _InvoiceAndTaxMainScreenState();
}

class _InvoiceAndTaxMainScreenState extends State<InvoiceAndTaxMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    InvoiceDashboardScreen(),
    InvoiceListScreen(),
    BillListScreen(),
    BankAccountListScreen(),
    PayrollRunListScreen(),
    ReportsMenuScreen(),
  ];

  void _openQuickActions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return QuickActionMenu(
          onSelected: (route) {
            Navigator.pop(context);
            push(route);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openQuickActions,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedNavBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        icons: const [
          Icons.dashboard,
          Icons.sell,
          Icons.shopping_cart,
          Icons.account_balance,
          Icons.people,
          Icons.bar_chart,
        ],
        labels: const [
          "Dashboard",
          "Sales",
          "Purchases",
          "Banking",
          "Payroll",
          "Reports",
        ],
      ),
    );
  }
}
