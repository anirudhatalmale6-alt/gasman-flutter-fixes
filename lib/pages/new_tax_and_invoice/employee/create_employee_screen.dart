import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../services/employee_service.dart';


class EmployeeNewScreen extends StatefulWidget {
  final dynamic employeeDetails;

  const EmployeeNewScreen({super.key, this.employeeDetails});

  @override
  State<EmployeeNewScreen> createState() => _EmployeeNewScreenState();
}

class _EmployeeNewScreenState extends State<EmployeeNewScreen> {
  final _svc = EmployeeService();

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _jobTitle = TextEditingController();
  final _department = TextEditingController();
  final _salary = TextEditingController();
  final _startDate = TextEditingController();
  final _niNumber = TextEditingController();
  final _taxCode = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.employeeDetails != null) {
      setEmployeeData(widget.employeeDetails);
    }
  }

  void setEmployeeData(Map<String, dynamic> e) {
    _firstName.text = e["first_name"] ?? "";
    _lastName.text = e["last_name"] ?? "";
    _email.text = e["email"] ?? "";
    _phone.text = e["phone"] ?? "";
    _jobTitle.text = e["job_title"] ?? "";
    _department.text = e["department"] ?? "";
    _salary.text = e["salary"]?.toString() ?? "";
    _startDate.text = DateFormat("dd-MM-yyyy").format(DateTime.parse(e["start_date"])) ?? "";
    _niNumber.text = e["ni_number"] ?? "";
    _taxCode.text = e["tax_code"] ?? "";
  }

  Future<void> _save() async {
    if (_firstName.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("First Name is required")),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      await _svc.createEmployee(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        email: _email.text,
        phone: _phone.text,
        jobTitle: _jobTitle.text,
        department: _department.text,
        salary: double.tryParse(_salary.text) ?? 0,
        startDate: _startDate.text,
        niNumber: _niNumber.text,
        taxCode: _taxCode.text,
        id: widget.employeeDetails?["id"],
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _field(String label, TextEditingController controller,
      {TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _jobTitle.dispose();
    _department.dispose();
    _salary.dispose();
    _startDate.dispose();
    _niNumber.dispose();
    _taxCode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.employeeDetails != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Update Employee" : "New Employee"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field("First Name *", _firstName),
          _field("Last Name", _lastName),
          _field("Email", _email, type: TextInputType.emailAddress),
          _field("Phone", _phone, type: TextInputType.phone),
          _field("Job Title", _jobTitle),
          _field("Department", _department),
          _field("Salary", _salary, type: TextInputType.number),
          _field("Start Date (YYYY-MM-DD)", _startDate),
          _field("NI Number", _niNumber),
          _field("Tax Code", _taxCode),

          const SizedBox(height: 20),

          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Text(isEdit ? "Update Employee" : "Save Employee"),
          ),
        ],
      ),
    );
  }
}