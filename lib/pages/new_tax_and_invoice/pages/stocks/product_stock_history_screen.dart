import 'package:flutter/material.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/stocks/product_stock_chart.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';

import '../../../../services/product_service.dart';

class ProductStockHistoryScreen extends StatefulWidget {
  final Map product;

  const ProductStockHistoryScreen({super.key, required this.product});

  @override
  State<ProductStockHistoryScreen> createState() =>
      _ProductStockHistoryScreenState();
}

class _ProductStockHistoryScreenState
    extends State<ProductStockHistoryScreen> {
  final _svc = ProductService();

  List movements = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    movements = await _svc.getStockMovements(widget.product["id"]);
    setState(() => loading = false);
  }

  Color getColor(String type) {
    if (type == "invoice") return Colors.red;
    if (type == "bill") return Colors.green;
    return Colors.orange;
  }

  IconData getIcon(String type) {
    if (type == "invoice") return Icons.remove;
    if (type == "bill") return Icons.add;
    return Icons.sync;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.product["name"]} Stock History"),
        actions: [
          IconButton(onPressed: (){
            push(StockChart(data: movements));
          }, icon: Icon(Icons.area_chart))
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
        itemCount: movements.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final m = movements[i];

          final type = m["type"] ?? "";
          final qty = (m["qty_change"] ?? 0).toDouble();
          final balance = (m["balance_after"] ?? 0).toDouble();
          final ref = m["reference"] ?? "";
          final date = m["created_at"] ?? "";

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: getColor(type),
              child: Icon(getIcon(type), color: Colors.white),
            ),
            title: Text(
              "${type.toUpperCase()} ${qty > 0 ? "+$qty" : qty}",
              style: TextStyle(
                color: getColor(type),
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "Balance: $balance\n$ref • $date",
            ),
          );
        },
      ),
    );
  }
}

