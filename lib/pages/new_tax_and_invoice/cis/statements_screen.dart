import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'view_models/statement_vm.dart';

class StatementScreen extends StatelessWidget {
  final int subcontractorId;

  const StatementScreen(this.subcontractorId, {super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StatementVM()..load(subcontractorId),
      child: Scaffold(
        appBar: AppBar(title: const Text("Statement")),
        body: Consumer<StatementVM>(
          builder: (_, vm, __) {
            // 🔄 Loading state
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // ❌ Error state
            if (vm.error != null) {
              return Center(child: Text(vm.error!));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👤 Subcontractor Info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vm.subcontractor?.name ?? "",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("UTR: ${vm.subcontractor?.utr ?? ""}"),
                    ],
                  ),
                ),

                const Divider(),

                // 📄 List
                Expanded(
                  child: ListView.builder(
                    itemCount: vm.deductions.length,
                    itemBuilder: (_, i) {
                      final d = vm.deductions[i];

                      return ListTile(
                        title: Text(d.description),
                        subtitle: Text(d.date),
                        trailing: Text("£${d.netPayment}"),
                      );
                    },
                  ),
                ),

                const Divider(),

                // 💰 Totals
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _row("Gross", vm.totalGross),
                      _row("Deductions", vm.totalDeductions),
                      _row("Net", vm.totalNet),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _row(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text("£${value.toStringAsFixed(2)}"),
      ],
    );
  }
}