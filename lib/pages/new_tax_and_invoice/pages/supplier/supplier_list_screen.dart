import 'package:flutter/material.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/supplier/create_supplier_screen.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';

import '../../../../services/customer_service.dart';
import '../../../../utils_class/dialog_utils.dart';
import '../csv_import/csv_import_screen.dart';

class SupplierListScreen extends StatefulWidget {
  final bool? isSelection;

  const SupplierListScreen({super.key, this.isSelection = false});

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  final MasterDataService _svc = MasterDataService();
  final TextEditingController _search = TextEditingController();

  bool _loading = true;
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _items = await _svc.getSuppliers(search: _search.text);
    } catch (e) {
      debugPrint("Failed to load suppliers: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Suppliers"),
        actions: [
          IconButton(
            onPressed: () async {
              await push(SupplierNewScreen());
              _load();
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () async {
              await push(CsvImportScreen(type: "suppliers"));
              _load();
            },
            icon: const Icon(Icons.import_export),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                labelText: "Search suppliers",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _load,
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _load(),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final s = _items[i];
                        final name = s["name"]?.toString() ?? "Supplier";
                        final email = s["email"]?.toString() ?? "";
                        final phone = s["phone"]?.toString() ?? "";
                        return ListTile(
                          leading: const Icon(Icons.business),
                          onTap: () {
                            Navigator.pop(context, s);
                          },
                          title: Text(name),
                          subtitle: Text(
                            [email, phone]
                                .where((e) => e.isNotEmpty)
                                .join(" • "),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  await push(SupplierNewScreen(
                                    supplierDetails: s,
                                  ));
                                  _load();
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirm =
                                      await DialogUtils.showDeleteDialog(
                                    context: context,
                                    itemName: name,
                                    onDelete: () async {
                                      await _svc.deleteSupplier(id: s['id']);
                                      _load(); // 👈 API call
                                    },
                                  );

                                  if (confirm) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("Supplier deleted")),
                                    );

                                    // 👉 Refresh list if needed
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
