import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../services/reports_service.dart';
import '../../../../utils_class/money.dart';

class ProfitLossScreen extends StatefulWidget {
  const ProfitLossScreen({super.key});

  @override
  State<ProfitLossScreen> createState() => _ProfitLossScreenState();
}

class _ProfitLossScreenState extends State<ProfitLossScreen> {
  final ReportsService _svc = ReportsService();
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _svc.profitAndLoss();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profit & Loss")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (_, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          final data = snap.data!;
          final income = (data["income"] as num?)?.toDouble() ?? 0;
          final expense = (data["expense"] as num?)?.toDouble() ?? 0;
          final net = (data["netProfit"] as num?)?.toDouble() ?? 0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                  child: ListTile(
                      title: const Text("Income"),
                      trailing: Text(formatMoney(income)))),
              Card(
                  child: ListTile(
                      title: const Text("Expenses"),
                      trailing: Text(formatMoney(expense)))),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  title: const Text("Net Profit"),
                  trailing: Text(formatMoney(net),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
