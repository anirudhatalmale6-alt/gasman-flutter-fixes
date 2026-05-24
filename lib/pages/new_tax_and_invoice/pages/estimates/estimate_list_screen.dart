import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../services/estimate_service.dart';
import '../../../../utils_class/dialog_utils.dart';
import '../../../../utils_class/money.dart';
import 'estimate_form_screen.dart';

class EstimateListScreen extends StatefulWidget {
  const EstimateListScreen({super.key});

  @override
  State<EstimateListScreen> createState() => _EstimateListScreenState();
}

class _EstimateListScreenState extends State<EstimateListScreen> {
  final EstimateService _service = EstimateService();

  List estimates = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      setState(() => loading = true);

      estimates = await _service.getEstimates();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> deleteEstimate(int id) async {
    try {
      await _service.deleteEstimate(id);
      load();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Estimates"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const EstimateFormScreen(),
            ),
          );

          if (res == true) {
            load();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : estimates.isEmpty
              ? Center(
                  child: Text("No estimates found"),
                )
              : ListView.builder(
                  itemCount: estimates.length,
                  itemBuilder: (_, i) {
                    final e = estimates[i];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text(
                          e["estimate_number"] ?? "",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              e["customer_name"] ?? "",
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Status: ${e["status"] ?? "draft"}    "
                              "${DateFormat("dd-MM-yyyy").format(DateTime.parse(e["estimate_date"]))}",
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formatMoney(
                                double.tryParse(
                                      e["total"]?.toString() ?? "0",
                                    ) ??
                                    0,
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    try {
                                      final res = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => EstimateFormScreen(
                                            invoice: e,
                                          ),
                                        ),
                                      );

                                      if (res == true) {
                                        load();
                                      }
                                    } catch (err) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            err.toString(),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () async {
                                    final confirm =
                                        await DialogUtils.showDeleteDialog(
                                      context: context,
                                      itemName: "Estimate",
                                      onDelete: () async {
                                        await deleteEstimate(
                                          e["id"],
                                        );

                                        load();
                                      },
                                    );

                                    if (confirm == true && mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Estimate deleted",
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () async {
                          final res = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EstimateFormScreen(
                                invoice: e,
                              ),
                            ),
                          );

                          if (res == true) {
                            load();
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
