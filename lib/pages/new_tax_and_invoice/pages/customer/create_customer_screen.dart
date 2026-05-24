import 'package:flutter/material.dart';
import '../../../../services/customer_service.dart';

class CustomerNewScreen extends StatefulWidget {
  final dynamic customerDetails;

  const CustomerNewScreen({super.key, this.customerDetails});

  @override
  State<CustomerNewScreen> createState() => _CustomerNewScreenState();
}

class _CustomerNewScreenState extends State<CustomerNewScreen> {
  final _svc = MasterDataService();

  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _vatNumber = TextEditingController();
  final _contactPerson = TextEditingController();

  bool _saving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await _svc.createCustomer(
        name: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        address: _address.text.trim(),
        vatNumber: _vatNumber.text.trim(),
        contactPerson: _contactPerson.text.trim(),
        id: widget.customerDetails != null
            ? widget.customerDetails['id']
            : null,
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save customer: $e")),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.customerDetails != null) {
      setCustomerData(widget.customerDetails);
    }
  }

  void setCustomerData(Map<String, dynamic> c) {
    _name.text = c["name"]?.toString() ?? "";
    _email.text = c["email"]?.toString() ?? "";
    _phone.text = c["phone"]?.toString() ?? "";
    _address.text = c["address"]?.toString() ?? "";
    _vatNumber.text = c["vat_number"]?.toString() ?? "";
    _contactPerson.text = c["contact_person"]?.toString() ?? "";
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    _vatNumber.dispose();
    _contactPerson.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customerDetails != null
            ? "Update Customer"
            : "New Customer"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: _dec("Name *"),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return "Name is required";
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _email,
              decoration: _dec("Email"),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v != null && v.isNotEmpty) {
                  final emailRegex =
                  RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
                  if (!emailRegex.hasMatch(v)) {
                    return "Enter valid email";
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _phone,
              decoration: _dec("Phone"),
              keyboardType: TextInputType.phone,
              validator: (v) {
                if (v != null && v.isNotEmpty && v.length < 7) {
                  return "Enter valid phone number";
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _address,
              decoration: _dec("Address"),
              maxLines: 2,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _vatNumber,
              decoration: _dec("VAT Number"),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _contactPerson,
              decoration: _dec("Contact Person"),
            ),
            const SizedBox(height: 24),

            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : Text(widget.customerDetails != null
                  ? "Update Customer"
                  : "Save Customer"),
            ),
          ],
        ),
      ),
    );
  }
}
