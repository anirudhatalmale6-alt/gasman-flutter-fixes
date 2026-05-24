import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the_gas_man_app/services/company_service.dart';

import '../../../theme/app_theme.dart';
import '../new_invoice_page/account_storage_file.dart';
import '../new_invoice_page/data_model/all_models.dart';

class CompanyInformationPage extends StatefulWidget {

  final bool? shouldShowAppBar;
  final String? appBarTitle;
  const CompanyInformationPage({super.key,required this.shouldShowAppBar,this.appBarTitle});

  @override
  State<CompanyInformationPage> createState() =>
      _CompanyInformationPageState();
}

class _CompanyInformationPageState
    extends State<CompanyInformationPage> {
  File? _logoFile;
  final ImagePicker _picker = ImagePicker();
  final AccountStorage _storage = AccountStorage();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _name = TextEditingController();

  final TextEditingController _engineerName = TextEditingController();

  final TextEditingController _address = TextEditingController();

  final TextEditingController _email = TextEditingController();

  final TextEditingController _phone = TextEditingController();

  final TextEditingController _vatNumber = TextEditingController();

  final TextEditingController _prefix = TextEditingController();

  final TextEditingController _gasSafeNumber = TextEditingController();

  final TextEditingController _postalCode = TextEditingController();

  final TextEditingController _paymentDetails = TextEditingController();

  bool _vatRegistered = true;
  bool _isLoading = true;

  double _uploadProgress = 0;
  bool _isUploading = false;

  var _companyService = CompanyService();

  String? _logoUrl;

  @override
  void initState() {
    super.initState();
    _getCompanyInfo();
    //_load();
  }

  Future<void> _load() async {
    await _storage.load();
    final s = _storage.settings;
    _name.text = s.businessName;
    _engineerName.text = s.engineerName;
    _address.text = s.businessAddress;
    _email.text = s.businessEmail;
    _phone.text = s.businessPhone;
    _vatNumber.text = s.vatNumber;
    _prefix.text = s.invoicePrefix;
    _postalCode.text = s.postalCode;
    _gasSafeNumber.text = s.gasSafeNumber;
    _paymentDetails.text = s.paymentDetails;
    _vatRegistered = s.vatRegistered;
    if (s.logoPath != null && s.logoPath!.isNotEmpty) {
      _logoFile = File(s.logoPath!);
    }

    _isLoading = false;
    setState(() {});
  }

  Future<void> _getCompanyInfo() async {
    try {
      final data = await _companyService.getCompany();

      _name.text = data["business_name"] ?? "";
      _engineerName.text = data["name"] ?? "";
      _address.text = data["address"] ?? "";
      _phone.text = data["phone"] ?? "";
      _email.text = data["email"] ?? "";
      _vatNumber.text = data["vrn"] ?? "";
      _prefix.text = data["invoice_prefix"] ?? "INV";
      _postalCode.text = data["postal_code"] ?? "";
      _gasSafeNumber.text = data["gas_safe_number"] ?? "";
      _paymentDetails.text = data["payment_details"] ?? "";

      _vatRegistered = data["vrn"] != null && data["vrn"].toString().isNotEmpty;

      if (data["logo_url"] != null && data["logo_url"].toString().isNotEmpty) {
        _logoUrl = "https://api.gasmanbusiness.co.uk${data["logo_url"]}";
        _logoFile = await _companyService.urlToFile(_logoUrl!);
      }

      _isLoading = false;

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      _isLoading = false;

      if (mounted) {
        setState(() {});
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }



  @override
  void dispose() {
    _name.dispose();
    _engineerName.dispose();
    _address.dispose();
    _email.dispose();
    _phone.dispose();
    _vatNumber.dispose();
    _prefix.dispose();
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
      businessAddress: _address.text.trim(),
      engineerName: _engineerName.text.trim(),
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
      gasSafeNumber: _gasSafeNumber.text,
      postalCode: _postalCode.text,
      paymentDetails: _paymentDetails.text,
    );

    await _storage.saveSettings();
    saveCompanyInfo();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.shouldShowAppBar! ? AppBar(
        title:  Text(widget.appBarTitle ?? "Engineer/Company Settings"),
      ) : null,
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
                      controller: _engineerName,
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
                      validator: (v) => v == null || v.trim().isEmpty
                          ? "Payment Details"
                          : null,
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
                    TextFormField(
                      controller: _gasSafeNumber,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? "Gas Safe Number required"
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Gas Safe Number',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _postalCode,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? "Postalcode  required"
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Postal Code',
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

  void saveCompanyInfo() async {
    try {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0;
      });

      /// SHOW DIALOG
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                title: const Text("Uploading"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinearProgressIndicator(
                      value: _uploadProgress,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "${(_uploadProgress * 100).toStringAsFixed(0)}%",
                    ),
                  ],
                ),
              );
            },
          );
        },
      );

      await _companyService.updateCompany(
        name: _engineerName.text.trim(),
        businessName: _name.text.trim(),
        address: _address.text.trim(),
        phone: _phone.text.trim(),
        email: _email.text.trim(),
        vrn: _vatNumber.text.trim(),
        paymentDetails: _paymentDetails.text.trim(),
        gasSafeNumber: _gasSafeNumber.text.trim(),
        postalCode: _postalCode.text.trim(),
        invoicePrefix: _prefix.text.trim(),
        logoFile: _logoFile,
        onProgress: (sent, total) {
          if (mounted) {
            setState(() {
              _uploadProgress = sent / total;
            });
          }
        },
      );

      /// CLOSE DIALOG
      if (mounted) {
        Navigator.pop(context);
      }

      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Company updated successfully"),
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
      }

      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }
}
