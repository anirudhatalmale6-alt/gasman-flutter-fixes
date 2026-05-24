import 'package:flutter/material.dart';

import '../../../../services/banking_service.dart';
import '../../../../utils_class/dialog_utils.dart';
import '../../../../utils_class/money.dart';

class BankTransactionsScreen extends StatefulWidget {
  final int bankAccountId;

  const BankTransactionsScreen({super.key, required this.bankAccountId});

  @override
  State<BankTransactionsScreen> createState() => _BankTransactionsScreenState();
}

class _BankTransactionsScreenState extends State<BankTransactionsScreen> {
  final BankingService _svc = BankingService();

  bool loading = true;
  List<dynamic> txns = [];

  // ✅ Date Filters
  DateTime? fromDate;
  DateTime? toDate;

  String? selectedType;

  final fromController = TextEditingController();
  final toController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setDefaultDates(); // 👈 ADD THIS
    _load();
  }

  void _setDefaultDates() {
    final now = DateTime.now();

    // 👉 Last month calculation
    final firstDayLastMonth = DateTime(now.year, now.month - 1, 1);
    final lastDayLastMonth = DateTime(now.year, now.month, 0);

    fromDate = firstDayLastMonth;
    toDate = lastDayLastMonth;

    fromController.text = _formatDate(fromDate!);
    toController.text = _formatDate(toDate!);
    _load();
  }

  // ✅ Format Date
  String _formatDate(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')}/"
        "${d.month.toString().padLeft(2, '0')}/"
        "${d.year}";
  }

  // ✅ Pick Date
  Future<void> _pickDate({required bool isFrom}) async {
    final initial =
        isFrom ? (fromDate ?? DateTime.now()) : (toDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
          fromController.text = _formatDate(picked);
        } else {
          toDate = picked;
          toController.text = _formatDate(picked);
        }
      });
      _load();
    }
  }

  // ✅ Load Transactions (with filter)
  Future<void> _load() async {
    setState(() => loading = true);
    try {
      txns = await _svc.listTransactions(widget.bankAccountId,
          fromDate: fromDate?.toIso8601String().substring(0, 10),
          toDate: toDate?.toIso8601String().substring(0, 10),
          type: selectedType);
    } catch (e) {
      print("Error loading transactions: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // ✅ Clear Filters
  void _clearFilter() {
    setState(() {
      fromDate = null;
      toDate = null;
      fromController.clear();
      toController.clear();
    });
    _load();
  }

  // ✅ Add Transaction
  Future<void> _addTxn({Map<String, dynamic>? txn}) async {
    final isEdit = txn != null;

    // ✅ Prefill values if edit
    final desc = TextEditingController(text: txn?["description"] ?? "");
    final amt = TextEditingController(text: txn?["amount"]?.toString() ?? "0");
    final ref = TextEditingController(text: txn?["reference"] ?? "");
    final category = TextEditingController(text: txn?["category"] ?? "");

    String selectedType = txn?["type"] ?? "DEPOSIT";

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title:
                Text(isEdit ? "Edit Bank Transaction" : "New Bank Transaction"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ TYPE DROPDOWN
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(
                      labelText: "Type",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: "DEPOSIT", child: Text("DEPOSIT")),
                      DropdownMenuItem(
                          value: "WITHDRAWAL", child: Text("WITHDRAWAL")),
                      DropdownMenuItem(
                          value: "TRANSFER", child: Text("TRANSFER")),
                      DropdownMenuItem(value: "REFUND", child: Text("REFUND")),
                      DropdownMenuItem(value: "FEE", child: Text("FEE")),
                      DropdownMenuItem(
                          value: "INTEREST", child: Text("INTEREST")),
                    ],
                    onChanged: (value) {
                      setState(() => selectedType = value!);
                    },
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: desc,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: amt,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Amount",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: ref,
                    decoration: const InputDecoration(
                      labelText: "Reference",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: category,
                    decoration: const InputDecoration(
                      labelText: "Category",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(isEdit ? "Update" : "Save"),
              ),
            ],
          );
        },
      ),
    );

    if (ok != true) return;

    try {
      if (isEdit) {
        await _svc.createTransaction(
          id: txn["id"],
          bankAccountId: txn["bank_account_id"],
          txnDate: txn["transaction_date"].toString().substring(0, 10),
          type: selectedType,
          description: desc.text.trim(),
          amount: double.tryParse(amt.text) ?? 0,
          reference: ref.text.trim(),
          category: category.text.trim(),
        );
      } else {
        await _svc.createTransaction(
          bankAccountId: widget.bankAccountId,
          txnDate: DateTime.now().toIso8601String().substring(0, 10),
          type: selectedType,
          description: desc.text.trim(),
          amount: double.tryParse(amt.text) ?? 0,
          reference: ref.text.trim(),
          category: category.text.trim(),
        );
      }

      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Save failed: $e")),
        );
      }
    }
  }

  // ✅ Reconcile
  Future<void> _reconcile(dynamic txn) async {
    final txnId = txn["id"] as int;

    Map<String, dynamic> suggestions;
    try {
      suggestions = await _svc.suggestMatches(txnId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Suggest failed: $e")),
        );
      }
      return;
    }

    final type = suggestions["type"]?.toString() ?? "";
    final list = (suggestions["suggestions"] as List?) ?? [];

    if (list.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No suggestions found.")),
        );
      }
      return;
    }

    final chosen = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text("Match to $type"),
        children: list.map((s) {
          final title = type == "INVOICE"
              ? "Invoice ${(s["invoice_number"] ?? s["invoiceNumber"])}"
              : "Bill ${(s["bill_number"] ?? s["billNumber"])}";

          final bal = (s["balance"] as num?)?.toDouble() ?? 0;

          return SimpleDialogOption(
            onPressed: () =>
                Navigator.pop(context, Map<String, dynamic>.from(s)),
            child: Text("$title (bal ${formatMoney(bal)})"),
          );
        }).toList(),
      ),
    );

    if (chosen == null) return;

    try {
      await _svc.match(
        txnId: txnId,
        referenceType: type,
        referenceId: chosen["id"] as int,
      );
      await _load();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Reconciled.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Match failed: $e")),
        );
      }
    }
  }

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bank Transactions"),
        actions: [
          IconButton(onPressed: _addTxn, icon: const Icon(Icons.add)),
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 10.0,
          ),
          // ✅ Date Filters UI
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: fromController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "From Date",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () => _pickDate(isFrom: true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: toController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "To Date",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () => _pickDate(isFrom: false),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),

          // ✅ TYPE DROPDOWN
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: DropdownButtonFormField<String>(
              initialValue: selectedType,
              decoration: const InputDecoration(
                labelText: "Transaction Type",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "DEPOSIT", child: Text("DEPOSIT")),
                DropdownMenuItem(
                    value: "WITHDRAWAL", child: Text("WITHDRAWAL")),
                DropdownMenuItem(value: "TRANSFER", child: Text("TRANSFER")),
                DropdownMenuItem(value: "REFUND", child: Text("REFUND")),
                DropdownMenuItem(value: "FEE", child: Text("FEE")),
                DropdownMenuItem(value: "INTEREST", child: Text("INTEREST")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedType = value;
                });
                _load();
              },
            ),
          ),

          // ✅ List
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: txns.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final t = txns[i];
                      final amt = double.tryParse(t["amount"].toString()) ?? 0;
                      final status = t["status"]?.toString() ?? "";
                      final type = t["type"]?.toString() ?? "";
                      final isCredit = amt >= 0;

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: status == "RECONCILED"
                              ? null
                              : () => _reconcile(t),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // 🔵 LEFT ICON
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isCredit
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isCredit
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    color: isCredit ? Colors.green : Colors.red,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // 📄 TEXT SECTION
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t["description"]?.toString() ?? "",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${_formatDate(DateTime.parse(t["transaction_date"]))} • $type",
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      if (status.isNotEmpty)
                                        Container(
                                          margin: const EdgeInsets.only(top: 4),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: status == "RECONCILED"
                                                ? Colors.green.withOpacity(0.1)
                                                : Colors.orange
                                                    .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            status,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: status == "RECONCILED"
                                                  ? Colors.green
                                                  : Colors.orange,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                // 💰 AMOUNT + ACTIONS
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      formatMoney(amt),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: isCredit
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // ✏️ EDIT
                                        GestureDetector(
                                          onTap: () {
                                            _addTxn(txn: t);
                                          },
                                          child: const Icon(
                                            Icons.edit,
                                            size: 18,
                                            color: Colors.blue,
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        // 🗑 DELETE
                                        GestureDetector(
                                          onTap: () async {
                                            final confirm = await DialogUtils
                                                .showDeleteDialog(
                                              context: context,
                                              itemName: t["description"] ??
                                                  "Transaction",
                                              onDelete: () async {
                                                await _svc
                                                    .deleteTransaction(t['id']);
                                              },
                                            );

                                            if (confirm) {
                                              _load(); // refresh list
                                            }
                                          },
                                          child: const Icon(
                                            Icons.delete,
                                            size: 18,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    )
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
        ],
      ),
    );
  }
}
