import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as api;
import 'package:intl/intl.dart';
import 'package:the_gas_man_app/pages/new_invoice_page/account_storage_file.dart';
import 'package:the_gas_man_app/pages/new_invoice_page/data_model/all_models.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/vat_return/vat_history_screen.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/vat_return/vat_obligation_list.dart';
import 'package:the_gas_man_app/services/vat_return_service.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';

class VatReturnScreen extends StatefulWidget {
  final Obligation? onligation;

  const VatReturnScreen({super.key, this.onligation});

  @override
  State<VatReturnScreen> createState() => _VatReturnScreenState();
}

class _VatReturnScreenState extends State<VatReturnScreen> {
  Map<String, dynamic>? vatRetutnData = {};
  Map<String, dynamic>? vatSummaryData = {};
  Map<String, dynamic>? vatLockData = {};
  bool loading = true;
  bool submitting = false;
  VatReturnService _svc = VatReturnService();
  bool? isConditionAccpeted = false;
  DateTime dateFrom = DateTime(DateTime.now().year, DateTime.now().month - 3, 1);
  DateTime dateTo = DateTime(DateTime.now().year, DateTime.now().month, 0);

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      setState(() => loading = true);

      final results = await Future.wait([
        _svc.getVatReturn(  dateFrom: DateFormat("yyyy-MM-dd").format(dateFrom),
          dateTo: DateFormat("yyyy-MM-dd").format(dateTo),),
        _svc.getVatLoacks(),
        _svc.getSummary(),
      ]);

      vatRetutnData = results[0]!['boxes'];
      vatLockData = results[1];
      vatSummaryData = results[2];
    } catch (e) {
      // Optional: handle error (log / show snackbar)
      print('Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> submit() async {
    // debugger();
    if (vatLockData!['locks'] != null && vatLockData!['locks'] is List) {
      List<dynamic> vatLocksList = vatLockData!['locks'];
      dynamic vatLockFirst = vatLocksList.first;
      if (vatLockFirst['locked'] != null && vatLockFirst['locked']) {
        showError("Vat period is locked so it cant be edited");
        return;
      }
    }
    setState(() => submitting = true);
    AccountingSettings? settings = AccountStorage().settings;

    try {
      final res = await _svc.submitVat(
        vrn: settings.vatNumber.toString(),
        vatData: {
          "periodKey": widget.onligation!.periodKey,
          "vatDueSales": double.parse(vatRetutnData!['box1'].toString())
              .toStringAsFixed(0),
          "vatDueAcquisitions": double.parse(vatRetutnData!['box2'].toString())
              .toStringAsFixed(0),
          "totalVatDue": double.parse(vatRetutnData!['box3'].toString())
              .toStringAsFixed(0),
          "vatReclaimedCurrPeriod":
              double.parse(vatRetutnData!['box4'].toString())
                  .toStringAsFixed(0),
          "netVatDue": double.parse(vatRetutnData!['box5'].toString())
              .toStringAsFixed(0),
          "totalValueSalesExVAT":
              double.parse(vatRetutnData!['box6'].toString())
                  .toStringAsFixed(0),
          "totalValuePurchasesExVAT":
              double.parse(vatRetutnData!['box7'].toString())
                  .toStringAsFixed(0),
          "totalValueGoodsSuppliedExVAT":
              double.parse(vatRetutnData!['box8'].toString())
                  .toStringAsFixed(0),
          "totalAcquisitionsExVAT":
              double.parse(vatRetutnData!['box9'].toString())
                  .toStringAsFixed(0),
          "finalised": true
        }
      );

      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("Success"),
          content: Text("VAT submitted to HMRC"),
        ),
      );
    } catch (e) {
      showError(e.toString());
    }

    setState(() => submitting = false);
  }

  void showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Submission Error"),
        content: Text(msg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("VAT Return"),actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: load,
        ),
      ],),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("Period: ${vatSummaryData!["periodKey"]}"),
          ListTile(
            title: const Text("VAT on Sales"),
            trailing: Text("£${vatSummaryData!["vatCollected"]}"),
          ),
          ListTile(
            title: const Text("VAT on Purchases"),
            trailing: Text("£${vatSummaryData!["vatPaid"]}"),
          ),
          ListTile(
            title: const Text("VAT Owed"),
            trailing: Text("£${vatSummaryData!["vatOwed"]}"),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: isConditionAccpeted,
                onChanged: (value) {
                  setState(() {
                    isConditionAccpeted = value ?? false;
                  });
                },
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text:
                              'When you submit this VAT information you are making a legal declaration that the information is true and complete. ',
                        ),
                        TextSpan(
                          text:
                              'A false declaration can result in prosecution.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: (submitting || !isConditionAccpeted!) ? null : submit,
            child: submitting
                ? const CircularProgressIndicator()
                : const Text("Submit to HMRC"),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              push(VatHistoryScreen());
            },
            child: submitting
                ? const CircularProgressIndicator()
                : const Text("View History"),
          )
        ],
      ),
    );
  }
}
