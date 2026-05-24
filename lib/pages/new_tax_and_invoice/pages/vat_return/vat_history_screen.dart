import 'package:flutter/material.dart';
import 'package:the_gas_man_app/services/vat_return_service.dart';

class VatHistoryScreen extends StatefulWidget {
  const VatHistoryScreen({super.key});

  @override
  State<VatHistoryScreen> createState() => _VatHistoryScreenState();
}

class _VatHistoryScreenState extends State<VatHistoryScreen> {
  List items = [];
  final _vatReturnService = VatReturnService();

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final res = await _vatReturnService.getVatSubmissions();
    items = res["items"];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("VAT Submissions")),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (_, i) {
          final s = items[i];
          return ListTile(
            title: Text("Period ${s["period_key"]}"),
            subtitle: Text(s["submitted_at"]),
            trailing: const Icon(Icons.check_circle, color: Colors.green),
          );
        },
      ),
    );
  }
}
