import 'package:flutter/material.dart';
import '../../../../services/customer_service.dart';

class SupplierNewScreen extends StatefulWidget {
  final dynamic supplierDetails;

  const SupplierNewScreen({super.key, this.supplierDetails});

  @override
  State<SupplierNewScreen> createState() => _SupplierNewScreenState();
}

class _SupplierNewScreenState extends State<SupplierNewScreen> {
  final _svc = MasterDataService();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _vatNumber = TextEditingController();
  final _contactPerson = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.supplierDetails != null) {
      _setSupplierData(widget.supplierDetails);
    }
  }

  void _setSupplierData(Map<String, dynamic> s) {
    _name.text = s["name"] ?? "";
    _email.text = s["email"] ?? "";
    _phone.text = s["phone"] ?? "";
    _address.text = s["address"] ?? "";
    _vatNumber.text = s["vat_number"] ?? "";
    _contactPerson.text = s["contact_person"] ?? "";
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name is required")),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      await _svc.createSupplier(
        name: _name.text.trim(),
        email: _email.text,
        phone: _phone.text,
        address: _address.text,
        vatNumber: _vatNumber.text,
        contactPerson: _contactPerson.text,
        id: widget.supplierDetails?["id"],
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save supplier: $e")),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _field(
      String label,
      TextEditingController controller, {
        TextInputType? type,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.supplierDetails != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Update Supplier" : "New Supplier"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field("Name *", _name),
          _field("Email", _email, type: TextInputType.emailAddress),
          _field("Phone", _phone, type: TextInputType.phone),
          _field("Address", _address),
          _field("VAT Number", _vatNumber),
          _field("Contact Person", _contactPerson),

          const SizedBox(height: 20),

          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Text(isEdit ? "Update Supplier" : "Save Supplier"),
          ),
        ],
      ),
    );
  }
}