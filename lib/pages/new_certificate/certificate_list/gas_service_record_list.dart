import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../gas_service_record/new_service_record_page.dart';

class GasServiceRecordsListScreen extends StatefulWidget {
  const GasServiceRecordsListScreen({super.key});

  @override
  State<GasServiceRecordsListScreen> createState() =>
      _GasServiceRecordsListScreenState();
}

class _GasServiceRecordsListScreenState
    extends State<GasServiceRecordsListScreen> {
  List<ServiceRecord> records = [];
  List<ServiceRecord> filteredRecords = [];

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
    final String? data = prefs.getString('latest_service_record');

    if (data != null) {
      final decoded = jsonDecode(data);

      if (decoded is List) {
        records = decoded.map((e) => ServiceRecord.fromJson(e)).toList();
      } else {
        records = [ServiceRecord.fromJson(decoded)];
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
        DateTime date;

        /// ✅ Try ISO format first
        try {
          date = DateTime.parse(record.serviceDate);
        } catch (_) {
          /// ✅ fallback dd/MM/yyyy
          final parts = record.serviceDate.split('/');
          date = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }

        return date.month == selectedMonthIndex;
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
    final String? data = prefs.getString('latest_service_record');

    if (data == null) return;

    List list = jsonDecode(data);
    list.removeAt(originalIndex);

    await prefs.setString('latest_service_record', jsonEncode(list));

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
        builder: (_) => const NewServiceRecordPage(),
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
        builder: (_) => NewServiceRecordPage(
          record: record,
        ),
      ),
    );

    loadRecords();
  }

  /// ================= FORMAT DATE =================
  String formatDate(String date) {
    if (date.isEmpty) return "";
    try {
      final d = DateTime.parse(date);
      return "${d.day.toString().padLeft(2, '0')}/"
          "${d.month.toString().padLeft(2, '0')}/"
          "${d.year}";
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final them = Theme.of(context);
    final isEmpty = !loading && filteredRecords.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gas Service Records"),
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
                      record.recordNumber.isNotEmpty
                          ? record.recordNumber
                          : "No Record Number",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold),
                    ),

                    subtitle: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text("Customer: ${record.customerName}"),
                        Text("Property: ${record.propertyAddress}"),
                        Text(
                            "Service Date: ${formatDate(record.serviceDate)}"),
                        Text(
                            "Appliances: ${record.appliances.length}"),
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