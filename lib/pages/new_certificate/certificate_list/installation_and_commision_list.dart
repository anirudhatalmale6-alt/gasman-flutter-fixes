import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../installation_and_commision/installation_and_comissioning_page.dart';

class InstallationCommissionRecordListScreen extends StatefulWidget {
  const InstallationCommissionRecordListScreen({super.key});

  @override
  State<InstallationCommissionRecordListScreen> createState() =>
      _InstallationCommissionRecordListScreenState();
}

class _InstallationCommissionRecordListScreenState
    extends State<InstallationCommissionRecordListScreen> {
  List<InstallationCommissioningRecord> records = [];
  List<InstallationCommissioningRecord> filteredRecords = [];

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
    final prefs = await SharedPreferences.getInstance();
    final String? data =
    prefs.getString('latest_install_commission_record');

    if (data != null) {
      final decoded = jsonDecode(data);

      if (decoded is List) {
        records = decoded
            .map((e) => InstallationCommissioningRecord.fromJson(e))
            .toList();
      } else {
        records = [InstallationCommissioningRecord.fromJson(decoded)];
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

        /// ✅ Try ISO format
        try {
          date = DateTime.parse(record.installDate);
        } catch (_) {
          /// ✅ fallback dd/MM/yyyy
          final parts = record.installDate.split('/');
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
    final prefs = await SharedPreferences.getInstance();

    records.removeAt(originalIndex);

    await prefs.setString(
      'latest_install_commission_record',
      jsonEncode(records.map((e) => e.toJson()).toList()),
    );

    setState(() {
      applyFilter();
    });
  }

  /// ================= NAVIGATION =================
  void goToCreate() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const InstallationCommissioningPage(),
      ),
    );

    loadRecords();
  }

  void goToEdit(int originalIndex) async {
    final record = records[originalIndex];

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InstallationCommissioningPage(record: record),
      ),
    );

    loadRecords();
  }

  /// ================= FORMAT DATE =================
  String formatDate(String date) {
    try {
      final d = DateTime.parse(date);
      return "${d.day.toString().padLeft(2, '0')}/"
          "${d.month.toString().padLeft(2, '0')}/"
          "${d.year}";
    } catch (_) {
      return date;
    }
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    final them = Theme.of(context);
    final isEmpty = !loading && filteredRecords.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Installation & Commissioning"),
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
                    title: Text(record.customerName),
                    subtitle: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Certificate: ${record.certificateNumber}"),
                        Text(
                            "Property: ${record.propertyAddress}"),
                        Text(
                            "Date: ${formatDate(record.installDate)}"),
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