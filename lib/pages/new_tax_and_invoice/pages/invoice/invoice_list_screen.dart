import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/data_models/invoice_detail.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/invoice/invoice_new_screen.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';

import '../../../../services/invoice_service.dart';
import '../../../../utils_class/dialog_utils.dart';
import '../../../../utils_class/money.dart';
import 'invoice_view_screen.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  final InvoiceService _service = InvoiceService();

  bool loading = true;

  List<dynamic> items = [];
  List<dynamic> filteredItems = [];

  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);

    try {
      final data = await _service.list();

      setState(() {
        items = data;
        filteredItems = data;
      });

      _applyFilter();
    } catch (e) {
      debugPrint("Failed to load invoices: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _applyFilter() {
    setState(() {
      filteredItems = items.where((inv) {
        final invoiceDate = DateTime.parse(inv["invoice_date"]);

        if (fromDate != null && invoiceDate.isBefore(fromDate!)) {
          return false;
        }

        if (toDate != null &&
            invoiceDate.isAfter(
              toDate!.add(const Duration(days: 1)),
            )) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      fromDate = picked;
      _applyFilter();
    }
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: toDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      toDate = picked;
      _applyFilter();
    }
  }

  void _clearFilter() {
    setState(() {
      fromDate = null;
      toDate = null;
      filteredItems = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Invoices"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await push(InvoiceNewScreen());
              _load();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickFromDate,
                    child: Text(
                      fromDate == null
                          ? "From Date"
                          : DateFormat("dd-MM-yyyy").format(fromDate!),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickToDate,
                    child: Text(
                      toDate == null
                          ? "To Date"
                          : DateFormat("dd-MM-yyyy").format(toDate!),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _clearFilter,
                  icon: const Icon(Icons.clear),
                ),
              ],
            ),
          ),
          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: items.isEmpty
                        ? Center(
                            child: Text("No Invoices found"),
                          )
                        : ListView.separated(
                            itemCount: filteredItems.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final inv = filteredItems[i];

                              final id = inv["id"] as int;

                              final number = inv["invoice_number"] ??
                                  inv["invoiceNumber"] ??
                                  "INV";

                              final status = inv["status"] ?? "";

                              final invoiceDate = inv["invoice_date"] ?? "";

                              final total = double.tryParse(inv["total"]);

                              return ListTile(
                                title: Text(number.toString()),
                                subtitle: Text(
                                  "Status: $status    "
                                  "${DateFormat("dd-MM-yyyy").format(DateTime.parse(invoiceDate))}",
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      formatMoney(total!),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            try {
                                              InvoiceDetailMaster
                                                  invoiceDetails =
                                                  await _service.getDetail(id);

                                              await push(
                                                InvoiceNewScreen(
                                                  invoiceDetail: invoiceDetails,
                                                ),
                                              );

                                              _load();
                                            } catch (e) {}
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
                                            final confirm = await DialogUtils
                                                .showDeleteDialog(
                                              context: context,
                                              itemName: "Invoice",
                                              onDelete: () async {
                                                await _service.deleteInvoice(
                                                  id,
                                                  onError: () {
                                                    Navigator.pop(context);
                                                  },
                                                );

                                                _load();
                                              },
                                            );

                                            if (confirm) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Invoice deleted",
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
                                onTap: () {
                                  push(
                                    InvoiceViewScreen(
                                      invoiceId: id,
                                    ),
                                  );
                                },
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
