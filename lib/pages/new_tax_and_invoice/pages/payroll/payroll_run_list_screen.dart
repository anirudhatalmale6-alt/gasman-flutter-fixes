import 'package:flutter/material.dart';
import 'package:the_gas_man_app/pages/finance/expense_form_page.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/payroll/payroll_new_run_screen.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/payroll/payroll_run_view_screen.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';

import '../../../../services/payroll_service.dart';
import '../../../../utils_class/dialog_utils.dart';

class PayrollRunListScreen extends StatefulWidget {
  const PayrollRunListScreen({super.key});

  @override
  State<PayrollRunListScreen> createState() => _PayrollRunListScreenState();
}

class _PayrollRunListScreenState extends State<PayrollRunListScreen> {
  final PayrollService _svc = PayrollService();
  bool loading = true;
  List<dynamic> runs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      runs = await _svc.listRuns();
    } catch (e) {
      //if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Load failed: $e")));
      print(" _svc.listRuns() Error ${e}");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payroll Runs"),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          IconButton(
            onPressed: () {
              push(PayrollNewRunScreen()).then((value) {
                _load();
              });
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : runs.isEmpty
              ? Center(
                  child: Text("No payrolls found..."),
                )
              : ListView.separated(
                  itemCount: runs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final r = runs[i];

                    return ListTile(
                      title: Text("Run #${r["id"]}"),
                      subtitle: Text(
                        "${formatDate(DateTime.parse(r["period_start"]))} → "
                        "${formatDate(DateTime.parse(r["period_end"]))} • ${r["status"]}",
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ✏️ Edit
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              push(PayrollNewRunScreen(
                                // pass runId if needed
                                runId: r['id'],
                              ));
                            },
                          ),

                          // 🗑️ Delete (using your DialogUtils)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final deleted =
                                  await DialogUtils.showDeleteDialog(
                                context: context,
                                itemName: "Run #${r["id"]}",
                                onDelete: () async {
                                  await _svc.deleteRun(r["id"]);
                                },
                              );

                              // ✅ Only update UI if deletion succeeded
                              if (deleted) {
                                setState(() {
                                  runs.removeAt(i);
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Deleted successfully"),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: () => push(
                        PayrollRunViewScreen(runId: r['id']),
                      ),
                    );
                  },
                ),
    );
  }
}
