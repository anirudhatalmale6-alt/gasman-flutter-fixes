import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/payroll/payroll_run_view_screen.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';

import '../../../../services/payroll_service.dart';

class PayrollNewRunScreen extends StatefulWidget {
  final int? runId; // ✅ optional for edit

  const PayrollNewRunScreen({super.key, this.runId});

  @override
  State<PayrollNewRunScreen> createState() => _PayrollNewRunScreenState();
}

class _PayrollNewRunScreenState extends State<PayrollNewRunScreen> {
  final PayrollService _svc = PayrollService();

  bool loading = true;
  List<dynamic> employees = [];

  Map<String, dynamic>? runData;

  bool get isEdit => widget.runId != null;

  // ✅ Controllers
  final Map<int, TextEditingController> basic = {};
  final Map<int, TextEditingController> overtime = {};
  final Map<int, TextEditingController> bonus = {};
  final Map<int, TextEditingController> tax = {};
  final Map<int, TextEditingController> niEmployee = {};
  final Map<int, TextEditingController> niEmployer = {};
  final Map<int, TextEditingController> other = {};

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() => loading = true);
    try {
      employees = await _svc.listEmployees();

      // ✅ Create controllers
      for (final e in employees) {
        final id = e["id"] as int;

        basic[id] = TextEditingController();
        overtime[id] = TextEditingController();
        bonus[id] = TextEditingController();
        tax[id] = TextEditingController();
        niEmployee[id] = TextEditingController();
        niEmployer[id] = TextEditingController();
        other[id] = TextEditingController();
      }

      // ✅ EDIT MODE → fetch API
      if (isEdit) {
        runData = await _svc.getRun(widget.runId!);

        final lines = runData!["lines"] as List;

        for (final line in lines) {
          final empId = line["employee_id"];

          basic[empId]?.text = line["basic_pay"] ?? "0";
          overtime[empId]?.text = line["overtime"] ?? "0";
          bonus[empId]?.text = line["bonus"] ?? "0";
          tax[empId]?.text = line["tax"] ?? "0";
          niEmployee[empId]?.text = line["ni_employee"] ?? "0";
          niEmployer[empId]?.text = line["ni_employer"] ?? "0";
          other[empId]?.text = line["other_deductions"] ?? "0";
        }
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _saveRun() async {
    final today = DateTime.now();

    final periodStart =
        DateTime(today.year, today.month, 1).toIso8601String().substring(0, 10);

    final periodEnd = DateTime(today.year, today.month + 1, 0)
        .toIso8601String()
        .substring(0, 10);

    final payDate = today.toIso8601String().substring(0, 10);

    final lines = employees.map((e) {
      final id = e["id"] as int;

      return {
        "employeeId": id,
        "basicPay": double.tryParse(basic[id]!.text) ?? 0,
        "overtime": double.tryParse(overtime[id]!.text) ?? 0,
        "bonus": double.tryParse(bonus[id]!.text) ?? 0,
        "tax": double.tryParse(tax[id]!.text) ?? 0,
        "niEmployee": double.tryParse(niEmployee[id]!.text) ?? 0,
        "niEmployer": double.tryParse(niEmployer[id]!.text) ?? 0,
        "otherDeductions": double.tryParse(other[id]!.text) ?? 0,
      };
    }).toList();

    try {
      final body = {
        "runDate": payDate,
        "periodStart": periodStart,
        "periodEnd": periodEnd,
        "notes": runData?["payrollRun"]?["notes"] ?? "Payroll",
        "lines": lines,
      };

      final run = await _svc.createRun(body, id: widget.runId);

      if (!mounted) return;

      Navigator.pop(context);

      push(PayrollRunViewScreen(
        runId: run["id"] as int,
      ));

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Save failed: $e")),
      );
    }
  }

  // ✅ Field
  Widget payrollField({
    required TextEditingController controller,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget employeeCard(dynamic e) {
    final id = e["id"] as int;
    final fullName = "${e["first_name"] ?? ""} ${e["last_name"] ?? ""}".trim();

    final net = calculateNetPay(
      basic: basic[id]!,
      overtime: overtime[id]!,
      bonus: bonus[id]!,
      tax: tax[id]!,
      niEmployee: niEmployee[id]!,
      otherDeductions: other[id]!,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(
              height: 20.0,
            ),
            payrollField(controller: basic[id]!, label: "Basic"),
            payrollField(controller: overtime[id]!, label: "Overtime"),
            payrollField(controller: bonus[id]!, label: "Bonus"),
            payrollField(controller: tax[id]!, label: "Tax"),
            payrollField(controller: niEmployee[id]!, label: "NI Emp"),
            payrollField(controller: niEmployer[id]!, label: "NI Employer"),
            payrollField(controller: other[id]!, label: "Other"),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Net: £${net.toStringAsFixed(2)}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.green),
              ),
            )
          ],
        ),
      ),
    );
  }

  double calculateNetPay({
    required TextEditingController basic,
    required TextEditingController overtime,
    required TextEditingController bonus,
    required TextEditingController tax,
    required TextEditingController niEmployee,
    required TextEditingController otherDeductions,
  }) {
    final earnings = (double.tryParse(basic.text) ?? 0) +
        (double.tryParse(overtime.text) ?? 0) +
        (double.tryParse(bonus.text) ?? 0);

    final deductions = (double.tryParse(tax.text) ?? 0) +
        (double.tryParse(niEmployee.text) ?? 0) +
        (double.tryParse(otherDeductions.text) ?? 0);

    return earnings - deductions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Payroll" : "New Payroll"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: employees.length + 1,
              itemBuilder: (context, index) {
                if (index == employees.length) {
                  return FilledButton(
                    onPressed: _saveRun,
                    child: Text(isEdit ? "Update" : "Create"),
                  );
                }
                return employeeCard(employees[index]);
              },
            ),
    );
  }
}
