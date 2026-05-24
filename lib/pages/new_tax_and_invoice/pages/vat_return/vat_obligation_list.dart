import 'package:flutter/material.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/vat_return/vat_return_screen.dart';
import 'package:the_gas_man_app/services/vat_return_service.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';

class Obligation {
  final String periodKey;
  final String start;
  final String end;
  final String due;
  final String status;

  Obligation({
    required this.periodKey,
    required this.start,
    required this.end,
    required this.due,
    required this.status,
  });

  factory Obligation.fromJson(Map<String, dynamic> json) {
    return Obligation(
      periodKey: json['periodKey'],
      start: json['start'],
      end: json['end'],
      due: json['due'],
      status: json['status'],
    );
  }
}

class ObligationListScreen extends StatefulWidget {
  const ObligationListScreen({super.key});

  @override
  State<ObligationListScreen> createState() =>
      _ObligationListScreenState();
}

class _ObligationListScreenState extends State<ObligationListScreen> {

  VatReturnService _svc = VatReturnService();
  List<Obligation> obligations = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      setState(() {
        loading = true;
        error = null;
      });


      final response = await _svc.getVatObligations();

      final list = response!['obligations'] as List;
      obligations = list
          .map((e) => Obligation.fromJson(e))
          .toList();

    } catch (e) {
      error = e.toString();
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> refresh() async {
    await load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("VAT Obligations"),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Error: $error"),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: load,
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (obligations.isEmpty) {
      return const Center(child: Text("No obligations found"));
    }

    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView.builder(
        itemCount: obligations.length,
        itemBuilder: (context, index) {
          final item = obligations[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text("Period: ${item.periodKey}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Start: ${item.start}"),
                  Text("End: ${item.end}"),
                  Text("Due: ${item.due}"),
                ],
              ),
              trailing: InkWell(
                onTap: (){
                 // push(VatReturnScreen(onligation: item,));
                  push(VatReturnScreen());
                },
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: item.status == "O"
                        ? Colors.orange
                        : Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.status == "O" ? "Open" : "Closed",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}