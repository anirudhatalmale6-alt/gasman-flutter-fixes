import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../landloard_gst_safety_page/landloard_gas_safety_page.dart';

class LandlordRecordsListScreen extends StatefulWidget {
  const LandlordRecordsListScreen({super.key});

  @override
  State<LandlordRecordsListScreen> createState() =>
      _LandlordRecordsListScreenState();
}

class _LandlordRecordsListScreenState extends State<LandlordRecordsListScreen> {
  List<LandlordGasSafetyRecord> records = [];
  List<LandlordGasSafetyRecord> filteredRecords = [];

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

  Future<void> loadRecords() async {
    setState(() => loading = true);

    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('latest_lgs_record');

    if (data != null) {
      final List decoded = jsonDecode(data);
      records =
          decoded.map((e) => LandlordGasSafetyRecord.fromJson(e)).toList();
    } else {
      records = [];
    }

    applyFilter();

    setState(() => loading = false);
  }

  /// ================= FILTER =================
  void applyFilter() {
    if (selectedMonth == "All") {
      filteredRecords = records;
      return;
    }

    final formatter = DateFormat("dd/MM/yyyy"); // 👈 match your format

    filteredRecords = records.where((record) {
      try {
        final date = formatter.parse(record.inspectionDate);
        final monthName = months[date.month];
        return monthName == selectedMonth;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  /// ================= DELETE =================
  Future<void> deleteRecord(int index) async {
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
    final String? data = prefs.getString('latest_lgs_record');

    if (data == null) return;

    List list = jsonDecode(data);
    list.removeAt(index);

    await prefs.setString('latest_lgs_record', jsonEncode(list));

    setState(() {
      records.removeAt(index);
      applyFilter();
    });
  }

  /// ================= CREATE =================
  Future<void> _goToCreate() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LandlordGasSafetyPage(),
      ),
    );

    loadRecords();
  }

  /// ================= EDIT =================
  Future<void> _goToEdit(int index) async {
    final record = filteredRecords[index];

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LandlordGasSafetyPage(
          record: record,
        ),
      ),
    );

    loadRecords();
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = !loading && filteredRecords.isEmpty;
    final them = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Records"),
      ),

      floatingActionButton: !isEmpty
          ? FloatingActionButton.extended(
        onPressed: _goToCreate,
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
          /// ================= FILTER UI =================
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

          /// ================= LIST / EMPTY =================
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
                    "No certificates found",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _goToCreate,
                    icon: const Icon(Icons.add),
                    label: const Text("Create Certificate"),
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
                    onTap: (){
                      _goToEdit(index);
                    },
                    title: Text(record.landlordName),
                    subtitle: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Property: ${record.propertyAddress}"),
                        Text("Date: ${record.inspectionDate}"),
                        Text(
                            "Certificate: ${record.certificateNumber}"),
                      ],
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: Colors.blue),
                          onPressed: () => _goToEdit(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red),
                          onPressed: () => deleteRecord(index),
                        ),
                      ],
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