import 'package:flutter/material.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pdf_service.dart';

import '../../../../services/product_service.dart';

class StockValuationScreen extends StatefulWidget {
  const StockValuationScreen({super.key});

  @override
  State<StockValuationScreen> createState() =>
      _StockValuationScreenState();
}

class _StockValuationScreenState extends State<StockValuationScreen> {
  final _svc = ProductService();

  DateTime selectedDate = DateTime.now();


  Map? data;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final dateStr = selectedDate.toIso8601String();

    data = await _svc.getStockValuationByDate(dateStr);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final items = data?["items"] ?? [];
    final totals = data?["totals"] ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text("Stock Valuation"),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => PdfService().exportPdf(data!),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: pickDate,
          ),

        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: [
          ...items.map((e) {
            return ListTile(
              title: Text(e["name"]),
              subtitle: Text(
                  "Qty: ${e["stock_qty"]} • Avg: £${e["avg_cost"]}"),
              trailing: Text("£${e["total_value"]}"),
            );
          }),

          const Divider(),

          ListTile(
            title: const Text("TOTAL"),
            trailing: Text("£${totals["total_value"]}"),
          )
        ],
      ),
    );
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });

      load(); // reload report
    }
  }

}
