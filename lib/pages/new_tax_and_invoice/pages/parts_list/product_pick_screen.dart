import 'package:flutter/material.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/parts_list/add_part_screen.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';

import '../../../../services/product_service.dart';
import 'product_edit_screen.dart';

class PartListScreen extends StatefulWidget {
  final String? fromScreen;

  const PartListScreen({super.key, this.fromScreen});

  @override
  State<PartListScreen> createState() => _PartListScreenState();
}

class _PartListScreenState extends State<PartListScreen> {
  final _svc = ProductService();
  final _search = TextEditingController();

  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _items = await _svc.getProducts(search: _search.text);
    } catch (e) {
      debugPrint("Failed to load products: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteItem(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Product"),
        content: const Text("Are you sure you want to delete this product?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _svc.deleteProduct(id);
        _load();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Product deleted")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Delete failed: $e")),
        );
      }
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
        title: const Text("Select Part"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final added = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProductNewScreen()),
              );

              if (added == true) {
                _load();
              }
            },
          ),
          IconButton(
            tooltip: "Refresh",
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
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
                labelText: "Search parts",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _load,
                ),
              ),
              onSubmitted: (_) => _load(),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty ? Center(
              child: Text("No parts found."),
            ):ListView.separated(
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final p = _items[i];
                      final name = p["name"] ?? "";
                      final price = p["price"] ?? 0;
                      final stock = p["stock_qty"] ?? 0;

                      return ListTile(
                        title: Text(name),
                        subtitle: Text("£$price • Stock: $stock"),

                        // 👇 EDIT + DELETE ICONS
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                final updated = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductEditScreen(product: p),
                                  ),
                                );

                                if (updated == true) {
                                  _load();
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteItem(p["id"]);
                              },
                            ),
                          ],
                        ),

                        onTap: () {
                          if (widget.fromScreen != null &&
                              widget.fromScreen == "dashboard") {
                            push(ProductEditScreen(product: p));
                          } else {
                            Navigator.pop(context, p);
                          }
                          // RETURN PRODUCT
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
