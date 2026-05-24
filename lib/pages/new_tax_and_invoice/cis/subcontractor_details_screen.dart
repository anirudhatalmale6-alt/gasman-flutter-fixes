import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/cis/deduction_list_screen.dart';

import 'statements_screen.dart';
import 'view_models/sub_cintractor_vm.dart';


class SubcontractorDetailScreen extends StatefulWidget {
  final int id;

  const SubcontractorDetailScreen(this.id, {super.key});

  @override
  State<SubcontractorDetailScreen> createState() =>
      _SubcontractorDetailScreenState();
}

class _SubcontractorDetailScreenState
    extends State<SubcontractorDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SubcontractorVM>().loadSingle(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubcontractorVM>(
      builder: (_, vm, __) {
        final s = vm.selected;

        if (vm.isLoading || s == null) {
          return Scaffold(
            appBar: AppBar(title: Text("Subcontractor")),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(s.name),
            actions: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  // TODO: navigate to edit screen
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  await vm.delete(s.id);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👤 Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _row("Name", s.name),
                        _row("UTR", s.utr),
                        _row("NINO", s.nino ?? "-"),
                        _row("Phone", s.phone ?? "-"),
                        _row("Email", s.email ?? "-"),
                        _row("City", s.city ?? "-"),
                        _row("Postcode", s.postcode ?? "-"),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 🧾 Deduction Rate + Status
                Card(
                  child: ListTile(
                    title: Text("Deduction Rate"),
                    subtitle: Text("${s.deductionRate}%"),
                    trailing: _statusChip(s.verificationStatus),
                  ),
                ),

                const SizedBox(height: 16),

                // ✅ Verify Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await vm.verify(s.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Verification updated")),
                      );
                    },
                    child: Text("Verify with HMRC"),
                  ),
                ),

                const SizedBox(height: 16),

                // 🔗 Actions
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.receipt),
                        title: Text("View Statement"),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StatementScreen(s.id),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.payments),
                        title: Text("View Deductions"),
                        onTap: () {
                          // TODO: navigate to deduction list filtered by subcontractor
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DeductionListScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;

    switch (status.toLowerCase()) {
      case "verified":
        color = Colors.green;
        break;
      case "unverified":
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Chip(
      label: Text(status),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color),
    );
  }
}