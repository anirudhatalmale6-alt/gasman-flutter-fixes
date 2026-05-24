import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:signature/signature.dart';
import 'package:the_gas_man_app/models/company_settings.dart';
import 'package:the_gas_man_app/pages/new_invoice_page/account_storage_file.dart';
import 'package:the_gas_man_app/pages/new_invoice_page/data_model/all_models.dart';
import 'package:the_gas_man_app/pages/new_invoice_page/pages/customers_page.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/customer/customer_list_screen.dart';
import 'package:the_gas_man_app/theme/app_theme.dart';

import '../../../utils_class/app_pdf_documents.dart';
import '../../../utils_class/utils.dart';
import '../common_ui/company_logo.dart';

class LandlordGasSafetyPage extends StatefulWidget {
  final LandlordGasSafetyRecord? record;

  const LandlordGasSafetyPage({super.key, this.record});

  @override
  State<LandlordGasSafetyPage> createState() => _LandlordGasSafetyPageState();
}

class _LandlordGasSafetyPageState extends State<LandlordGasSafetyPage> {
  // Colours to roughly match your app theme
  static const Color _teal = Color(0xFF4F7F7F);
  static const Color _cardBg = Color(0xFFF3F7F7);

  final _formKey = GlobalKey<FormState>();

  // Certificate info
  final _certificateNumberController = TextEditingController(text: 'LGS-00001');

  // Landlord details
  final _landlordNameController = TextEditingController();
  final _landlordAddressController = TextEditingController();
  final _landlordPostcodeController = TextEditingController();
  final _landlordPhoneController = TextEditingController();
  final _landlordEmailController = TextEditingController();

  // Property details
  final _tenantNameController = TextEditingController();
  final _propertyAddressController = TextEditingController();
  final _propertyPostcodeController = TextEditingController();

  // Appliances – dynamic list
  final List<ApplianceData> _appliances = [ApplianceData.empty(1)];

  //final List<ApplianceData> _appliances = [];

  // Appliance checks (global for this cert – same as your UI)
  bool ventilationAdequate = true;
  bool flueChimneySatisfactory = true;
  bool safetyDevicesOk = true;
  bool combustionReadingsSatisfactory = true;
  bool applianceSafeToUse = true;

  // Flue / chimney checks
  bool flueConditionSatisfactory = true;
  bool terminationSatisfactory = true;
  final _flueNotesController = TextEditingController();

  // Gas installation pipework
  bool visualConditionSatisfactory = true;
  bool pipeworkSecure = true;
  bool earthBonding = true;
  bool tightnessTestCarriedOut = true;
  final _standingPressureController = TextEditingController();
  final _workingPressureController = TextEditingController();
  final _letByResultController = TextEditingController();
  final _tightnessDropController = TextEditingController();

  // Defects / unsafe situations
  String classification = 'None'; // None, ID, AR, NCS
  final _defectDetailsController = TextEditingController();
  final _actionTakenController = TextEditingController();
  final _adviceGivenController = TextEditingController();

  // Inspection dates (store as text)
  final _inspectionDateController = TextEditingController();
  final _nextInspectionDueController = TextEditingController();
  final _reminderDateController = TextEditingController();

  // Engineer / company
  final _engineerNameController = TextEditingController();
  final _gasSafeNumberController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyAddressController = TextEditingController();
  final _companyPostcodeController = TextEditingController();
  final _companyPhoneController = TextEditingController();
  final _companyEmailController = TextEditingController();

  // Signatures (stored as bytes in memory, base64 in record)
  Uint8List? _engineerSignatureBytes;
  Uint8List? _landlordSignatureBytes;

  bool _saving = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      setCompanyDetails();
      if (widget.record != null) {
        _setDataToForm(widget.record!);
      } else {
        getNextCertificateNumber();
      }
    });
  }

  void setCompanyDetails() async {
    AccountingSettings companySettings = AccountStorage().settings;
    if (companySettings != null) {
      _engineerNameController.text = companySettings.engineerName;
      _companyNameController.text = companySettings.businessName;
      _companyAddressController.text = companySettings.businessAddress;
      _gasSafeNumberController.text = companySettings.gasSafeNumber;
      _companyPhoneController.text = companySettings.businessPhone;
      _companyEmailController.text = companySettings.businessEmail;
      _companyPostcodeController.text = companySettings.postalCode;
    }
  }

  @override
  void dispose() {
    _certificateNumberController.dispose();
    _landlordNameController.dispose();
    _landlordAddressController.dispose();
    _landlordPostcodeController.dispose();
    _landlordPhoneController.dispose();
    _landlordEmailController.dispose();
    _tenantNameController.dispose();
    _propertyAddressController.dispose();
    _propertyPostcodeController.dispose();
    _flueNotesController.dispose();
    _standingPressureController.dispose();
    _workingPressureController.dispose();
    _letByResultController.dispose();
    _tightnessDropController.dispose();
    _defectDetailsController.dispose();
    _actionTakenController.dispose();
    _adviceGivenController.dispose();
    _inspectionDateController.dispose();
    _nextInspectionDueController.dispose();
    _reminderDateController.dispose();
    _engineerNameController.dispose();
    _gasSafeNumberController.dispose();
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _companyPostcodeController.dispose();
    _companyPhoneController.dispose();
    _companyEmailController.dispose();
    for (final a in _appliances) {
      a.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      controller.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  Future<String> getNextCertificateNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('latest_lgs_record');

    if (data == null) {
      return "LGS-00001"; // first record
    }

    final List decoded = jsonDecode(data);

    if (decoded.isEmpty) {
      return "LGS-00001";
    }

    /// 🔥 Get last record
    final last = decoded.last;

    final lastNumberStr = last['certificateNumber'] ?? "LGS-00000";

    /// Extract numeric part
    final numberPart = lastNumberStr.toString().replaceAll("LGS-", "");

    int number = int.tryParse(numberPart) ?? 0;

    number++; // increment

    /// Format with leading zeros
    final newNumber = number.toString().padLeft(5, '0');
    _certificateNumberController.text = "LGS-" + newNumber;

    return "LGS-$newNumber";
  }

  /*void _loadSavedRecord() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('latest_lgs_record');

    if (jsonString == null) return null;

    final Map<String, dynamic> json = jsonDecode(jsonString);

    LandlordGasSafetyRecord landlordGasSafetyRecord =  LandlordGasSafetyRecord(
      certificateNumber: json['certificateNumber'],
      landlordName: json['landlordName'],
      landlordAddress: json['landlordAddress'],
      landlordPostcode: json['landlordPostcode'],
      landlordPhone: json['landlordPhone'],
      landlordEmail: json['landlordEmail'],
      tenantName: json['tenantName'],
      propertyAddress: json['propertyAddress'],
      propertyPostcode: json['propertyPostcode'],
      appliances: (json['appliances'] as List)
          .map((a) => AppliancePlain(
        type: a['type'],
        make: a['make'],
        model: a['model'],
        location: a['location'],
        operatingPressure: a['operatingPressure'],
        heatInput: a['heatInput'],
        coCo2Ratio: a['coCo2Ratio'],
        coPpm: a['coPpm'],
        coCo2RatioHigh: a['coCo2RatioHigh'],
        coPpmHigh: a['coPpmHigh'],
        co2Percent: a['co2Percent'],
      ))
          .toList(),
      ventilationAdequate: json['ventilationAdequate'],
      flueChimneySatisfactory: json['flueChimneySatisfactory'],
      safetyDevicesOk: json['safetyDevicesOk'],
      combustionReadingsSatisfactory: json['combustionReadingsSatisfactory'],
      applianceSafeToUse: json['applianceSafeToUse'],
      flueConditionSatisfactory: json['flueConditionSatisfactory'],
      terminationSatisfactory: json['terminationSatisfactory'],
      flueNotes: json['flueNotes'],
      visualConditionSatisfactory: json['visualConditionSatisfactory'],
      pipeworkSecure: json['pipeworkSecure'],
      earthBonding: json['earthBonding'],
      tightnessTestCarriedOut: json['tightnessTestCarriedOut'],
      standingPressure: json['standingPressure'],
      workingPressure: json['workingPressure'],
      letByResult: json['letByResult'],
      tightnessDrop: json['tightnessDrop'],
      classification: json['classification'],
      defectDetails: json['defectDetails'],
      actionTaken: json['actionTaken'],
      adviceGiven: json['adviceGiven'],
      inspectionDate: json['inspectionDate'],
      nextInspectionDue: json['nextInspectionDue'],
      engineerName: json['engineerName'],
      gasSafeNumber: json['gasSafeNumber'],
      companyName: json['companyName'],
      companyAddress: json['companyAddress'],
      companyPostcode: json['companyPostcode'],
      companyPhone: json['companyPhone'],
      companyEmail: json['companyEmail'],
      engineerSignatureBase64: json['engineerSignatureBase64'],
      landlordSignatureBase64: json['landlordSignatureBase64'],
    );

    _setDataToForm(landlordGasSafetyRecord);
  }*/

  void _setDataToForm(LandlordGasSafetyRecord record) {
    // Certificate
    _certificateNumberController.text = record.certificateNumber;

    // Landlord
    _landlordNameController.text = record.landlordName;
    _landlordAddressController.text = record.landlordAddress;
    _landlordPostcodeController.text = record.landlordPostcode;
    _landlordPhoneController.text = record.landlordPhone;
    _landlordEmailController.text = record.landlordEmail;

    // Property
    _tenantNameController.text = record.tenantName;
    _propertyAddressController.text = record.propertyAddress;
    _propertyPostcodeController.text = record.propertyPostcode;

    // Appliances (IMPORTANT)
    _appliances.clear();
    for (int i = 0; i < record.appliances.length; i++) {
      final a = record.appliances[i];
      final data = ApplianceData.empty(i + 1);
      data.typeController.text = a.type;
      data.makeController.text = a.make;
      data.modelController.text = a.model;
      data.locationController.text = a.location;
      data.operatingPressureController.text = a.operatingPressure;
      data.heatInputController.text = a.heatInput;
      data.coCo2RatioController.text = a.coCo2Ratio;
      data.coPpmController.text = a.coPpm;
      data.coCo2RatioHighController.text = a.coCo2RatioHigh;
      data.coPpmHighController.text = a.coPpmHigh;
      data.co2PercentController.text = a.co2Percent;
      _appliances.add(data);
    }

    // Appliance checks
    ventilationAdequate = record.ventilationAdequate;
    flueChimneySatisfactory = record.flueChimneySatisfactory;
    safetyDevicesOk = record.safetyDevicesOk;
    combustionReadingsSatisfactory = record.combustionReadingsSatisfactory;
    applianceSafeToUse = record.applianceSafeToUse;

    // Flue
    flueConditionSatisfactory = record.flueConditionSatisfactory;
    terminationSatisfactory = record.terminationSatisfactory;
    _flueNotesController.text = record.flueNotes;

    // Pipework
    visualConditionSatisfactory = record.visualConditionSatisfactory;
    pipeworkSecure = record.pipeworkSecure;
    earthBonding = record.earthBonding;
    tightnessTestCarriedOut = record.tightnessTestCarriedOut;

    _standingPressureController.text = record.standingPressure;
    _workingPressureController.text = record.workingPressure;
    _letByResultController.text = record.letByResult;
    _tightnessDropController.text = record.tightnessDrop;

    // Defects
    classification = record.classification;
    _defectDetailsController.text = record.defectDetails;
    _actionTakenController.text = record.actionTaken;
    _adviceGivenController.text = record.adviceGiven;

    // Dates
    _inspectionDateController.text = record.inspectionDate;
    _nextInspectionDueController.text = record.nextInspectionDue;
    _reminderDateController.text = record.reminderDate;

    // Engineer / Company
    _engineerNameController.text = record.engineerName;
    _gasSafeNumberController.text = record.gasSafeNumber;
    _companyNameController.text = record.companyName;
    _companyAddressController.text = record.companyAddress;
    _companyPostcodeController.text = record.companyPostcode;
    _companyPhoneController.text = record.companyPhone;
    _companyEmailController.text = record.companyEmail;

    // Signatures (convert base64 → bytes)
    _engineerSignatureBytes = record.engineerSignatureBase64 != null
        ? base64Decode(record.engineerSignatureBase64!)
        : null;

    _landlordSignatureBytes = record.landlordSignatureBase64 != null
        ? base64Decode(record.landlordSignatureBase64!)
        : null;

    setState(() {});
  }

  void _addAppliance() {
    setState(() {
      _appliances.add(ApplianceData.empty(_appliances.length + 1));
    });
  }

  void _removeAppliance(int index) {
    if (_appliances.length == 1) return;
    setState(() {
      _appliances[index].dispose();
      _appliances.removeAt(index);
    });
  }

/*  Future<void> _saveRecordLocally() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill required fields')),
      );
      return;
    }

    setState(() => _saving = true);

    final record = _buildRecord();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('latest_lgs_record', jsonEncode(record.toJson()));

    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record saved on this device')),
      );
    }
  }*/

  Future<void> _saveRecordLocally() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill required fields')),
      );
      return;
    }

    setState(() => _saving = true);

    final record = _buildRecord();
    final prefs = await SharedPreferences.getInstance();

    /// 🔥 GET EXISTING DATA
    final String? data = prefs.getString('latest_lgs_record');

    List<dynamic> list = [];

    if (data != null) {
      list = jsonDecode(data);
    }

    /// 🔥 FIND INDEX BY CERTIFICATE NUMBER
    final index = list.indexWhere(
      (e) => e['certificateNumber'] == record.certificateNumber,
    );

    if (index != -1) {
      /// ✅ UPDATE EXISTING
      list[index] = record.toJson();
    } else {
      /// ✅ ADD NEW
      list.add(record.toJson());
    }

    /// 🔥 SAVE BACK
    await prefs.setString('latest_lgs_record', jsonEncode(list));

    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          index != -1
              ? 'Record updated successfully'
              : 'Record saved successfully',
        ),
      ),
    );

    Navigator.pop(context);
  }

  LandlordGasSafetyRecord _buildRecord() {
    return LandlordGasSafetyRecord(
      certificateNumber: _certificateNumberController.text.trim(),
      landlordName: _landlordNameController.text.trim(),
      landlordAddress: _landlordAddressController.text.trim(),
      landlordPostcode: _landlordPostcodeController.text.trim(),
      landlordPhone: _landlordPhoneController.text.trim(),
      landlordEmail: _landlordEmailController.text.trim(),
      tenantName: _tenantNameController.text.trim(),
      propertyAddress: _propertyAddressController.text.trim(),
      propertyPostcode: _propertyPostcodeController.text.trim(),
      appliances: _appliances.map((a) => a.toPlain()).toList(growable: false),
      ventilationAdequate: ventilationAdequate,
      flueChimneySatisfactory: flueChimneySatisfactory,
      safetyDevicesOk: safetyDevicesOk,
      combustionReadingsSatisfactory: combustionReadingsSatisfactory,
      applianceSafeToUse: applianceSafeToUse,
      flueConditionSatisfactory: flueConditionSatisfactory,
      terminationSatisfactory: terminationSatisfactory,
      flueNotes: _flueNotesController.text.trim(),
      visualConditionSatisfactory: visualConditionSatisfactory,
      pipeworkSecure: pipeworkSecure,
      earthBonding: earthBonding,
      tightnessTestCarriedOut: tightnessTestCarriedOut,
      standingPressure: _standingPressureController.text.trim(),
      workingPressure: _workingPressureController.text.trim(),
      letByResult: _letByResultController.text.trim(),
      tightnessDrop: _tightnessDropController.text.trim(),
      classification: classification,
      defectDetails: _defectDetailsController.text.trim(),
      actionTaken: _actionTakenController.text.trim(),
      adviceGiven: _adviceGivenController.text.trim(),
      inspectionDate: _inspectionDateController.text.trim(),
      nextInspectionDue: _nextInspectionDueController.text.trim(),
      reminderDate: _reminderDateController.text.trim(),
      engineerName: _engineerNameController.text.trim(),
      gasSafeNumber: _gasSafeNumberController.text.trim(),
      companyName: _companyNameController.text.trim(),
      companyAddress: _companyAddressController.text.trim(),
      companyPostcode: _companyPostcodeController.text.trim(),
      companyPhone: _companyPhoneController.text.trim(),
      companyEmail: _companyEmailController.text.trim(),
      engineerSignatureBase64: _engineerSignatureBytes != null
          ? base64Encode(_engineerSignatureBytes!)
          : null,
      landlordSignatureBase64: _landlordSignatureBytes != null
          ? base64Encode(_landlordSignatureBytes!)
          : null,
    );
  }

  Future<Uint8List> _generatePdfBytes(LandlordGasSafetyRecord record) async {
    // final pdf = AppPdfDocument();
    final pdf = AppPdfDocument();
    final accountStorage = AccountStorage();
    await accountStorage.load();
    final s = accountStorage.settings;
    pw.MemoryImage? logo;
    if (s.logoPath != null && s.logoPath!.isNotEmpty) {
      final Uint8List imageBytes = await File(s.logoPath!).readAsBytes();
      logo = pw.MemoryImage(imageBytes);
    }
    pw.Widget boolRow(String label, bool value) {
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(value ? 'Yes' : 'No'),
        ],
      );
    }

    final gasSafeLogo = await imageFromAssetBundle(
      'assets/ic_gas_safe.png',
    );

    pw.Widget signatureBox(String title, String? base64) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          if (base64 != null)
            pw.Container(
              width: 120,
              height: 60,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 0.5),
              ),
              child: pw.Image(
                pw.MemoryImage(base64Decode(base64)),
                fit: pw.BoxFit.contain,
              ),
            )
          else
            pw.Container(
              width: 120,
              height: 60,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 0.5),
              ),
              child: pw.Center(
                child: pw.Text('No signature'),
              ),
            ),
        ],
      );
    }

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            'Landlord Gas Safety Record',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          if (logo != null) ...[
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
              pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Image(gasSafeLogo, width: 80, height: 80)),
              pw.SizedBox(width: 8),
              pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Image(logo, width: 80, height: 80))
            ]),
            pw.SizedBox(height: 8)
          ],
          pw.Text('Certificate #: ${record.certificateNumber}'),
          pw.SizedBox(height: 16),

          // Landlord
          pw.Text('Landlord Details',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(record.landlordName),
          pw.Text(record.landlordAddress),
          pw.Text(record.landlordPostcode),
          pw.Text('Phone: ${record.landlordPhone}'),
          pw.Text('Email: ${record.landlordEmail}'),
          pw.SizedBox(height: 12),

          // Property
          pw.Text('Property Details',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('Tenant: ${record.tenantName}'),
          pw.Text(record.propertyAddress),
          pw.Text(record.propertyPostcode),
          pw.SizedBox(height: 12),

          // Appliances
          pw.Text('Appliances',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ...record.appliances.map((a) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('${a.type} (${a.make} ${a.model})'),
                pw.Text('  Location: ${a.location}'),
                pw.Text(
                    '  Operating pressure: ${a.operatingPressure}   Heat input: ${a.heatInput}'),
                pw.Text(
                    '  CO/CO₂ ratio: ${a.coCo2Ratio}   CO (ppm): ${a.coPpm}'),
                pw.Text(
                    '  CO/CO₂ ratio High: ${a.coCo2RatioHigh}   CO (ppm) High: ${a.coPpmHigh}'),
                pw.Text('  C02(%): ${a.co2Percent}'),
                pw.SizedBox(height: 4),
              ],
            );
          }),
          pw.SizedBox(height: 12),

          pw.Text('Appliance Checks',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          boolRow('Ventilation adequate', record.ventilationAdequate),
          boolRow(
              'Flue / chimney satisfactory', record.flueChimneySatisfactory),
          boolRow('Safety devices operating correctly', record.safetyDevicesOk),
          boolRow('Combustion readings satisfactory',
              record.combustionReadingsSatisfactory),
          boolRow('Appliance safe to use', record.applianceSafeToUse),
          pw.SizedBox(height: 12),

          pw.Text('Flue / Chimney Checks',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          boolRow('Flue / chimney condition satisfactory',
              record.flueConditionSatisfactory),
          boolRow('Termination satisfactory', record.terminationSatisfactory),
          pw.Text('Notes: ${record.flueNotes}'),
          pw.SizedBox(height: 12),

          pw.Text('Gas Installation Pipework',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          boolRow('Visual condition satisfactory',
              record.visualConditionSatisfactory),
          boolRow('Pipework secure', record.pipeworkSecure),
          boolRow('Earth Bonding', record.earthBonding),
          boolRow('Tightness test carried out', record.tightnessTestCarriedOut),
          pw.Text('Standing pressure (mbar): ${record.standingPressure}'),
          pw.Text('Working pressure (mbar): ${record.workingPressure}'),
          pw.Text('Let-by result: ${record.letByResult}'),
          pw.Text('Tightness test drop (mbar): ${record.tightnessDrop}'),
          pw.SizedBox(height: 12),

          pw.Text('Defects / Unsafe Situations',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('Classification: ${record.classification}'),
          pw.Text('Details: ${record.defectDetails}'),
          pw.Text('Action taken: ${record.actionTaken}'),
          pw.Text('Advice given: ${record.adviceGiven}'),
          pw.SizedBox(height: 12),

          pw.Text('Inspection Dates',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('Inspection date: ${record.inspectionDate}'),
          pw.Text('Next inspection due: ${record.nextInspectionDue}'),
          pw.SizedBox(height: 12),

          pw.Text('Engineer / Company Details',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('Engineer: ${record.engineerName}'),
          pw.Text('Gas Safe reg: ${record.gasSafeNumber}'),
          pw.Text('Company: ${record.companyName}'),
          pw.Text(record.companyAddress),
          pw.Text(record.companyPostcode),
          pw.Text('Phone: ${record.companyPhone}'),
          pw.Text('Email: ${record.companyEmail}'),
          pw.SizedBox(height: 16),

          // SIGNATURES SIDE BY SIDE
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              signatureBox(
                  'Engineer Signature', record.engineerSignatureBase64),
              signatureBox(
                  'Landlord/Tenant Signature', record.landlordSignatureBase64),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  Future<File> _writePdfToTempFile(Uint8List bytes,
      {String fileName = 'landlord_gas_safety.pdf'}) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<void> _onPdfPressed() async {
    if (!_formKey.currentState!.validate()) return;
    final record = _buildRecord();
    final bytes = await _generatePdfBytes(record);
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  Future<void> _onEmailPressed() async {
    if (!_formKey.currentState!.validate()) return;
    final record = _buildRecord();
    final bytes = await _generatePdfBytes(record);
    final file = await _writePdfToTempFile(bytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Landlord Gas Safety Record ${record.certificateNumber}',
      text:
          'Please find attached the Landlord Gas Safety Record for ${record.propertyAddress}.',
    );
  }

  Future<void> _captureSignature({
    required String title,
    required bool forEngineer,
  }) async {
    final controller = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sign: $title'),
          content: SizedBox(
            width: double.maxFinite,
            height: 200,
            child: Signature(
              controller: controller,
              backgroundColor: Colors.grey[200]!,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.clear();
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () async {
                final bytes = await controller.toPngBytes();
                if (bytes != null) {
                  setState(() {
                    if (forEngineer) {
                      _engineerSignatureBytes = bytes;
                    } else {
                      _landlordSignatureBytes = bytes;
                    }
                  });
                }
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _teal,
        title: const Text('Landlord Gas Safety'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Generate PDF',
            onPressed: _onPdfPressed,
          ),
          IconButton(
            icon: const Icon(Icons.email_outlined),
            tooltip: 'Email PDF',
            onPressed: _onEmailPressed,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Container(
          color: Colors.white,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _card(
                title: 'Certificate Info',
                child: _textField(
                  label: 'Certificate #',
                  enable: false,
                  controller: _certificateNumberController,
                ),
              ),
              const SizedBox(height: 12),
              _card(
                title: 'Landlord Details',
                onCustomerButtonClick: () async {
                  dynamic customer = await push(CustomerListScreen(
                    fromScreen: "invoice",
                  ));
                  if (customer != null) {
                    _landlordNameController.text =
                        customer["name"]?.toString() ?? "";

                    _landlordAddressController.text =
                        customer["address"]?.toString() ?? "";

                    _landlordPostcodeController.text =
                        customer["postcode"]?.toString() ?? "";

                    _landlordPhoneController.text =
                        customer["phone"]?.toString() ?? "";

                    _landlordEmailController.text =
                        customer["email"]?.toString() ?? "";
                  }
                },
                child: Column(
                  children: [
                    _textField(
                        label: 'Name', controller: _landlordNameController),
                    _textField(
                        label: 'Address',
                        controller: _landlordAddressController),
                    _textField(
                        label: 'Postcode',
                        controller: _landlordPostcodeController),
                    _textField(
                        label: 'Phone', controller: _landlordPhoneController),
                    _textField(
                        label: 'Email', controller: _landlordEmailController),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _card(
                title: 'Property Details',
                child: Column(
                  children: [
                    _textField(
                        label: 'Tenant (optional)',
                        controller: _tenantNameController,
                        required: false),
                    _textField(
                        label: 'Address',
                        controller: _propertyAddressController),
                    _textField(
                        label: 'Postcode',
                        controller: _propertyPostcodeController),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildAppliancesCard(),
              const SizedBox(height: 12),
              _buildApplianceChecksCard(),
              const SizedBox(height: 12),
              _buildFlueChecksCard(),
              const SizedBox(height: 12),
              _buildPipeworkCard(),
              const SizedBox(height: 12),
              _buildDefectsCard(),
              const SizedBox(height: 12),
              _buildInspectionDatesCard(),
              const SizedBox(height: 12),
              _buildEngineerCard(),
              const SizedBox(height: 12),
              _buildSignaturesCard(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: _saving ? null : _saveRecordLocally,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Save Record'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(
      {required String title,
      required Widget child,
      Function? onCustomerButtonClick}) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              if (onCustomerButtonClick != null)
                IconButton(
                    onPressed: () {
                      onCustomerButtonClick();
                    },
                    icon: Icon(Icons.person_search_rounded))
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    bool required = true,
    bool enable = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: controller,
        enabled: enable,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          isDense: true,
        ),
        validator: (value) {
          if (!required) return null;
          if (value == null || value.trim().isEmpty) {
            return 'Required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildAppliancesCard() {
   // print("Appliance Length ${_appliances.length}");
    return _card(
      title: 'Appliances',
      child: Column(
        children: [
          for (int i = 0; i < _appliances.length; i++)
            _buildApplianceItem(_appliances[i], i),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _addAppliance,
              icon: const Icon(Icons.add),
              label: const Text('Add Appliance'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplianceItem(ApplianceData appliance, int index) {
    return Container(
      key: Key(index.toString()),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Appliance ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _removeAppliance(index),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _innerField('Type (boiler, hob, fire...)', appliance.typeController),
          _innerField('Make', appliance.makeController),
          _innerField('Model', appliance.modelController),
          _innerField('Location', appliance.locationController),
          Row(
            children: [
              Expanded(
                child: _innerField('Operating / standing pressure',
                    appliance.operatingPressureController),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _innerField('Heat input', appliance.heatInputController),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _innerField(
                    'CO / CO\u2082 ratio', appliance.coCo2RatioController),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _innerField('CO (ppm)', appliance.coPpmController),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _innerField('CO / CO\u2082 High ratio',
                    appliance.coCo2RatioHighController),
              ),
              const SizedBox(width: 8),
              Expanded(
                child:
                    _innerField('CO (ppm) High', appliance.coPpmHighController),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _innerField('C02(%)', appliance.co2PercentController),
              ),
              const SizedBox(width: 8),
              Container(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _innerField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          isDense: true,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildApplianceChecksCard() {
    return _card(
      title: 'Appliance Checks',
      child: Column(
        children: [
          _switchRow('Ventilation adequate', ventilationAdequate,
              (v) => setState(() => ventilationAdequate = v)),
          _switchRow('Flue / chimney satisfactory', flueChimneySatisfactory,
              (v) => setState(() => flueChimneySatisfactory = v)),
          _switchRow('Safety devices operating correctly', safetyDevicesOk,
              (v) => setState(() => safetyDevicesOk = v)),
          _switchRow(
              'Combustion readings satisfactory',
              combustionReadingsSatisfactory,
              (v) => setState(() => combustionReadingsSatisfactory = v)),
          _switchRow('Appliance safe to use', applianceSafeToUse,
              (v) => setState(() => applianceSafeToUse = v)),
        ],
      ),
    );
  }

  Widget _buildFlueChecksCard() {
    return _card(
      title: 'Flue / Chimney Checks',
      child: Column(
        children: [
          _switchRow(
              'Flue / chimney condition satisfactory',
              flueConditionSatisfactory,
              (v) => setState(() => flueConditionSatisfactory = v)),
          _switchRow('Termination satisfactory', terminationSatisfactory,
              (v) => setState(() => terminationSatisfactory = v)),
          TextFormField(
            controller: _flueNotesController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Notes',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPipeworkCard() {
    return _card(
      title: 'Gas Installation Pipework',
      child: Column(
        children: [
          _switchRow(
              'Visual condition satisfactory',
              visualConditionSatisfactory,
              (v) => setState(() => visualConditionSatisfactory = v)),
          _switchRow('Pipework secure', pipeworkSecure,
              (v) => setState(() => pipeworkSecure = v)),
          _switchRow('Earth Bonding', earthBonding,
              (v) => setState(() => earthBonding = v)),
          _switchRow('Tightness test carried out', tightnessTestCarriedOut,
              (v) => setState(() => tightnessTestCarriedOut = v)),
          _innerField('Standing pressure (mbar)', _standingPressureController),
          _innerField('Working pressure (mbar)', _workingPressureController),
          _innerField('Let-by result', _letByResultController),
          _innerField('Tightness test drop (mbar)', _tightnessDropController),
        ],
      ),
    );
  }

  Widget _buildDefectsCard() {
    return _card(
      title: 'Defects / Unsafe Situations',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Classification'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _classificationChip('None'),
              _classificationChip('ID'),
              _classificationChip('AR'),
              //  _classificationChip('NCS'),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _defectDetailsController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Details of unsafe situation / defects',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _actionTakenController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Action taken',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _adviceGivenController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Advice given',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionDatesCard() {
    return _card(
      title: 'Inspection Dates',
      child: Column(
        children: [
          _dateField('Inspection date', _inspectionDateController),
          _dateField('Next inspection due', _nextInspectionDueController),
          _dateField('Reminder Date', _reminderDateController),
        ],
      ),
    );
  }

  Widget _dateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          isDense: true,
        ),
        onTap: () => _pickDate(controller),
        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
      ),
    );
  }

  Widget _buildEngineerCard() {
    return _card(
      title: 'Engineer / Company Details',
      child: Column(
        children: [
          CompanyLogo(),
          const SizedBox(
            height: 10.0,
          ),
          _textField(
              label: 'Engineer name', controller: _engineerNameController),
          _textField(
              label: 'Gas Safe registration no.',
              controller: _gasSafeNumberController),
          _textField(label: 'Company name', controller: _companyNameController),
          _textField(
              label: 'Company address', controller: _companyAddressController),
          _textField(label: 'Postcode', controller: _companyPostcodeController),
          _textField(label: 'Phone', controller: _companyPhoneController),
          _textField(label: 'Email', controller: _companyEmailController),
        ],
      ),
    );
  }

  Widget _buildSignaturesCard() {
    return _card(
      title: 'Signatures',
      child: Row(
        children: [
          Expanded(
            child: _SignatureBox(
              label: 'Engineer Signature',
              bytes: _engineerSignatureBytes,
              onTap: () => _captureSignature(
                title: 'Engineer',
                forEngineer: true,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SignatureBox(
              label: 'Landlord / Tenant Signature',
              bytes: _landlordSignatureBytes,
              onTap: () => _captureSignature(
                title: 'Landlord / Tenant',
                forEngineer: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _switchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label)),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: _teal,
          ),
        ],
      ),
    );
  }

  Widget _classificationChip(String valueLabel) {
    final selected = classification == valueLabel;
    return ChoiceChip(
      label: Text(valueLabel),
      selected: selected,
      onSelected: (_) => setState(() => classification = valueLabel),
      selectedColor: _teal.withOpacity(0.15),
    );
  }
}

// ---------------------------------------------------------------------------
// Small signature widget for the UI
// ---------------------------------------------------------------------------

class _SignatureBox extends StatelessWidget {
  final String label;
  final Uint8List? bytes;
  final VoidCallback onTap;

  const _SignatureBox({
    required this.label,
    required this.bytes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          const SizedBox(height: 4),
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: bytes == null
                ? const Center(
                    child: Text(
                      'Tap to sign',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      bytes!,
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

class AppliancePlain {
  final String type;
  final String make;
  final String model;
  final String location;
  final String operatingPressure;
  final String heatInput;
  final String coCo2Ratio;
  final String coPpm;

  final String coCo2RatioHigh;
  final String coPpmHigh;
  final String co2Percent;

  AppliancePlain({
    required this.type,
    required this.make,
    required this.model,
    required this.location,
    required this.operatingPressure,
    required this.heatInput,
    required this.coCo2Ratio,
    required this.coPpm,
    required this.coCo2RatioHigh,
    required this.coPpmHigh,
    required this.co2Percent,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'make': make,
        'model': model,
        'location': location,
        'operatingPressure': operatingPressure,
        'heatInput': heatInput,
        'coCo2Ratio': coCo2Ratio,
        'coPpm': coPpm,
        'coCo2RatioHigh': coCo2RatioHigh,
        'coPpmHigh': coPpmHigh,
        'co2Percent': co2Percent,
      };

  factory AppliancePlain.fromJson(Map<String, dynamic> json) {
    return AppliancePlain(
      type: json['type'] ?? '',
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      location: json['location'] ?? '',
      operatingPressure: json['operatingPressure'] ?? '',
      heatInput: json['heatInput'] ?? '',
      coCo2Ratio: json['coCo2Ratio'] ?? '',
      coPpm: json['coPpm'] ?? '',
      coCo2RatioHigh: json['coCo2RatioHigh'] ?? '',
      coPpmHigh: json['coPpmHigh'] ?? '',
      co2Percent: json['co2Percent'] ?? '',
    );
  }
}

class ApplianceData {
  final int index;
  final TextEditingController typeController;
  final TextEditingController makeController;
  final TextEditingController modelController;
  final TextEditingController locationController;
  final TextEditingController operatingPressureController;
  final TextEditingController heatInputController;
  final TextEditingController coCo2RatioController;
  final TextEditingController coPpmController;

  final TextEditingController coCo2RatioHighController;
  final TextEditingController coPpmHighController;
  final TextEditingController co2PercentController;

  ApplianceData._({
    required this.index,
    required this.typeController,
    required this.makeController,
    required this.modelController,
    required this.locationController,
    required this.operatingPressureController,
    required this.heatInputController,
    required this.coCo2RatioController,
    required this.coPpmController,
    required this.coCo2RatioHighController,
    required this.coPpmHighController,
    required this.co2PercentController,
  });

  factory ApplianceData.empty(int index) {
    return ApplianceData._(
      index: index,
      typeController: TextEditingController(),
      makeController: TextEditingController(),
      modelController: TextEditingController(),
      locationController: TextEditingController(),
      operatingPressureController: TextEditingController(),
      heatInputController: TextEditingController(),
      coCo2RatioController: TextEditingController(),
      coPpmController: TextEditingController(),
      coCo2RatioHighController: TextEditingController(),
      coPpmHighController: TextEditingController(),
      co2PercentController: TextEditingController(),
    );
  }

  AppliancePlain toPlain() {
    return AppliancePlain(
        type: typeController.text.trim(),
        make: makeController.text.trim(),
        model: modelController.text.trim(),
        location: locationController.text.trim(),
        operatingPressure: operatingPressureController.text.trim(),
        heatInput: heatInputController.text.trim(),
        coCo2Ratio: coCo2RatioController.text.trim(),
        coPpm: coPpmController.text.trim(),
        coCo2RatioHigh: coCo2RatioHighController.text.trim(),
        coPpmHigh: coPpmHighController.text.trim(),
        co2Percent: co2PercentController.text.trim());
  }

  void dispose() {
    typeController.dispose();
    makeController.dispose();
    modelController.dispose();
    locationController.dispose();
    operatingPressureController.dispose();
    heatInputController.dispose();
    coCo2RatioController.dispose();
    coPpmController.dispose();
    coCo2RatioHighController.dispose();
    coPpmHighController.dispose();
    co2PercentController.dispose();
  }
}

class LandlordGasSafetyRecord {
  final String certificateNumber;
  final String landlordName;
  final String landlordAddress;
  final String landlordPostcode;
  final String landlordPhone;
  final String landlordEmail;

  final String tenantName;
  final String propertyAddress;
  final String propertyPostcode;

  final List<AppliancePlain> appliances;

  final bool ventilationAdequate;
  final bool flueChimneySatisfactory;
  final bool safetyDevicesOk;
  final bool combustionReadingsSatisfactory;
  final bool applianceSafeToUse;

  final bool flueConditionSatisfactory;
  final bool terminationSatisfactory;
  final String flueNotes;

  final bool visualConditionSatisfactory;
  final bool pipeworkSecure;
  final bool earthBonding;
  final bool tightnessTestCarriedOut;
  final String standingPressure;
  final String workingPressure;
  final String letByResult;
  final String tightnessDrop;

  final String classification;
  final String defectDetails;
  final String actionTaken;
  final String adviceGiven;

  final String inspectionDate;
  final String nextInspectionDue;
  final String reminderDate;

  final String engineerName;
  final String gasSafeNumber;
  final String companyName;
  final String companyAddress;
  final String companyPostcode;
  final String companyPhone;
  final String companyEmail;

  final String? engineerSignatureBase64;
  final String? landlordSignatureBase64;

  LandlordGasSafetyRecord({
    required this.certificateNumber,
    required this.landlordName,
    required this.landlordAddress,
    required this.landlordPostcode,
    required this.landlordPhone,
    required this.landlordEmail,
    required this.tenantName,
    required this.propertyAddress,
    required this.propertyPostcode,
    required this.appliances,
    required this.ventilationAdequate,
    required this.flueChimneySatisfactory,
    required this.safetyDevicesOk,
    required this.combustionReadingsSatisfactory,
    required this.applianceSafeToUse,
    required this.flueConditionSatisfactory,
    required this.terminationSatisfactory,
    required this.flueNotes,
    required this.visualConditionSatisfactory,
    required this.pipeworkSecure,
    required this.earthBonding,
    required this.tightnessTestCarriedOut,
    required this.standingPressure,
    required this.workingPressure,
    required this.letByResult,
    required this.tightnessDrop,
    required this.classification,
    required this.defectDetails,
    required this.actionTaken,
    required this.adviceGiven,
    required this.inspectionDate,
    required this.nextInspectionDue,
    required this.reminderDate,
    required this.engineerName,
    required this.gasSafeNumber,
    required this.companyName,
    required this.companyAddress,
    required this.companyPostcode,
    required this.companyPhone,
    required this.companyEmail,
    required this.engineerSignatureBase64,
    required this.landlordSignatureBase64,
  });

  Map<String, dynamic> toJson() => {
        'certificateNumber': certificateNumber,
        'landlordName': landlordName,
        'landlordAddress': landlordAddress,
        'landlordPostcode': landlordPostcode,
        'landlordPhone': landlordPhone,
        'landlordEmail': landlordEmail,
        'tenantName': tenantName,
        'propertyAddress': propertyAddress,
        'propertyPostcode': propertyPostcode,
        'appliances': appliances.map((a) => a.toJson()).toList(),
        'ventilationAdequate': ventilationAdequate,
        'flueChimneySatisfactory': flueChimneySatisfactory,
        'safetyDevicesOk': safetyDevicesOk,
        'combustionReadingsSatisfactory': combustionReadingsSatisfactory,
        'applianceSafeToUse': applianceSafeToUse,
        'flueConditionSatisfactory': flueConditionSatisfactory,
        'terminationSatisfactory': terminationSatisfactory,
        'flueNotes': flueNotes,
        'visualConditionSatisfactory': visualConditionSatisfactory,
        'pipeworkSecure': pipeworkSecure,
        'earthBonding': earthBonding,
        'tightnessTestCarriedOut': tightnessTestCarriedOut,
        'standingPressure': standingPressure,
        'workingPressure': workingPressure,
        'letByResult': letByResult,
        'tightnessDrop': tightnessDrop,
        'classification': classification,
        'defectDetails': defectDetails,
        'actionTaken': actionTaken,
        'adviceGiven': adviceGiven,
        'inspectionDate': inspectionDate,
        'nextInspectionDue': nextInspectionDue,
        'reminderDate': reminderDate,
        'engineerName': engineerName,
        'gasSafeNumber': gasSafeNumber,
        'companyName': companyName,
        'companyAddress': companyAddress,
        'companyPostcode': companyPostcode,
        'companyPhone': companyPhone,
        'companyEmail': companyEmail,
        'engineerSignatureBase64': engineerSignatureBase64,
        'landlordSignatureBase64': landlordSignatureBase64,
      };

  factory LandlordGasSafetyRecord.fromJson(Map<String, dynamic> json) {
    return LandlordGasSafetyRecord(
      certificateNumber: json['certificateNumber'] ?? '',
      landlordName: json['landlordName'] ?? '',
      landlordAddress: json['landlordAddress'] ?? '',
      landlordPostcode: json['landlordPostcode'] ?? '',
      landlordPhone: json['landlordPhone'] ?? '',
      landlordEmail: json['landlordEmail'] ?? '',
      tenantName: json['tenantName'] ?? '',
      propertyAddress: json['propertyAddress'] ?? '',
      propertyPostcode: json['propertyPostcode'] ?? '',
      appliances: (json['appliances'] as List? ?? [])
          .map((e) => AppliancePlain.fromJson(e))
          .toList(),
      ventilationAdequate: json['ventilationAdequate'] ?? false,
      flueChimneySatisfactory: json['flueChimneySatisfactory'] ?? false,
      safetyDevicesOk: json['safetyDevicesOk'] ?? false,
      combustionReadingsSatisfactory:
          json['combustionReadingsSatisfactory'] ?? false,
      applianceSafeToUse: json['applianceSafeToUse'] ?? false,
      flueConditionSatisfactory: json['flueConditionSatisfactory'] ?? false,
      terminationSatisfactory: json['terminationSatisfactory'] ?? false,
      flueNotes: json['flueNotes'] ?? '',
      visualConditionSatisfactory: json['visualConditionSatisfactory'] ?? false,
      pipeworkSecure: json['pipeworkSecure'] ?? false,
      earthBonding: json['earthBonding'] ?? false,
      tightnessTestCarriedOut: json['tightnessTestCarriedOut'] ?? false,
      standingPressure: json['standingPressure'] ?? '',
      workingPressure: json['workingPressure'] ?? '',
      letByResult: json['letByResult'] ?? '',
      tightnessDrop: json['tightnessDrop'] ?? '',
      classification: json['classification'] ?? '',
      defectDetails: json['defectDetails'] ?? '',
      actionTaken: json['actionTaken'] ?? '',
      adviceGiven: json['adviceGiven'] ?? '',
      inspectionDate: json['inspectionDate'] ?? '',
      nextInspectionDue: json['nextInspectionDue'] ?? '',
      reminderDate: json['reminderDate'] ?? '',
      engineerName: json['engineerName'] ?? '',
      gasSafeNumber: json['gasSafeNumber'] ?? '',
      companyName: json['companyName'] ?? '',
      companyAddress: json['companyAddress'] ?? '',
      companyPostcode: json['companyPostcode'] ?? '',
      companyPhone: json['companyPhone'] ?? '',
      companyEmail: json['companyEmail'] ?? '',
      engineerSignatureBase64: json['engineerSignatureBase64'],
      landlordSignatureBase64: json['landlordSignatureBase64'],
    );
  }
}
