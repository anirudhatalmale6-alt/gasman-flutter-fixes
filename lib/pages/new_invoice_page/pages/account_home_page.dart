import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:the_gas_man_app/pages/settings/engineer_settings_page.dart';
import 'package:the_gas_man_app/theme/app_theme.dart';

import '../account_storage_file.dart';
import 'dashboard_tab.dart';
import 'expenses_tab.dart';
import 'invoice_tab.dart';
import 'reports_tab.dart';
import 'setting_tab.dart';
import 'receipt_ocr_page.dart';


class AccountsHomePage extends StatefulWidget {
  const AccountsHomePage({super.key});

  @override
  State<AccountsHomePage> createState() => _AccountsHomePageState();
}

class _AccountsHomePageState extends State<AccountsHomePage> {
  final AccountStorage _storage = AccountStorage();
  bool _loading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _storage.load();
    setState(() => _loading = false);
  }

  Future<void> _saveAll() async {
    await _storage.saveInvoices();
    await _storage.saveExpenses();
    await _storage.saveSettings();
    setState(() {}); // refresh UI
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final tabs = [
      DashboardTab(storage: _storage),
      InvoicesTab(storage: _storage, onChanged: _saveAll),
      ExpensesTab(storage: _storage, onChanged: _saveAll),
      ReceiptOcrPage(storage: _storage, onChanged: _saveAll),
      ReportsTab(storage: _storage),
      CompanyInformationPage(shouldShowAppBar: false,),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.kTeal,
        title: const Text('Accounts & Invoicing'),
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.kTeal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Invoices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.document_scanner_outlined),
            label: 'OCR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Company information',
          ),
        ],
      ),
    );
  }
}

