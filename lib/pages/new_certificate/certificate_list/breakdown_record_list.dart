import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../breakdown_record/breakdown_record_page.dart';

class BreakdownRecordsListScreen extends StatefulWidget {
  const BreakdownRecordsListScreen({super.key});

  @override
  State<BreakdownRecordsListScreen> createState() =>
      _BreakdownRecordsListScreenState();
}

class _BreakdownRecordsListScreenState
    extends State<BreakdownRecordsListScreen> {
  List<BreakdownRecord> records = [];
  List<BreakdownRecord> filteredRecords = [];

  bool loading = true;

  String selectedMonth = "All";

  final List<String> months = [
    "All",
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  @override
  void initState() {
    super.initState();
    loadRecords();
  }

  /// ================= LOAD =================
  Future<void> loadRecords() async {
    setState(() => loading = true);

    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('breakdown_records');

    if (data != null) {
      final decoded = jsonDecode(data);

      if (decoded is List) {
        records = decoded.map((e) => BreakdownRecord.fromJson(e)).toList();
      } else {
        records = [BreakdownRecord.fromJson(decoded)];
      }
    } else {
      records = [];
    }

    applyFilter();

    setState(() => loading = false);
  }

  /// ================= FILTER =================
  void applyFilter() {
    if (selectedMonth == "All") {
      filteredRecords = List.from(records);
      return;
    }

    final selectedMonthIndex = months.indexOf(selectedMonth);

    filteredRecords = records.where((record) {
      try {
        return record.createdAt.month == selectedMonthIndex;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  /// ================= DELETE =================
  Future<void> deleteRecord(int originalIndex) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Record"),
        content: const Text("Are you sure you want to delete this record?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete")),
        ],
      ),
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('breakdown_records');

    if (data == null) return;

    List list = jsonDecode(data);
    list.removeAt(originalIndex);

    await prefs.setString('breakdown_records', jsonEncode(list));

    setState(() {
      records.removeAt(originalIndex);
      applyFilter();
    });
  }

  /// ================= CREATE =================
  Future<void> goToCreate() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BreakdownRecordPage(),
      ),
    );

    loadRecords();
  }

  /// ================= EDIT =================
  Future<void> goToEdit(int originalIndex) async {
    final record = records[originalIndex];

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BreakdownRecordPage(
          breakdownRecord: record,
        ),
      ),
    );

    loadRecords();
  }

  /// ================= FORMAT DATE =================
  String formatDate(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')}/"
        "${d.month.toString().padLeft(2, '0')}/"
        "${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    final them = Theme.of(context);
    final isEmpty = !loading && filteredRecords.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Breakdown Records"),
      ),

      floatingActionButton: !isEmpty
          ? FloatingActionButton.extended(
        onPressed: goToCreate,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add New",
          style:
          TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: them.primaryColor,
      )
          : null,

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          /// ================= FILTER =================
          Padding(
            padding: const EdgeInsets.all(8),
            child: DropdownButtonFormField<String>(
              value: selectedMonth,
              decoration: const InputDecoration(
                labelText: "Filter by Month",
                border: OutlineInputBorder(),
              ),
              items: months
                  .map((m) => DropdownMenuItem(
                value: m,
                child: Text(m),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedMonth = value!;
                  applyFilter();
                });
              },
            ),
          ),

          /// ================= LIST =================
          Expanded(
            child: isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.description,
                      size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "No record found",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: goToCreate,
                    icon: const Icon(Icons.add),
                    label: const Text("Create New"),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: filteredRecords.length,
              itemBuilder: (context, index) {
                final record = filteredRecords[index];

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      record.customer.isNotEmpty
                          ? record.customer
                          : "No Customer",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold),
                    ),

                    subtitle: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text("Address: ${record.address}"),
                        Text("Fault: ${record.fault}"),
                        Text(
                            "Date: ${formatDate(record.createdAt)}"),
                      ],
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: Colors.blue),
                          onPressed: () {
                            final originalIndex =
                            records.indexOf(record);
                            goToEdit(originalIndex);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red),
                          onPressed: () {
                            final originalIndex =
                            records.indexOf(record);
                            deleteRecord(originalIndex);
                          },
                        ),
                      ],
                    ),

                    onTap: () {
                      final originalIndex =
                      records.indexOf(record);
                      goToEdit(originalIndex);
                    },
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