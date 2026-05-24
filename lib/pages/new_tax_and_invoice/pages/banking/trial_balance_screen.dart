import 'package:flutter/material.dart';

import '../../../../services/reports_service.dart';
import '../../../../utils_class/money.dart';


class TrialBalanceScreen extends StatefulWidget {
  const TrialBalanceScreen({super.key});

  @override
  State<TrialBalanceScreen> createState() => _TrialBalanceScreenState();
}

class _TrialBalanceScreenState extends State<TrialBalanceScreen> {
  final ReportsService _svc = ReportsService();
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _svc.trialBalance(); // optional dateFrom/dateTo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Balance")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final data = snap.data!;
          final lines = (data["lines"] as List?) ?? [];
          final totals = (data["totals"] as Map?) ?? {};

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  title: const Text("Totals"),
                  subtitle: Text(
                    "Debit: ${formatMoney((totals["debit"] as num?)?.toDouble() ?? 0)} "
                        "Credit: ${formatMoney((totals["credit"] as num?)?.toDouble() ?? 0)}",
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...lines.map((r) {
                final code = r["code"]?.toString() ?? "";
                final name = r["name"]?.toString() ?? "";
                final debit = (r["debit"] as num?)?.toDouble() ?? 0;
                final credit = (r["credit"] as num?)?.toDouble() ?? 0;

                return Card(
                  child: ListTile(
                    title: Text("#$code  $name"),
                    subtitle: Text("Debit: ${formatMoney(debit)} Credit: ${formatMoney(credit)}"),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}