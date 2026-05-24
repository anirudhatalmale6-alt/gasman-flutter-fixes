import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../theme/app_theme.dart';
import '../account_storage_file.dart';
import '../data_model/all_models.dart';

class SettingsTab extends StatefulWidget {
  final AccountStorage storage;
  final VoidCallback onChanged;

  const SettingsTab({
    super.key,
    required this.storage,
    required this.onChanged,
  });

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  File? _logoFile;
  final ImagePicker _picker = ImagePicker();
  late TextEditingController _name;
  late TextEditingController _enginerrName;
  late TextEditingController _address;
  late TextEditingController _email;
  late TextEditingController _phone;
  late TextEditingController _vatNumber;
  late TextEditingController _prefix;
  late TextEditingController _gasSafeController;
  late TextEditingController _postalCodeController;
  late TextEditingController _paymentDetails;
  bool _vatRegistered = true;

  @override
  void initState() {
    super.initState();
    final s = widget.storage.settings;
    _name = TextEditingController(text: s.businessName);
    _enginerrName = TextEditingController(text: s.engineerName);
    _address = TextEditingController(text: s.businessAddress);
    _email = TextEditingController(text: s.businessEmail);
    _phone = TextEditingController(text: s.businessPhone);
    _vatNumber = TextEditingController(text: s.vatNumber);
    _prefix = TextEditingController(text: s.invoicePrefix);
    _postalCodeController = TextEditingController(text: s.postalCode);
    _gasSafeController = TextEditingController(text: s.gasSafeNumber);
    _paymentDetails = TextEditingController(text: s.paymentDetails);
    _vatRegistered = s.vatRegistered;
    if (s.logoPath != null && s.logoPath!.isNotEmpty) {
      _logoFile = File(s.logoPath!);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _email.dispose();
    _phone.dispose();
    _vatNumber.dispose();
    _prefix.dispose();
    _paymentDetails.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final old = widget.storage.settings;
    widget.storage.settings = AccountingSettings(
        businessName: _name.text.trim(),
        engineerName: _enginerrName.text,
        businessAddress: _address.text.trim(),
        businessEmail: _email.text.trim(),
        businessPhone: _phone.text.trim(),
        vatRegistered: _vatRegistered,
        vatNumber: _vatNumber.text.trim(),
        invoicePrefix: _prefix.text.trim().isEmpty
            ? old.invoicePrefix
            : _prefix.text.trim(),
        nextInvoiceNumber: old.nextInvoiceNumber,
        nextApiInvoiceNumber: old.nextApiInvoiceNumber,
        nextApiBillNumber: old.nextApiBillNumber,
        nextEstimateNumber: old.nextEstimateNumber,
        logoPath: _logoFile != null ? _logoFile!.path : "",
        gasSafeNumber: _gasSafeController.text,
        postalCode: _postalCodeController.text,
       paymentDetails: _paymentDetails.text

    );
    await widget.storage.saveSettings();
    widget.onChanged();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: AppColors.kLightBg,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Center(
              child: GestureDetector(
                onTap: _showLogoPicker,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                      _logoFile != null ? FileImage(_logoFile!) : null,
                  child: _logoFile == null
                      ? Icon(Icons.photo, size: 30, color: Colors.grey)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Business name',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _enginerrName,
              decoration: const InputDecoration(
                labelText: 'Engineer name',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _address,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Business address',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phone,
              decoration: const InputDecoration(
                labelText: 'Business phone',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _email,
              decoration: const InputDecoration(
                labelText: 'Business email',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _paymentDetails,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Payment Details',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('VAT registered'),
              value: _vatRegistered,
              onChanged: (v) => setState(() => _vatRegistered = v),
            ),
            if (_vatRegistered) ...[
              const SizedBox(height: 4),
              TextField(
                controller: _vatNumber,
                decoration: const InputDecoration(
                  labelText: 'VAT number',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],
            const SizedBox(height: 8),
            TextField(
              controller: _gasSafeController,
              decoration: const InputDecoration(
                labelText: 'Gas Safe Number',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _prefix,
              decoration: const InputDecoration(
                labelText: 'Invoice number prefix (e.g. INV)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _postalCodeController,
              decoration: const InputDecoration(
                labelText: 'PostalCode',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: _save,
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoPicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickLogo(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickLogo(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickLogo(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 70);

    if (picked != null) {
      setState(() {
        _logoFile = File(picked.path);
      });
    }
  }
}
