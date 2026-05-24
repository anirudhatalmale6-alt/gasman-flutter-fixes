import 'package:flutter/material.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/csv_import/csv_import_screen.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/customer/create_customer_screen.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';

import '../../../../services/customer_service.dart';
import '../../../../utils_class/dialog_utils.dart';

class CustomerListScreen extends StatefulWidget {
  final String? fromScreen;

  const CustomerListScreen({super.key, this.fromScreen});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
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
      _items = await _svc.getCustomers(search: _search.text);
    } catch (e) {
      debugPrint("Failed to load customers: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }



  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void deleteCustomer({int? id}) async {
    final success = await DialogUtils.showDeleteDialog(
      context: context,
      itemName: "Customer",
      onDelete: () async {
        final dynamic = await _svc.deleteCustomer(id: id!);
        _load(); // 👈 your API
      },
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Customer deleted")),
      );

      // optionally refresh list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customers"),
        actions: [
          IconButton(
            onPressed: () async {
              await push(CustomerNewScreen());
              _load();
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () async {
              await push(CsvImportScreen(type: "customers"));
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
                labelText: "Search customers",
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
                        final c = _items[i];
                        final name = c["name"]?.toString() ?? "Customer";
                        final email = c["email"]?.toString() ?? "";
                        final phone = c["phone"]?.toString() ?? "";

                        return ListTile(
                          leading: const Icon(Icons.person),
                          onTap: () {
                            if (widget.fromScreen != null &&
                                (widget.fromScreen == "invoice")) {
                              Navigator.pop(context, c);
                            } else {
                              push(CustomerNewScreen(
                                customerDetails: c,
                              ));
                            }
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
                                onPressed: () {
                                  push(CustomerNewScreen(
                                    customerDetails: c,
                                  ));
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  deleteCustomer(id: c['id']);
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
