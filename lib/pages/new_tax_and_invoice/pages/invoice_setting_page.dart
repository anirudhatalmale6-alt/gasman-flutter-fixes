import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../theme/app_theme.dart';
import '../../new_invoice_page/account_storage_file.dart';
import '../../new_invoice_page/data_model/all_models.dart';

class InvoiceSettingPage extends StatefulWidget {
  const InvoiceSettingPage({super.key});

  @override
  State<InvoiceSettingPage> createState() => _InvoiceSettingPageState();
}

class _InvoiceSettingPageState extends State<InvoiceSettingPage> {
  File? _logoFile;
  final ImagePicker _picker = ImagePicker();
  final AccountStorage _storage = AccountStorage();

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _name;
  late TextEditingController _enginerrName;
  late TextEditingController _address;
  late TextEditingController _email;
  late TextEditingController _phone;
  late TextEditingController _vatNumber;
  late TextEditingController _prefix;
  late TextEditingController _paymentDetails;

  bool _vatRegistered = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _storage.load();
    final s = _storage.settings;

    _name = TextEditingController(text: s.businessName);
    _enginerrName = TextEditingController(text: s.engineerName);
    _address = TextEditingController(text: s.businessAddress);
    _email = TextEditingController(text: s.businessEmail);
    _phone = TextEditingController(text: s.businessPhone);
    _vatNumber = TextEditingController(text: s.vatNumber);
    _prefix = TextEditingController(text: s.invoicePrefix);
    _paymentDetails = TextEditingController(text: s.paymentDetails);
    _vatRegistered = s.vatRegistered;

    if (s.logoPath != null && s.logoPath!.isNotEmpty) {
      _logoFile = File(s.logoPath!);
    }

    _isLoading = false;
    setState(() {});
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
    if (!_formKey.currentState!.validate()) return;

    if (_logoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a logo")),
      );
      return;
    }

    final old = _storage.settings;

    _storage.settings = AccountingSettings(
        businessName: _name.text.trim(),
        engineerName: _enginerrName.text.trim(),
        businessAddress: _address.text.trim(),
        businessEmail: _email.text.trim(),
        businessPhone: _phone.text.trim(),
        vatRegistered: _vatRegistered,
        vatNumber: _vatNumber.text.trim(),
        invoicePrefix: _prefix.text.trim(),
        nextInvoiceNumber: old.nextInvoiceNumber,
        nextApiInvoiceNumber: old.nextApiInvoiceNumber,
        nextEstimateNumber: old.nextEstimateNumber,
        nextApiBillNumber: old.nextApiBillNumber,
        logoPath: _logoFile!.path,
        gasSafeNumber: old.gasSafeNumber,
        postalCode: old.postalCode,
        paymentDetails: old.paymentDetails);

    await _storage.saveSettings();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Business settings"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: AppColors.kLightBg,
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    /// Logo
                    Center(
                      child: GestureDetector(
                        onTap: _showLogoPicker,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage:
                              _logoFile != null ? FileImage(_logoFile!) : null,
                          child: _logoFile == null
                              ? const Icon(Icons.photo,
                                  size: 30, color: Colors.grey)
                              : null,
                        ),
                      ),
                    ),
                    if (_logoFile == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          "Logo is required",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),

                    const SizedBox(height: 12),

                    /// Name
                    TextFormField(
                      controller: _name,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? "Business name is required"
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Business name',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// Name
                    TextFormField(
                      controller: _enginerrName,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? "Engineer name is required"
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Engineer name',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// Address
                    TextFormField(
                      controller: _address,
                      maxLines: 2,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? "Address is required"
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Business address',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// Phone
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Phone is required";
                        }
                        if (v.length < 10) {
                          return "Enter valid phone";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Business phone',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// Email
                    TextFormField(
                      controller: _email,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Email is required";
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                          return "Enter valid email";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Business email',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),

                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _paymentDetails,
                      maxLines: 3,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Payment details is required";
                        }

                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Payment Details',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// VAT Toggle
                    SwitchListTile(
                      title: const Text('VAT registered'),
                      value: _vatRegistered,
                      onChanged: (v) => setState(() => _vatRegistered = v),
                    ),

                    if (_vatRegistered) ...[
                      TextFormField(
                        controller: _vatNumber,
                        validator: (v) {
                          if (_vatRegistered &&
                              (v == null || v.trim().isEmpty)) {
                            return "VAT number is required";
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'VAT number',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    /// Prefix
                    TextFormField(
                      controller: _prefix,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? "Prefix is required"
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Invoice number prefix (e.g. INV)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// Save Button
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
