import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:the_gas_man_app/pages/finance/expense_form_page.dart';

import '../../../../services/payroll_service.dart';
import '../../../../utils_class/money.dart';
import '../../../../utils_class/pdf_print.dart';

class PayrollRunViewScreen extends StatefulWidget {
  final int runId;
  const PayrollRunViewScreen({super.key, required this.runId});

  @override
  State<PayrollRunViewScreen> createState() => _PayrollRunViewScreenState();
}

class _PayrollRunViewScreenState extends State<PayrollRunViewScreen> {
  final PayrollService _svc = PayrollService();
  bool loading = true;
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      data = await _svc.getRun(widget.runId);
    } catch (e) {

      print(" _svc.getRun(widget.runId) Error ${e}");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _post() async {
    try {
      await _svc.postRun(widget.runId);
      await _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payroll run posted to journals.")));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Post failed: $e")));
    }
  }

  Future<void> _openPayslip(int payslipId) async {
    final bytes = await _svc.downloadPayslipPdf(payslipId);
    await PdfPrint.previewAndPrint(bytes, filename: "payslip_$payslipId.pdf");
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (data == null) return const Scaffold(body: Center(child: Text("No data")));

    final run = Map<String, dynamic>.from(data!["payrollRun"]);
    final slips = (data!["lines"] as List?) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text("Payroll Run #${run["id"]}"),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          if ((run["status"]?.toString() ?? "") != "POSTED")
            IconButton(onPressed: _post, icon: const Icon(Icons.check_circle)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: Text("${formatDate(DateTime.parse(run["period_start"]))} → ${formatDate(DateTime.parse(run["period_end"]))}"),
              subtitle: Text("Pay date: ${formatDate(DateTime.parse(run["run_date"]))} • Status: ${run["status"]}"),
            ),
          ),
          const SizedBox(height: 12),
          const Text("Payslips", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...slips.map((p) {
            final net = double.parse(p["net_pay"]) ?? 0;
            return Card(
              child: ListTile(
                title: Text(p["full_name"]?.toString() ?? "Employee"),
                subtitle: Text("Net: ${formatMoney(net)}"),
                trailing: const Icon(Icons.picture_as_pdf),
                onTap: () => _openPayslip(p["id"] as int),
              ),
            );
          }),
        ],
      ),
    );
  }
}