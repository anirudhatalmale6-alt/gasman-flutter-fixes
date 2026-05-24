import 'package:flutter/material.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/stocks/product_stock_history_screen.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';
import '../../../../services/product_service.dart';

class ProductEditScreen extends StatefulWidget {
  final Map product;

  const ProductEditScreen({super.key, required this.product});

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  final _svc = ProductService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController name;
  late TextEditingController description;
  late TextEditingController sku;
  late TextEditingController price;
  late TextEditingController cost;
  late TextEditingController stock;

  double selectedVat = 0;
  bool saving = false;

  @override
  void initState() {
    super.initState();

    name = TextEditingController(text: widget.product["name"] ?? "");
    description =
        TextEditingController(text: widget.product["description"] ?? "");
    sku = TextEditingController(text: widget.product["sku"] ?? "");
    price = TextEditingController(text: "${widget.product["price"] ?? 0}");
    cost = TextEditingController(text: "${widget.product["cost"] ?? 0}");
    stock =
        TextEditingController(text: "${widget.product["stock_qty"] ?? 0}");

    selectedVat = double.tryParse((widget.product["vat_rate"] ?? 0)) ?? 0;
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => saving = true);

    try {
      await _svc.updateProduct(
        id: widget.product["id"],
        name: name.text.trim(),
        description:
        description.text.isEmpty ? null : description.text.trim(),
        sku: sku.text.isEmpty ? null : sku.text.trim(),
        price: double.parse(price.text),
        cost: double.parse(cost.text),
        stockQty: double.parse(stock.text),
        vatRate: selectedVat,
      );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      showError("Error: $e");
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> delete() async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Product"),
        content:
        const Text("Are you sure you want to delete this product?"),
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
      await _svc.deleteProduct(widget.product["id"]);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    name.dispose();
    description.dispose();
    sku.dispose();
    price.dispose();
    cost.dispose();
    stock.dispose();
    super.dispose();
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    TextInputType? type,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stockQty = double.tryParse(stock.text) ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Product"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: delete,
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field(
              label: "Name",
              controller: name,
              validator: (v) =>
              v == null || v.isEmpty ? "Name is required" : null,
            ),
            _field(
              label: "Description",
              controller: description,
            ),
            _field(
              label: "SKU",
              controller: sku,
            ),
            _field(
              label: "Sale Price",
              controller: price,
              type: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return "Enter price";
                if (double.tryParse(v) == null) return "Invalid number";
                return null;
              },
            ),
            _field(
              label: "Cost",
              controller: cost,
              type: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return "Enter cost";
                if (double.tryParse(v) == null) return "Invalid number";
                return null;
              },
            ),

            /// VAT Dropdown
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DropdownButtonFormField<double>(
                value: selectedVat,
                decoration: InputDecoration(
                  labelText: "VAT %",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 0, child: Text("0%")),
                  DropdownMenuItem(value: 10, child: Text("10%")),
                  DropdownMenuItem(value: 20, child: Text("20%")),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedVat = value ?? 0;
                  });
                },
              ),
            ),

            _field(
              label: "Stock Qty",
              controller: stock,
              type: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return "Enter stock";
                if (double.tryParse(v) == null) return "Invalid number";
                return null;
              },
            ),

            /// Low Stock Warning
            if (stockQty <= 2)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: const [
                    Icon(Icons.warning, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      "Low stock",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 10),

            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: saving ? null : save,
                child: saving
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child:
                  CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text("Save Changes"),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: () {
                  push(ProductStockHistoryScreen(
                      product: widget.product));
                },
                child: const Text("View Product History"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}