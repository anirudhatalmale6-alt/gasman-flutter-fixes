import 'package:flutter/material.dart';

import '../../../../services/reports_service.dart';
import '../../../../utils_class/money.dart';


class BalanceSheetScreen extends StatefulWidget {
  const BalanceSheetScreen({super.key});

  @override
  State<BalanceSheetScreen> createState() => _BalanceSheetScreenState();
}

class _BalanceSheetScreenState extends State<BalanceSheetScreen> {
  final ReportsService _svc = ReportsService();
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _svc.balanceSheet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Balance Sheet")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final data = snap.data!;
          final assets =double.tryParse(data["assets"]['totalAssets'].toString()) ?? 0;
          final liabilities = double.tryParse(data["liabilities"]['totalLiabilities'].toString()) ?? 0;
          final equity = double.tryParse(data["equity"]['totalEquity'].toString()) ?? 0;
          final check = (data["check"] as Map?)?["assetsEqualsLiabilitiesPlusEquity"];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(child: ListTile(title: const Text("Assets"), trailing: Text(formatMoney(assets)))),
              Card(child: ListTile(title: const Text("Liabilities"), trailing: Text(formatMoney(liabilities)))),
              Card(child: ListTile(title: const Text("Equity"), trailing: Text(formatMoney(equity)))),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  title: const Text("Check (Assets - (L + E))"),
                  subtitle: const Text("Should be 0.00 when balanced"),
                  trailing: Text(check == null ? "-" : formatMoney((check as num).toDouble())),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}