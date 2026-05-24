import 'package:flutter/material.dart';
import '../../../../services/product_service.dart';

class ProductNewScreen extends StatefulWidget {
  const ProductNewScreen({super.key});

  @override
  State<ProductNewScreen> createState() => _ProductNewScreenState();
}

class _ProductNewScreenState extends State<ProductNewScreen> {
  final _svc = ProductService();

  final name = TextEditingController();
  final description = TextEditingController();
  final sku = TextEditingController();
  final price = TextEditingController();
  final cost = TextEditingController();
  //final vatRate = TextEditingController();
  final stock = TextEditingController();

  bool saving = false;

  double selectedVat = 0;

  Future<void> save() async {
    if (name.text.isEmpty) return;

    setState(() => saving = true);

    await _svc.createProduct(
      name: name.text,
      description: description.text.isEmpty ? null : description.text,
      sku: sku.text.isEmpty ? null : sku.text,
      price: double.tryParse(price.text) ?? 0,
      cost: double.tryParse(cost.text) ?? 0,
      vatRate: double.tryParse(selectedVat.toString()) ?? 0,
      stockQty: double.tryParse(stock.text) ?? 0,
    );

    setState(() => saving = false);

    Navigator.pop(context,true);
  }

  @override
  void dispose() {
    name.dispose();
    description.dispose();
    sku.dispose();
    price.dispose();
    cost.dispose();
  //  vatRate.dispose();
    stock.dispose();
    super.dispose();
  }

  Widget buildField(TextEditingController controller, String label,
      {TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Part")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildField(name, "Name"),
            buildField(description, "Description"),
            buildField(sku, "SKU"),
            buildField(price, "Price", type: TextInputType.number),
            buildField(cost, "Cost", type: TextInputType.number),
           // buildField(vatRate, "VAT %", type: TextInputType.number),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DropdownButtonFormField<double>(
                value: selectedVat,
                decoration: const InputDecoration(
                  labelText: "VAT %",
                  border: OutlineInputBorder(),
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
            buildField(stock, "Stock Qty", type: TextInputType.number),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saving ? null : save,
                child: saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save"),
              ),
            )
          ],
        ),
      ),
    );
  }
}