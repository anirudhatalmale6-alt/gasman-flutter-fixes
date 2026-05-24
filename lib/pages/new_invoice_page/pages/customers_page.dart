import 'package:flutter/material.dart';
import 'package:the_gas_man_app/theme/app_theme.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';

import '../../new_tax_and_invoice/pages/customer/create_customer_screen.dart';
import '../account_storage_file.dart';
import '../data_model/all_models.dart';


class CustomersPage extends StatefulWidget {
  final AccountStorage storage;

  final String? fromScreen;

  const CustomersPage({super.key, required this.storage,this.fromScreen});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final list = widget.storage.customers
        .where((c) =>
    c.name.toLowerCase().contains(_search.toLowerCase()) ||
        c.email.toLowerCase().contains(_search.toLowerCase()) ||
        c.phone.toLowerCase().contains(_search.toLowerCase()))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.kTeal,
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addCustomerDialog,
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
                  hintText: 'Search customers',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final c = list[i];
                  return Card(
                    margin:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      title: Text(c.name),
                      subtitle: Text(
                        [
                          if (c.phone.isNotEmpty) c.phone,
                          if (c.email.isNotEmpty) c.email,
                        ].join(' • '),
                      ),
                      onTap: (){
                        if(widget.fromScreen != null && widget.fromScreen == "invoice"){
                          Navigator.pop(context, c);
                        }else{
                          push(CustomerNewScreen(customerDetails: c,));
                        }
                      },
                      onLongPress: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Delete customer?'),
                            content: Text('Delete ${c.name}?'),
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
                          await widget.storage.deleteCustomer(c.id);
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

  Future<void> _addCustomerDialog() async {
    final name = TextEditingController();
    final address = TextEditingController();
    final email = TextEditingController();
    final phone = TextEditingController();
    final notes = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Customer'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: address,
                decoration: const InputDecoration(labelText: 'Address'),
                maxLines: 2,
              ),
              TextField(
                controller: phone,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: email,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: notes,
                decoration: const InputDecoration(labelText: 'Notes'),
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
              if (name.text.trim().isEmpty) return;
              final c = Customer(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: name.text.trim(),
                address: address.text.trim(),
                email: email.text.trim(),
                phone: phone.text.trim(),
                notes: notes.text.trim(),
              );
              await widget.storage.saveCustomer(c);
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
