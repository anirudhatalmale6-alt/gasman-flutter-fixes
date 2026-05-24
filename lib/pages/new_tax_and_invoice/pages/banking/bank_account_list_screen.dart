import 'package:flutter/material.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/bank_accounts/create_bank_account_screen.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';

import '../../../../services/banking_service.dart';
import 'bank_transactions_screen.dart';

class BankAccountListScreen extends StatefulWidget {
  const BankAccountListScreen({super.key});

  @override
  State<BankAccountListScreen> createState() => _BankAccountListScreenState();
}

class _BankAccountListScreenState extends State<BankAccountListScreen> {
  final BankingService _svc = BankingService();
  bool loading = true;
  List<dynamic> accounts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      accounts = await _svc.listBankAccounts();
    } catch (e) {
     // if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Load failed: $e")));
      print(" _svc.listBankAccounts() Error ${e}");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _addAccount() async {

    push(BankAccountNewScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bank Accounts"),
        actions: [
          IconButton(onPressed: _addAccount, icon: const Icon(Icons.add)),
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : accounts.isEmpty ? const Center(child: Text("No accounts found")) :ListView.separated(
        itemCount: accounts.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final a = accounts[i];
          return ListTile(
            leading: const Icon(Icons.account_balance),
            title: Text(a["name"]?.toString() ?? "Bank"),
            subtitle: Text(a["currency_code"]?.toString() ?? "GBP"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => push(BankTransactionsScreen(bankAccountId: a['id'],)),
          );
        },
      ),
    );
  }
}
