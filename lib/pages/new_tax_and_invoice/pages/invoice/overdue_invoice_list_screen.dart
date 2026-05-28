import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/data_models/invoice_detail.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/invoice/invoice_new_screen.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';

import '../../../../services/invoice_service.dart';
import '../../../../utils_class/money.dart';
import 'invoice_view_screen.dart';

class OverdueInvoiceListScreen extends StatefulWidget {
  const OverdueInvoiceListScreen({super.key});

  @override
  State<OverdueInvoiceListScreen> createState() =>
      _OverdueInvoiceListScreenState();
}

class _OverdueInvoiceListScreenState extends State<OverdueInvoiceListScreen> {
  final InvoiceService _service = InvoiceService();

  bool loading = true;
  List<dynamic> items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      items = await _service.listOverdue();
    } catch (e) {
      debugPrint("Failed to load overdue invoices: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  int _daysOverdue(String? dueDateStr) {
    if (dueDateStr == null) return 0;
    final dueDate = DateTime.tryParse(dueDateStr);
    if (dueDate == null) return 0;
    return DateTime.now().difference(dueDate).inDays;
  }

  Color _overdueColor(int days) {
    if (days > 30) return Colors.red.shade700;
    if (days > 14) return Colors.red;
    if (days > 7) return Colors.orange;
    return Colors.amber.shade700;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Overdue Invoices"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 64, color: Colors.green.shade300),
                          const SizedBox(height: 16),
                          const Text(
                            "No overdue invoices",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "All invoices are paid or not yet due",
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final inv = items[i];
                        final id = inv["id"] as int;
                        final number = inv["invoice_number"] ??
                            inv["invoiceNumber"] ??
                            "INV";
                        final customerName =
                            inv["customer_name"] ?? "Unknown Customer";
                        final dueDateStr = inv["due_date"]?.toString() ?? "";
                        final total =
                            double.tryParse(inv["total"]?.toString() ?? "0") ??
                                0;
                        final balance = double.tryParse(
                                inv["balance"]?.toString() ?? "0") ??
                            total;
                        final days = _daysOverdue(dueDateStr);
                        final color = _overdueColor(days);

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: color.withOpacity(0.3)),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              push(InvoiceViewScreen(invoiceId: id))
                                  .then((_) => _load());
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.warning_amber_rounded,
                                          color: color, size: 22),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          number.toString(),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          "$days days overdue",
                                          style: TextStyle(
                                            color: color,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(Icons.person_outline,
                                          size: 16, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          customerName,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today,
                                          size: 14, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Due: ${dueDateStr.isNotEmpty ? DateFormat("dd-MM-yyyy").format(DateTime.parse(dueDateStr)) : "N/A"}",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        formatMoney(balance),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
