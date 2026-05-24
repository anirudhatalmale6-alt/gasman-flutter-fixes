/*import 'package:flutter/material.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';

import '../../../../services/product_service.dart';
import 'add_part_screen.dart';
import 'product_edit_screen.dart';

class PartsListScreen extends StatefulWidget {
  const PartsListScreen({super.key});

  @override
  State<PartsListScreen> createState() => _PartsListScreenState();
}

class _PartsListScreenState extends State<PartsListScreen> {
  final _svc = ProductService();
  final _search = TextEditingController();

  List items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    items = await _svc.getProducts(search: _search.text);
    setState(() => loading = false);
  }

  Future<void> deleteItem(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete"),
        content: const Text("Are you sure you want to delete this item?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              _svc.deleteProduct(id);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _svc.deleteProduct(id); // make sure this method exists
      load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Parts / Products"),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              push(ProductNewScreen());
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _search,
              decoration: const InputDecoration(
                labelText: "Search parts",
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => load(),
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                    ? const Center(child: Text("No Parts Found"))
                    : ListView.builder(
                        itemCount: items.length,
                        physics: ClampingScrollPhysics(),
                        itemBuilder: (_, i) {
                          final p = items[i];

                          return ListTile(
                            title: Text(p["name"]),
                            subtitle: Text(
                                "£${p["price"]} • Stock: ${p["stock_qty"]}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () async {
                                    final updated = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ProductEditScreen(product: p),
                                      ),
                                    );

                                    if (updated == true) {
                                      load();
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    deleteItem(p["id"]);
                                  },
                                ),
                              ],
                            ),

                            onTap: () async {
                              print("Clicked.....");
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductEditScreen(product: p),
                                ),
                              );

                              if (updated == true) {
                                load();
                              }
                            },
                          );
                        },
                      ),
          )
        ],
      ),
    );
  }
}*/
