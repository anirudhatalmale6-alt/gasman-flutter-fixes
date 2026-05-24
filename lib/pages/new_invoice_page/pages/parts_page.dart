import 'package:flutter/material.dart';
import 'package:the_gas_man_app/theme/app_theme.dart';

import '../account_storage_file.dart';
import '../data_model/all_models.dart';


class PartsPage extends StatefulWidget {
  final AccountStorage storage;
  const PartsPage({super.key, required this.storage});

  @override
  State<PartsPage> createState() => _PartsPageState();
}

class _PartsPageState extends State<PartsPage> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final parts = widget.storage.parts
        .where((p) =>
    p.description.toLowerCase().contains(_search.toLowerCase()) ||
        p.sku.toLowerCase().contains(_search.toLowerCase()))
        .toList()
      ..sort((a, b) => a.description.compareTo(b.description));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.kTeal,
        title: const Text('Parts & Materials'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addPartDialog,
          ),
        ],
      ),
      body: Container(
        color: AppColors.kLightBg,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search parts',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: parts.length,
                itemBuilder: (_, i) {
                  final p = parts[i];
                  return Card(
                    margin:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      title: Text(p.description),
                      subtitle: Text(
                        [
                          if (p.sku.isNotEmpty) 'SKU: ${p.sku}',
                          'Cost: £${p.cost.toStringAsFixed(2)}',
                          'Price: £${p.price.toStringAsFixed(2)}',
                        ].join(' • '),
                      ),
                      onTap: () => Navigator.pop(context, p),
                      onLongPress: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Delete part?'),
                            content: Text('Delete ${p.description}?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) {
                          await widget.storage.deletePart(p.id);
                          setState(() {});
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addPartDialog() async {
    final desc = TextEditingController();
    final sku = TextEditingController();
    final cost = TextEditingController();
    final price = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Part'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: desc,
                decoration:
                const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: sku,
                decoration: const InputDecoration(labelText: 'SKU (optional)'),
              ),
              TextField(
                controller: cost,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Cost (£)'),
              ),
              TextField(
                controller: price,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Price (£)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (desc.text.trim().isEmpty) return;
              final c = double.tryParse(cost.text) ?? 0.0;
              final p = double.tryParse(price.text) ?? 0.0;
              final part = Part(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                description: desc.text.trim(),
                sku: sku.text.trim(),
                cost: c,
                price: p,
              );
              await widget.storage.savePart(part);
              if (mounted) {
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
