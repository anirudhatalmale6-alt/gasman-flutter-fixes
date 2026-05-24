import 'package:flutter/material.dart';
import '../../../../services/customer_service.dart';

class BankAccountNewScreen extends StatefulWidget {
  const BankAccountNewScreen({super.key});

  @override
  State<BankAccountNewScreen> createState() =>
      _BankAccountNewScreenState();
}

class _BankAccountNewScreenState extends State<BankAccountNewScreen> {
  final _svc = MasterDataService();

  final _accountName = TextEditingController();
  final _bankName = TextEditingController();
  final _accountNumber = TextEditingController();
  final _sortCode = TextEditingController();
  final _iban = TextEditingController();
  final _swiftBic = TextEditingController();
  final _openingBalance = TextEditingController(text: "0");

  bool _isDefault = false;
  bool _saving = false;

  Future<void> _save() async {
    if (_accountName.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account name is required")),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      await _svc.createBankAccount(
        accountName: _accountName.text.trim(),
        bankName: _bankName.text,
        accountNumber: _accountNumber.text,
        sortCode: _sortCode.text,
        iban: _iban.text,
        swiftBic: _swiftBic.text,
        openingBalance: double.tryParse(_openingBalance.text) ?? 0,
        isDefault: _isDefault,
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save bank account: $e")),
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
    _accountName.dispose();
    _bankName.dispose();
    _accountNumber.dispose();
    _sortCode.dispose();
    _iban.dispose();
    _swiftBic.dispose();
    _openingBalance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Bank Account"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field("Account Name *", _accountName),
          _field("Bank Name", _bankName),
          _field("Account Number", _accountNumber,
              type: TextInputType.number),
          _field("Sort Code", _sortCode),
          _field("IBAN", _iban),
          _field("SWIFT / BIC", _swiftBic),
          _field("Opening Balance", _openingBalance,
              type: TextInputType.number),

          const SizedBox(height: 10),

          Card(
            elevation: 1,
            child: SwitchListTile(
              value: _isDefault,
              onChanged: (v) => setState(() => _isDefault = v),
              title: const Text("Set as Default Account"),
            ),
          ),

          const SizedBox(height: 20),

          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text("Save Bank Account"),
          ),
        ],
      ),
    );
  }
}