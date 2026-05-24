import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:signature/signature.dart';
import 'package:the_gas_man_app/pages/new_invoice_page/account_storage_file.dart';
import 'package:the_gas_man_app/pages/new_invoice_page/data_model/all_models.dart';

import '../../../models/company_settings.dart';
import '../../../utils_class/app_pdf_documents.dart';
import '../../../utils_class/utils.dart';
import '../../new_tax_and_invoice/pages/customer/customer_list_screen.dart';
import '../common_ui/company_logo.dart';

class NewServiceRecordPage extends StatefulWidget {

  final ServiceRecord? record;
  const NewServiceRecordPage({super.key,this.record});

  @override
  State<NewServiceRecordPage> createState() => _NewServiceRecordPageState();
}

class _NewServiceRecordPageState extends State<NewServiceRecordPage> {
  static const Color _teal = Color(0xFF4F7F7F);
  static const Color _cardBg = Color(0xFFF3F7F7);

  final _formKey = GlobalKey<FormState>();

  // Certificate / record info
  final _recordNumberController = TextEditingController(text: 'SR-00001');

  // Customer / property
  final _customerNameController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _customerPostcodeController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerEmailController = TextEditingController();

  final _propertyAddressController = TextEditingController();
  final _propertyPostcodeController = TextEditingController();
  final _occupierNameController = TextEditingController();

  // Appliances
  final List<ServiceApplianceData> _appliances = [
    ServiceApplianceData.empty(1)
  ];

  // System tightness
  final _letByResultController = TextEditingController();
  final _tightnessDropController = TextEditingController();
  final _tightnessDurationController = TextEditingController();
  bool tightnessTestDone = false;
  bool tightnessPass = true;

  // Global service tasks
  bool burnerCleaned = false;
  bool heatExchangerCleaned = false;
  bool condensateTrapCleaned = false;
  bool magneticFilterCleaned = false;
  bool filtersCleaned = false;
  bool systemPressureChecked = false;
  bool inhibitorLevelChecked = false;
  bool waterQualityChecked = false;
  bool fanCleaned = false;
  bool expansionVesselSet = false;
  bool sealsReplaced = false;
  bool fullOperationalCheck = true;

  // Defects / advisory
  String classification = 'None'; // None, NCS, AR, ID
  final _defectDetailsController = TextEditingController();
  final _actionTakenController = TextEditingController();
  final _adviceGivenController = TextEditingController();

  // Dates
  final _serviceDateController = TextEditingController();
  final _nextServiceDueController = TextEditingController();
  final _reminderDateController = TextEditingController();

  // Engineer / company
  final _engineerNameController = TextEditingController();
  final _gasSafeNumberController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyAddressController = TextEditingController();
  final _companyPostcodeController = TextEditingController();
  final _companyPhoneController = TextEditingController();
  final _companyEmailController = TextEditingController();

  // Signatures
  Uint8List? _engineerSignatureBytes;
  Uint8List? _customerSignatureBytes;

  bool _saving = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setCompanyDetails();
    Future.delayed(Duration.zero, () {
      if(widget.record != null){
        _setFormData(widget.record!);
      }else{
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

  Future<String> getNextCertificateNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('latest_service_record');

    if (data == null) {
      return "SR-00001"; // first record
    }

    final List decoded = jsonDecode(data);

    if (decoded.isEmpty) {
      return "SR-00001";
    }

    /// 🔥 Get last record
    final last = decoded.last;

    final lastNumberStr = last['recordNumber'] ?? "SR-00000";

    /// Extract numeric part
    final numberPart = lastNumberStr.toString().replaceAll("SR-", "");

    int number = int.tryParse(numberPart) ?? 0;

    number++; // increment

    /// Format with leading zeros
    final newNumber = number.toString().padLeft(5, '0');
    _recordNumberController.text = "SR-"+newNumber;

    return "SR-$newNumber";
  }



  void _setFormData(ServiceRecord record) {
    setState(() {
      _recordNumberController.text = record.recordNumber ?? 'SR-00001';

      _customerNameController.text = record.customerName ?? '';
      _customerAddressController.text = record.customerAddress ?? '';
      _customerPostcodeController.text = record.customerPostcode ?? '';
      _customerPhoneController.text = record.customerPhone ?? '';
      _customerEmailController.text = record.customerEmail ?? '';

      _propertyAddressController.text = record.propertyAddress ?? '';
      _propertyPostcodeController.text = record.propertyPostcode ?? '';
      _occupierNameController.text = record.occupierName ?? '';

      _letByResultController.text = record.letByResult ?? '';
      _tightnessDropController.text = record.tightnessDrop ?? '';
      _tightnessDurationController.text = record.tightnessDuration ?? '';

      tightnessTestDone = record.tightnessTestDone ?? false;
      tightnessPass = record.tightnessPass ?? true;

      burnerCleaned = record.burnerCleaned ?? false;
      heatExchangerCleaned = record.heatExchangerCleaned ?? false;
      condensateTrapCleaned = record.condensateTrapCleaned ?? false;
      magneticFilterCleaned = record.magneticFilterCleaned ?? false;
      filtersCleaned = record.filtersCleaned ?? false;
      systemPressureChecked = record.systemPressureChecked ?? false;
      inhibitorLevelChecked = record.inhibitorLevelChecked ?? false;
      waterQualityChecked = record.waterQualityChecked ?? false;
      fanCleaned = record.fanCleaned ?? false;
      expansionVesselSet = record.expansionVesselSet ?? false;
      sealsReplaced = record.sealsReplaced ?? false;
      fullOperationalCheck = record.fullOperationalCheck ?? true;

      classification = record.classification ?? 'None';

      _defectDetailsController.text = record.defectDetails ?? '';
      _actionTakenController.text = record.actionTaken ?? '';
      _adviceGivenController.text = record.adviceGiven ?? '';

      _serviceDateController.text = record.serviceDate ?? '';
      _nextServiceDueController.text = record.nextServiceDue ?? '';
      _reminderDateController.text = record.reminderDate ?? '';

      _engineerNameController.text = record.engineerName ?? '';
      _gasSafeNumberController.text = record.gasSafeNumber ?? '';

      _companyNameController.text = record.companyName ?? '';
      _companyAddressController.text = record.companyAddress ?? '';
      _companyPostcodeController.text = record.companyPostcode ?? '';
      _companyPhoneController.text = record.companyPhone ?? '';
      _companyEmailController.text = record.companyEmail ?? '';

      /// 🔥 Appliances mapping (IMPORTANT)
      _appliances.clear();
      if (record.appliances != null && record.appliances!.isNotEmpty) {
        _appliances.addAll(
          record.appliances.asMap().entries.map(
                (entry) => ServiceApplianceData.fromPlain(
                  entry.value,
                  entry.key + 1, // index
                ),
              ),
        );
      } else {
        _appliances.add(ServiceApplianceData.empty(1));
      }

      /// 🔥 Restore signatures
      _engineerSignatureBytes = record.engineerSignatureBase64 != null
          ? base64Decode(record.engineerSignatureBase64!)
          : null;

      _customerSignatureBytes = record.customerSignatureBase64 != null
          ? base64Decode(record.customerSignatureBase64!)
          : null;
    });
  }

  @override
  void dispose() {
    _recordNumberController.dispose();
    _customerNameController.dispose();
    _customerAddressController.dispose();
    _customerPostcodeController.dispose();
    _customerPhoneController.dispose();
    _customerEmailController.dispose();
    _propertyAddressController.dispose();
    _propertyPostcodeController.dispose();
    _occupierNameController.dispose();
    _letByResultController.dispose();
    _tightnessDropController.dispose();
    _tightnessDurationController.dispose();
    _defectDetailsController.dispose();
    _actionTakenController.dispose();
    _adviceGivenController.dispose();
    _serviceDateController.dispose();
    _nextServiceDueController.dispose();
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

  void _addAppliance() {
    setState(() {
      _appliances.add(ServiceApplianceData.empty(_appliances.length + 1));
    });
  }

  void _removeAppliance(int index) {
    if (_appliances.length == 1) return;
    setState(() {
      _appliances[index].dispose();
      _appliances.removeAt(index);
    });
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
                      _customerSignatureBytes = bytes;
                    }
                  });
                }
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
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
    await prefs.setString(
        'latest_service_record', jsonEncode(record.toJson()));

    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service record saved on this device')),
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
    final String? data = prefs.getString('latest_service_record');

    List<dynamic> list = [];

    if (data != null) {
      list = jsonDecode(data);
    }

    /// 🔥 FIND INDEX BY CERTIFICATE NUMBER
    final index = list.indexWhere(
      (e) => e['recordNumber'] == record.recordNumber,
    );

    if (index != -1) {
      /// ✅ UPDATE EXISTING
      list[index] = record.toJson();
    } else {
      /// ✅ ADD NEW
      list.add(record.toJson());
    }

    /// 🔥 SAVE BACK
    await prefs.setString('latest_service_record', jsonEncode(list));

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

  ServiceRecord _buildRecord() {
    return ServiceRecord(
      recordNumber: _recordNumberController.text.trim(),
      customerName: _customerNameController.text.trim(),
      customerAddress: _customerAddressController.text.trim(),
      customerPostcode: _customerPostcodeController.text.trim(),
      customerPhone: _customerPhoneController.text.trim(),
      customerEmail: _customerEmailController.text.trim(),
      propertyAddress: _propertyAddressController.text.trim(),
      propertyPostcode: _propertyPostcodeController.text.trim(),
      occupierName: _occupierNameController.text.trim(),
      appliances: _appliances.map((a) => a.toPlain()).toList(growable: false),
      letByResult: _letByResultController.text.trim(),
      tightnessDrop: _tightnessDropController.text.trim(),
      tightnessDuration: _tightnessDurationController.text.trim(),
      tightnessTestDone: tightnessTestDone,
      tightnessPass: tightnessPass,
      burnerCleaned: burnerCleaned,
      heatExchangerCleaned: heatExchangerCleaned,
      condensateTrapCleaned: condensateTrapCleaned,
      magneticFilterCleaned: magneticFilterCleaned,
      filtersCleaned: filtersCleaned,
      systemPressureChecked: systemPressureChecked,
      inhibitorLevelChecked: inhibitorLevelChecked,
      waterQualityChecked: waterQualityChecked,
      fanCleaned: fanCleaned,
      expansionVesselSet: expansionVesselSet,
      sealsReplaced: sealsReplaced,
      fullOperationalCheck: fullOperationalCheck,
      classification: classification,
      defectDetails: _defectDetailsController.text.trim(),
      actionTaken: _actionTakenController.text.trim(),
      adviceGiven: _adviceGivenController.text.trim(),
      serviceDate: _serviceDateController.text.trim(),
      nextServiceDue: _nextServiceDueController.text.trim(),
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
      customerSignatureBase64: _customerSignatureBytes != null
          ? base64Encode(_customerSignatureBytes!)
          : null,
    );
  }

  Future<Uint8List> _generatePdfBytes(ServiceRecord record) async {
   final pdf = AppPdfDocument();

    // pw.Widget boolRow(String label, bool value) {
    //   return pw.Row(
    //     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    //     children: [
    //       pw.Text(label),
    //       pw.Text(value ? 'Yes' : 'No'),
    //     ],
    //   );
    // }

   final accountStorage = AccountStorage();
   await accountStorage.load();
   final s = accountStorage.settings;
   pw.MemoryImage? logo;
   if(s.logoPath != null && s.logoPath!.isNotEmpty){
     final Uint8List imageBytes = await File(s.logoPath!).readAsBytes();
     logo = pw.MemoryImage(imageBytes);
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
              decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
              child: pw.Image(
                pw.MemoryImage(base64Decode(base64)),
                fit: pw.BoxFit.contain,
              ),
            )
          else
            pw.Container(
              width: 120,
              height: 60,
              decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
              child: pw.Center(child: pw.Text('No signature')),
            ),
        ],
      );
    }

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            'Gas Appliance Service Record',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          if(logo != null)...[
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child:  pw.Image(gasSafeLogo, width: 80, height: 80)
                  ),
                  pw.SizedBox(width: 8),
                  pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child:  pw.Image(logo, width: 80, height: 80)
                  )
                ]
            ),
            pw.SizedBox(height: 8)
          ],
          pw.Text('Record #: ${record.recordNumber}'),
          pw.SizedBox(height: 16),

          // Customer / property
          pw.Text('Customer Details',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(record.customerName),
          pw.Text(record.customerAddress),
          pw.Text(record.customerPostcode),
          pw.Text('Phone: ${record.customerPhone}'),
          pw.Text('Email: ${record.customerEmail}'),
          pw.SizedBox(height: 12),

          pw.Text('Property Details',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('Occupier: ${record.occupierName}'),
          pw.Text(record.propertyAddress),
          pw.Text(record.propertyPostcode),
          pw.SizedBox(height: 12),

          // Appliances
          pw.Text('Appliances Serviced',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ...record.appliances.map((a) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('• ${a.type} (${a.make} ${a.model})'),
                pw.Text('  Location: ${a.location}'),
                pw.Text('  Serial: ${a.serialNumber}   Gas type: ${a.gasType}'),
                pw.Text(
                    '  Standing: ${a.standingPressure} mbar   Working: ${a.workingPressure} mbar   Inlet: ${a.inletPressure} mbar'),
                pw.Text('  Gas rate: ${a.gasRate}'),
                pw.Text(
                    '  CO: ${a.coPpm} ppm   CO₂: ${a.co2Percent}%   CO/CO₂: ${a.coCo2Ratio}'),
                pw.Text(
                    '  Visual OK: ${a.visualConditionOk ? 'Yes' : 'No'} | Flue OK: ${a.flueConditionOk ? 'Yes' : 'No'} | Ventilation OK: ${a.ventilationOk ? 'Yes' : 'No'}'),
                pw.Text(
                    '  Safety devices: ${a.safetyDevicesOk ? 'OK' : 'Issue'} | Ignition: ${a.ignitionOk ? 'OK' : 'Issue'} | Flame: ${a.flamePictureOk ? 'OK' : 'Issue'}'),
                pw.Text(
                    '  Combustion test: ${a.combustionTestDone ? 'Done' : 'Not done'} | Flue integrity: ${a.flueIntegrityOk ? 'OK' : 'Issue'}'),
                pw.Text(
                    '  Open-flue tests: Spillage ${a.spillageTestPass ? 'Pass' : 'Fail'} | Flue flow ${a.flueFlowTestPass ? 'Pass' : 'Fail'}'),
                pw.Text(
                    '  Appliance safe to use: ${a.applianceSafeToUse ? 'Yes' : 'No'}'),
                pw.SizedBox(height: 6),
              ],
            );
          }),
          pw.SizedBox(height: 12),

          // Tightness
          pw.Text('System Tightness Test',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('Test completed: ${record.tightnessTestDone ? 'Yes' : 'No'}'),
          if (record.tightnessTestDone) ...[
            pw.Text('Let-by result: ${record.letByResult}'),
            pw.Text(
                'Pressure drop: ${record.tightnessDrop}   Duration: ${record.tightnessDuration}'),
            pw.Text('Pass: ${record.tightnessPass ? 'Yes' : 'No'}'),
          ],
          pw.SizedBox(height: 12),

          // Service work
          pw.Text('Service Work Carried Out',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(_serviceLine('Burner cleaned', record.burnerCleaned)),
          pw.Text(_serviceLine(
              'Heat exchanger cleaned', record.heatExchangerCleaned)),
          pw.Text(_serviceLine(
              'Condensate trap cleaned', record.condensateTrapCleaned)),
          pw.Text(_serviceLine(
              'Magnetic filter cleaned', record.magneticFilterCleaned)),
          pw.Text(_serviceLine('Filters cleaned', record.filtersCleaned)),
          pw.Text(_serviceLine(
              'System pressure checked', record.systemPressureChecked)),
          pw.Text(_serviceLine(
              'Inhibitor level checked', record.inhibitorLevelChecked)),
          pw.Text(_serviceLine(
              'Water quality checked', record.waterQualityChecked)),
          pw.Text(_serviceLine('Fan cleaned', record.fanCleaned)),
          pw.Text(
              _serviceLine('Expansion vessel set', record.expansionVesselSet)),
          pw.Text(_serviceLine(
              'Case seals replaced where required', record.sealsReplaced)),
          pw.Text(_serviceLine(
              'Full operational check', record.fullOperationalCheck)),
          pw.SizedBox(height: 12),

          // Defects
          pw.Text('Defects / Advisory Notes',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('Classification: ${record.classification}'),
          pw.Text('Defects: ${record.defectDetails}'),
          pw.Text('Action taken: ${record.actionTaken}'),
          pw.Text('Advice given: ${record.adviceGiven}'),
          pw.SizedBox(height: 12),

          // Dates
          pw.Text('Service Dates',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('Service date: ${record.serviceDate}'),
          pw.Text('Next service due: ${record.nextServiceDue}'),
          pw.SizedBox(height: 12),

          // Engineer
          pw.Text('Engineer / Company Details',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('Engineer: ${record.engineerName}'),
          pw.Text('Gas Safe reg: ${record.gasSafeNumber}'),
          pw.Text(record.companyName),
          pw.Text(record.companyAddress),
          pw.Text(record.companyPostcode),
          pw.Text('Phone: ${record.companyPhone}'),
          pw.Text('Email: ${record.companyEmail}'),
          pw.SizedBox(height: 16),

          // Signatures side by side
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              signatureBox(
                  'Engineer Signature', record.engineerSignatureBase64),
              signatureBox(
                  'Customer Signature', record.customerSignatureBase64),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static String _serviceLine(String label, bool value) {
    return '${value ? '✔' : '✘'} $label';
  }

  Future<File> _writePdfToTempFile(Uint8List bytes,
      {String fileName = 'gas_service_record.pdf'}) async {
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
      subject: 'Gas Service Record ${record.recordNumber}',
      text:
          'Please find attached the Gas Appliance Service Record for ${record.propertyAddress}.',
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
        title: const Text('Gas Service Record'),
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
                title: 'Record Info',
                child: _textField(
                  label: 'Record #',
                  enabled: false,
                  controller: _recordNumberController,
                ),
              ),
              const SizedBox(height: 12),
              _card(
                title: 'Customer Details',
                onCustomerButtonClick: () async {
                  dynamic customer = await push(CustomerListScreen(
                    fromScreen: "invoice",
                  ));
                  if (customer != null) {
                    _customerNameController.text =
                        customer["name"]?.toString() ?? "";

                    _customerAddressController.text =
                        customer["address"]?.toString() ?? "";

                    _customerPostcodeController.text =
                        customer["postcode"]?.toString() ?? "";

                    _customerPhoneController.text =
                        customer["phone"]?.toString() ?? "";

                    _customerEmailController.text =
                        customer["email"]?.toString() ?? "";
                  }
                },
                child: Column(
                  children: [
                    _textField(
                        label: 'Name', controller: _customerNameController),
                    _textField(
                        label: 'Address',
                        controller: _customerAddressController),
                    _textField(
                        label: 'Postcode',
                        controller: _customerPostcodeController),
                    _textField(
                        label: 'Phone', controller: _customerPhoneController),
                    _textField(
                        label: 'Email', controller: _customerEmailController),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _card(
                title: 'Property Details',
                child: Column(
                  children: [
                    _textField(
                        label: 'Occupier (optional)',
                        controller: _occupierNameController,
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
              _buildTightnessCard(),
              const SizedBox(height: 12),
              _buildServiceWorkCard(),
              const SizedBox(height: 12),
              _buildDefectsCard(),
              const SizedBox(height: 12),
              _buildDatesCard(),
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
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
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

  // Appliances
  Widget _buildAppliancesCard() {
    return _card(
      title: 'Appliances Serviced',
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

  Widget _buildApplianceItem(ServiceApplianceData appliance, int index) {
    return Container(
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
          _innerField(
              'Type (boiler, fire, cooker...)', appliance.typeController),
          _innerField('Make', appliance.makeController),
          _innerField('Model', appliance.modelController),
          _innerField('Location', appliance.locationController),
          Row(
            children: [
              Expanded(
                child: _innerField(
                    'Serial number', appliance.serialNumberController),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: appliance.gasType,
                  decoration: InputDecoration(
                    labelText: 'Gas type',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'NG', child: Text('Natural Gas')),
                    DropdownMenuItem(value: 'LPG', child: Text('LPG')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (v) {
                    setState(() {
                      appliance.gasType = v ?? 'NG';
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Visual checks
          const Text('Visual & Safety Checks',
              style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          _applianceSwitch(
              'Appliance condition satisfactory',
              appliance.visualConditionOk,
              (v) => setState(() => appliance.visualConditionOk = v)),
          _applianceSwitch(
              'Flue/chimney condition satisfactory',
              appliance.flueConditionOk,
              (v) => setState(() => appliance.flueConditionOk = v)),
          _applianceSwitch('Ventilation correct', appliance.ventilationOk,
              (v) => setState(() => appliance.ventilationOk = v)),
          _applianceSwitch(
              'Pipework & isolation valve satisfactory',
              appliance.pipeworkOk,
              (v) => setState(() => appliance.pipeworkOk = v)),
          _applianceSwitch('Seals intact', appliance.sealsIntact,
              (v) => setState(() => appliance.sealsIntact = v)),
          _applianceSwitch('No water leaks present', appliance.noWaterLeaks,
              (v) {
            setState(() => appliance.noWaterLeaks = v);
          }),
          _applianceSwitch(
              'No signs of distress/overheating',
              appliance.noSignsOfDistress,
              (v) => setState(() => appliance.noSignsOfDistress = v)),

          const SizedBox(height: 8),
          const Text('Burner & Safety Devices',
              style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          _applianceSwitch(
              'Safety devices operating correctly',
              appliance.safetyDevicesOk,
              (v) => setState(() => appliance.safetyDevicesOk = v)),
          _applianceSwitch(
              'Ignition functioning correctly',
              appliance.ignitionOk,
              (v) => setState(() => appliance.ignitionOk = v)),
          _applianceSwitch('Flame picture acceptable', appliance.flamePictureOk,
              (v) => setState(() => appliance.flamePictureOk = v)),

          const SizedBox(height: 8),
          const Text('Pressures & Gas Rate',
              style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _innerField('Standing pressure (mbar)',
                    appliance.standingPressureController),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _innerField('Working pressure (mbar)',
                    appliance.workingPressureController),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _innerField(
                    'Inlet pressure (mbar)', appliance.inletPressureController),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _innerField(
                    'Gas rate (kW / m³/h)', appliance.gasRateController),
              ),
            ],
          ),

          const SizedBox(height: 8),
          const Text('Combustion Analysis',
              style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _innerField('CO (ppm)', appliance.coPpmController),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _innerField('CO₂ (%)', appliance.co2PercentController),
              ),
            ],
          ),
          _innerField('CO / CO\u2082 ratio', appliance.coCo2RatioController),
          _applianceSwitch(
              'Combustion test carried out',
              appliance.combustionTestDone,
              (v) => setState(() => appliance.combustionTestDone = v)),
          _applianceSwitch(
              'Flue integrity test passed',
              appliance.flueIntegrityOk,
              (v) => setState(() => appliance.flueIntegrityOk = v)),

          const SizedBox(height: 8),
          const Text('Open-Flue Tests (if applicable)',
              style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          _applianceSwitch('Spillage test passed', appliance.spillageTestPass,
              (v) => setState(() => appliance.spillageTestPass = v)),
          _applianceSwitch('Flue flow test passed', appliance.flueFlowTestPass,
              (v) => setState(() => appliance.flueFlowTestPass = v)),

          const SizedBox(height: 8),
          _applianceSwitch(
              'Appliance safe to use',
              appliance.applianceSafeToUse,
              (v) => setState(() => appliance.applianceSafeToUse = v)),
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

  Widget _applianceSwitch(
      String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label)),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: _teal,
        ),
      ],
    );
  }

  Widget _buildTightnessCard() {
    return _card(
      title: 'System Tightness Test',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _switchRow('Tightness test carried out', tightnessTestDone,
              (v) => setState(() => tightnessTestDone = v)),
          if (tightnessTestDone) ...[
            _textField(
                label: 'Let-by result',
                controller: _letByResultController,
                required: false),
            _textField(
                label: 'Pressure drop (mbar)',
                controller: _tightnessDropController,
                required: false),
            _textField(
                label: 'Test duration (mins)',
                controller: _tightnessDurationController,
                required: false),
            _switchRow('Tightness test passed', tightnessPass,
                (v) => setState(() => tightnessPass = v)),
          ],
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

  Widget _buildServiceWorkCard() {
    return _card(
      title: 'Service Work Carried Out',
      child: Column(
        children: [
          _switchRow('Burner cleaned', burnerCleaned,
              (v) => setState(() => burnerCleaned = v)),
          _switchRow('Heat exchanger cleaned', heatExchangerCleaned,
              (v) => setState(() => heatExchangerCleaned = v)),
          _switchRow('Condensate trap cleaned', condensateTrapCleaned,
              (v) => setState(() => condensateTrapCleaned = v)),
          _switchRow('Magnetic filter cleaned', magneticFilterCleaned,
              (v) => setState(() => magneticFilterCleaned = v)),
          _switchRow('Filters cleaned', filtersCleaned,
              (v) => setState(() => filtersCleaned = v)),
          _switchRow('System pressure checked', systemPressureChecked,
              (v) => setState(() => systemPressureChecked = v)),
          _switchRow('Inhibitor level checked', inhibitorLevelChecked,
              (v) => setState(() => inhibitorLevelChecked = v)),
          _switchRow('Water quality checked', waterQualityChecked,
              (v) => setState(() => waterQualityChecked = v)),
          _switchRow(
              'Fan cleaned', fanCleaned, (v) => setState(() => fanCleaned = v)),
          _switchRow('Expansion vessel charge set', expansionVesselSet,
              (v) => setState(() => expansionVesselSet = v)),
          _switchRow('Case seals replaced where required', sealsReplaced,
              (v) => setState(() => sealsReplaced = v)),
          _switchRow('Full operational check completed', fullOperationalCheck,
              (v) => setState(() => fullOperationalCheck = v)),
        ],
      ),
    );
  }

  Widget _buildDefectsCard() {
    return _card(
      title: 'Defects / Advisory Notes',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Classification'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _classificationChip('None'),
              // _classificationChip('NCS'),
              _classificationChip('AR'),
              _classificationChip('ID'),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _defectDetailsController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Defects / unsafe situations',
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
              labelText: 'Advice given to customer',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              isDense: true,
            ),
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

  Widget _buildDatesCard() {
    return _card(
      title: 'Service Dates',
      child: Column(
        children: [
          _dateField('Service date', _serviceDateController),
          _dateField('Next service due', _nextServiceDueController),
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
          const SizedBox(height: 10.0,),
          _textField(
              label: 'Engineer name', controller: _engineerNameController),
          _textField(
              label: 'Gas Safe registration no.',
              controller: _gasSafeNumberController),
          const Divider(height: 24),
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
              label: 'Customer Signature',
              bytes: _customerSignatureBytes,
              onTap: () => _captureSignature(
                title: 'Customer',
                forEngineer: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Signature widget
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

class ServiceAppliancePlain {
  final String type;
  final String make;
  final String model;
  final String location;
  final String serialNumber;
  final String gasType;
  final String standingPressure;
  final String workingPressure;
  final String inletPressure;
  final String gasRate;
  final String coPpm;
  final String co2Percent;
  final String coCo2Ratio;
  final bool visualConditionOk;
  final bool flueConditionOk;
  final bool ventilationOk;
  final bool pipeworkOk;
  final bool sealsIntact;
  final bool noWaterLeaks;
  final bool noSignsOfDistress;
  final bool safetyDevicesOk;
  final bool ignitionOk;
  final bool flamePictureOk;
  final bool combustionTestDone;
  final bool flueIntegrityOk;
  final bool spillageTestPass;
  final bool flueFlowTestPass;
  final bool applianceSafeToUse;

  ServiceAppliancePlain({
    required this.type,
    required this.make,
    required this.model,
    required this.location,
    required this.serialNumber,
    required this.gasType,
    required this.standingPressure,
    required this.workingPressure,
    required this.inletPressure,
    required this.gasRate,
    required this.coPpm,
    required this.co2Percent,
    required this.coCo2Ratio,
    required this.visualConditionOk,
    required this.flueConditionOk,
    required this.ventilationOk,
    required this.pipeworkOk,
    required this.sealsIntact,
    required this.noWaterLeaks,
    required this.noSignsOfDistress,
    required this.safetyDevicesOk,
    required this.ignitionOk,
    required this.flamePictureOk,
    required this.combustionTestDone,
    required this.flueIntegrityOk,
    required this.spillageTestPass,
    required this.flueFlowTestPass,
    required this.applianceSafeToUse,
  });

  /// 🔥 FROM JSON (SAFE)
  factory ServiceAppliancePlain.fromJson(Map<String, dynamic> json) {
    return ServiceAppliancePlain(
      type: json['type'] ?? '',
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      location: json['location'] ?? '',
      serialNumber: json['serialNumber'] ?? '',
      gasType: json['gasType'] ?? '',
      standingPressure: json['standingPressure'] ?? '',
      workingPressure: json['workingPressure'] ?? '',
      inletPressure: json['inletPressure'] ?? '',
      gasRate: json['gasRate'] ?? '',
      coPpm: json['coPpm'] ?? '',
      co2Percent: json['co2Percent'] ?? '',
      coCo2Ratio: json['coCo2Ratio'] ?? '',
      visualConditionOk: json['visualConditionOk'] ?? false,
      flueConditionOk: json['flueConditionOk'] ?? false,
      ventilationOk: json['ventilationOk'] ?? false,
      pipeworkOk: json['pipeworkOk'] ?? false,
      sealsIntact: json['sealsIntact'] ?? false,
      noWaterLeaks: json['noWaterLeaks'] ?? false,
      noSignsOfDistress: json['noSignsOfDistress'] ?? false,
      safetyDevicesOk: json['safetyDevicesOk'] ?? false,
      ignitionOk: json['ignitionOk'] ?? false,
      flamePictureOk: json['flamePictureOk'] ?? false,
      combustionTestDone: json['combustionTestDone'] ?? false,
      flueIntegrityOk: json['flueIntegrityOk'] ?? false,
      spillageTestPass: json['spillageTestPass'] ?? false,
      flueFlowTestPass: json['flueFlowTestPass'] ?? false,
      applianceSafeToUse: json['applianceSafeToUse'] ?? false,
    );
  }

  /// 🔥 TO JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'make': make,
      'model': model,
      'location': location,
      'serialNumber': serialNumber,
      'gasType': gasType,
      'standingPressure': standingPressure,
      'workingPressure': workingPressure,
      'inletPressure': inletPressure,
      'gasRate': gasRate,
      'coPpm': coPpm,
      'co2Percent': co2Percent,
      'coCo2Ratio': coCo2Ratio,
      'visualConditionOk': visualConditionOk,
      'flueConditionOk': flueConditionOk,
      'ventilationOk': ventilationOk,
      'pipeworkOk': pipeworkOk,
      'sealsIntact': sealsIntact,
      'noWaterLeaks': noWaterLeaks,
      'noSignsOfDistress': noSignsOfDistress,
      'safetyDevicesOk': safetyDevicesOk,
      'ignitionOk': ignitionOk,
      'flamePictureOk': flamePictureOk,
      'combustionTestDone': combustionTestDone,
      'flueIntegrityOk': flueIntegrityOk,
      'spillageTestPass': spillageTestPass,
      'flueFlowTestPass': flueFlowTestPass,
      'applianceSafeToUse': applianceSafeToUse,
    };
  }
}

class ServiceApplianceData {
  final int index;
  final TextEditingController typeController;
  final TextEditingController makeController;
  final TextEditingController modelController;
  final TextEditingController locationController;
  final TextEditingController serialNumberController;
  final TextEditingController standingPressureController;
  final TextEditingController workingPressureController;
  final TextEditingController inletPressureController;
  final TextEditingController gasRateController;
  final TextEditingController coPpmController;
  final TextEditingController co2PercentController;
  final TextEditingController coCo2RatioController;

  String gasType;
  bool visualConditionOk;
  bool flueConditionOk;
  bool ventilationOk;
  bool pipeworkOk;
  bool sealsIntact;
  bool noWaterLeaks;
  bool noSignsOfDistress;
  bool safetyDevicesOk;
  bool ignitionOk;
  bool flamePictureOk;
  bool combustionTestDone;
  bool flueIntegrityOk;
  bool spillageTestPass;
  bool flueFlowTestPass;
  bool applianceSafeToUse;

  ServiceApplianceData._({
    required this.index,
    required this.typeController,
    required this.makeController,
    required this.modelController,
    required this.locationController,
    required this.serialNumberController,
    required this.standingPressureController,
    required this.workingPressureController,
    required this.inletPressureController,
    required this.gasRateController,
    required this.coPpmController,
    required this.co2PercentController,
    required this.coCo2RatioController,
    required this.gasType,
    required this.visualConditionOk,
    required this.flueConditionOk,
    required this.ventilationOk,
    required this.pipeworkOk,
    required this.sealsIntact,
    required this.noWaterLeaks,
    required this.noSignsOfDistress,
    required this.safetyDevicesOk,
    required this.ignitionOk,
    required this.flamePictureOk,
    required this.combustionTestDone,
    required this.flueIntegrityOk,
    required this.spillageTestPass,
    required this.flueFlowTestPass,
    required this.applianceSafeToUse,
  });

  factory ServiceApplianceData.empty(int index) {
    return ServiceApplianceData._(
      index: index,
      typeController: TextEditingController(),
      makeController: TextEditingController(),
      modelController: TextEditingController(),
      locationController: TextEditingController(),
      serialNumberController: TextEditingController(),
      standingPressureController: TextEditingController(),
      workingPressureController: TextEditingController(),
      inletPressureController: TextEditingController(),
      gasRateController: TextEditingController(),
      coPpmController: TextEditingController(),
      co2PercentController: TextEditingController(),
      coCo2RatioController: TextEditingController(),
      gasType: 'NG',
      visualConditionOk: true,
      flueConditionOk: true,
      ventilationOk: true,
      pipeworkOk: true,
      sealsIntact: true,
      noWaterLeaks: true,
      noSignsOfDistress: true,
      safetyDevicesOk: true,
      ignitionOk: true,
      flamePictureOk: true,
      combustionTestDone: false,
      flueIntegrityOk: true,
      spillageTestPass: true,
      flueFlowTestPass: true,
      applianceSafeToUse: true,
    );
  }

  ServiceAppliancePlain toPlain() {
    return ServiceAppliancePlain(
      type: typeController.text.trim(),
      make: makeController.text.trim(),
      model: modelController.text.trim(),
      location: locationController.text.trim(),
      serialNumber: serialNumberController.text.trim(),
      gasType: gasType,
      standingPressure: standingPressureController.text.trim(),
      workingPressure: workingPressureController.text.trim(),
      inletPressure: inletPressureController.text.trim(),
      gasRate: gasRateController.text.trim(),
      coPpm: coPpmController.text.trim(),
      co2Percent: co2PercentController.text.trim(),
      coCo2Ratio: coCo2RatioController.text.trim(),
      visualConditionOk: visualConditionOk,
      flueConditionOk: flueConditionOk,
      ventilationOk: ventilationOk,
      pipeworkOk: pipeworkOk,
      sealsIntact: sealsIntact,
      noWaterLeaks: noWaterLeaks,
      noSignsOfDistress: noSignsOfDistress,
      safetyDevicesOk: safetyDevicesOk,
      ignitionOk: ignitionOk,
      flamePictureOk: flamePictureOk,
      combustionTestDone: combustionTestDone,
      flueIntegrityOk: flueIntegrityOk,
      spillageTestPass: spillageTestPass,
      flueFlowTestPass: flueFlowTestPass,
      applianceSafeToUse: applianceSafeToUse,
    );
  }

  void dispose() {
    typeController.dispose();
    makeController.dispose();
    modelController.dispose();
    locationController.dispose();
    serialNumberController.dispose();
    standingPressureController.dispose();
    workingPressureController.dispose();
    inletPressureController.dispose();
    gasRateController.dispose();
    coPpmController.dispose();
    co2PercentController.dispose();
    coCo2RatioController.dispose();
  }

  factory ServiceApplianceData.fromPlain(
    ServiceAppliancePlain plain,
    int index,
  ) {
    return ServiceApplianceData._(
      index: index,
      typeController: TextEditingController(text: plain.type),
      makeController: TextEditingController(text: plain.make),
      modelController: TextEditingController(text: plain.model),
      locationController: TextEditingController(text: plain.location),
      serialNumberController: TextEditingController(text: plain.serialNumber),
      standingPressureController:
          TextEditingController(text: plain.standingPressure),
      workingPressureController:
          TextEditingController(text: plain.workingPressure),
      inletPressureController: TextEditingController(text: plain.inletPressure),
      gasRateController: TextEditingController(text: plain.gasRate),
      coPpmController: TextEditingController(text: plain.coPpm),
      co2PercentController: TextEditingController(text: plain.co2Percent),
      coCo2RatioController: TextEditingController(text: plain.coCo2Ratio),
      gasType: plain.gasType,
      visualConditionOk: plain.visualConditionOk,
      flueConditionOk: plain.flueConditionOk,
      ventilationOk: plain.ventilationOk,
      pipeworkOk: plain.pipeworkOk,
      sealsIntact: plain.sealsIntact,
      noWaterLeaks: plain.noWaterLeaks,
      noSignsOfDistress: plain.noSignsOfDistress,
      safetyDevicesOk: plain.safetyDevicesOk,
      ignitionOk: plain.ignitionOk,
      flamePictureOk: plain.flamePictureOk,
      combustionTestDone: plain.combustionTestDone,
      flueIntegrityOk: plain.flueIntegrityOk,
      spillageTestPass: plain.spillageTestPass,
      flueFlowTestPass: plain.flueFlowTestPass,
      applianceSafeToUse: plain.applianceSafeToUse,
    );
  }
}

class ServiceRecord {
  final String recordNumber;
  final String customerName;
  final String customerAddress;
  final String customerPostcode;
  final String customerPhone;
  final String customerEmail;

  final String propertyAddress;
  final String propertyPostcode;
  final String occupierName;

  final List<ServiceAppliancePlain> appliances;

  final String letByResult;
  final String tightnessDrop;
  final String tightnessDuration;
  final bool tightnessTestDone;
  final bool tightnessPass;

  final bool burnerCleaned;
  final bool heatExchangerCleaned;
  final bool condensateTrapCleaned;
  final bool magneticFilterCleaned;
  final bool filtersCleaned;
  final bool systemPressureChecked;
  final bool inhibitorLevelChecked;
  final bool waterQualityChecked;
  final bool fanCleaned;
  final bool expansionVesselSet;
  final bool sealsReplaced;
  final bool fullOperationalCheck;

  final String classification;
  final String defectDetails;
  final String actionTaken;
  final String adviceGiven;

  final String serviceDate;
  final String nextServiceDue;
  final String reminderDate;

  final String engineerName;
  final String gasSafeNumber;
  final String companyName;
  final String companyAddress;
  final String companyPostcode;
  final String companyPhone;
  final String companyEmail;

  final String? engineerSignatureBase64;
  final String? customerSignatureBase64;

  ServiceRecord({
    required this.recordNumber,
    required this.customerName,
    required this.customerAddress,
    required this.customerPostcode,
    required this.customerPhone,
    required this.customerEmail,
    required this.propertyAddress,
    required this.propertyPostcode,
    required this.occupierName,
    required this.appliances,
    required this.letByResult,
    required this.tightnessDrop,
    required this.tightnessDuration,
    required this.tightnessTestDone,
    required this.tightnessPass,
    required this.burnerCleaned,
    required this.heatExchangerCleaned,
    required this.condensateTrapCleaned,
    required this.magneticFilterCleaned,
    required this.filtersCleaned,
    required this.systemPressureChecked,
    required this.inhibitorLevelChecked,
    required this.waterQualityChecked,
    required this.fanCleaned,
    required this.expansionVesselSet,
    required this.sealsReplaced,
    required this.fullOperationalCheck,
    required this.classification,
    required this.defectDetails,
    required this.actionTaken,
    required this.adviceGiven,
    required this.serviceDate,
    required this.nextServiceDue,
    required this.reminderDate,
    required this.engineerName,
    required this.gasSafeNumber,
    required this.companyName,
    required this.companyAddress,
    required this.companyPostcode,
    required this.companyPhone,
    required this.companyEmail,
    required this.engineerSignatureBase64,
    required this.customerSignatureBase64,
  });

  /// 🔥 FROM JSON
  factory ServiceRecord.fromJson(Map<String, dynamic> json) {
    return ServiceRecord(
      recordNumber: json['recordNumber'] ?? '',
      customerName: json['customerName'] ?? '',
      customerAddress: json['customerAddress'] ?? '',
      customerPostcode: json['customerPostcode'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      customerEmail: json['customerEmail'] ?? '',
      propertyAddress: json['propertyAddress'] ?? '',
      propertyPostcode: json['propertyPostcode'] ?? '',
      occupierName: json['occupierName'] ?? '',
      appliances: (json['appliances'] as List?)
              ?.map((e) => ServiceAppliancePlain.fromJson(e))
              .toList() ??
          [],
      letByResult: json['letByResult'] ?? '',
      tightnessDrop: json['tightnessDrop'] ?? '',
      tightnessDuration: json['tightnessDuration'] ?? '',
      tightnessTestDone: json['tightnessTestDone'] ?? false,
      tightnessPass: json['tightnessPass'] ?? true,
      burnerCleaned: json['burnerCleaned'] ?? false,
      heatExchangerCleaned: json['heatExchangerCleaned'] ?? false,
      condensateTrapCleaned: json['condensateTrapCleaned'] ?? false,
      magneticFilterCleaned: json['magneticFilterCleaned'] ?? false,
      filtersCleaned: json['filtersCleaned'] ?? false,
      systemPressureChecked: json['systemPressureChecked'] ?? false,
      inhibitorLevelChecked: json['inhibitorLevelChecked'] ?? false,
      waterQualityChecked: json['waterQualityChecked'] ?? false,
      fanCleaned: json['fanCleaned'] ?? false,
      expansionVesselSet: json['expansionVesselSet'] ?? false,
      sealsReplaced: json['sealsReplaced'] ?? false,
      fullOperationalCheck: json['fullOperationalCheck'] ?? true,
      classification: json['classification'] ?? 'None',
      defectDetails: json['defectDetails'] ?? '',
      actionTaken: json['actionTaken'] ?? '',
      adviceGiven: json['adviceGiven'] ?? '',
      serviceDate: json['serviceDate'] ?? '',
      nextServiceDue: json['nextServiceDue'] ?? '',
      reminderDate: json['reminderDate'] ?? '',
      engineerName: json['engineerName'] ?? '',
      gasSafeNumber: json['gasSafeNumber'] ?? '',
      companyName: json['companyName'] ?? '',
      companyAddress: json['companyAddress'] ?? '',
      companyPostcode: json['companyPostcode'] ?? '',
      companyPhone: json['companyPhone'] ?? '',
      companyEmail: json['companyEmail'] ?? '',
      engineerSignatureBase64: json['engineerSignatureBase64'],
      customerSignatureBase64: json['customerSignatureBase64'],
    );
  }

  /// 🔥 TO JSON
  Map<String, dynamic> toJson() {
    return {
      'recordNumber': recordNumber,
      'customerName': customerName,
      'customerAddress': customerAddress,
      'customerPostcode': customerPostcode,
      'customerPhone': customerPhone,
      'customerEmail': customerEmail,
      'propertyAddress': propertyAddress,
      'propertyPostcode': propertyPostcode,
      'occupierName': occupierName,
      'appliances': appliances.map((a) => a.toJson()).toList(),
      'letByResult': letByResult,
      'tightnessDrop': tightnessDrop,
      'tightnessDuration': tightnessDuration,
      'tightnessTestDone': tightnessTestDone,
      'tightnessPass': tightnessPass,
      'burnerCleaned': burnerCleaned,
      'heatExchangerCleaned': heatExchangerCleaned,
      'condensateTrapCleaned': condensateTrapCleaned,
      'magneticFilterCleaned': magneticFilterCleaned,
      'filtersCleaned': filtersCleaned,
      'systemPressureChecked': systemPressureChecked,
      'inhibitorLevelChecked': inhibitorLevelChecked,
      'waterQualityChecked': waterQualityChecked,
      'fanCleaned': fanCleaned,
      'expansionVesselSet': expansionVesselSet,
      'sealsReplaced': sealsReplaced,
      'fullOperationalCheck': fullOperationalCheck,
      'classification': classification,
      'defectDetails': defectDetails,
      'actionTaken': actionTaken,
      'adviceGiven': adviceGiven,
      'serviceDate': serviceDate,
      'nextServiceDue': nextServiceDue,
      'reminderDate': reminderDate,
      'engineerName': engineerName,
      'gasSafeNumber': gasSafeNumber,
      'companyName': companyName,
      'companyAddress': companyAddress,
      'companyPostcode': companyPostcode,
      'companyPhone': companyPhone,
      'companyEmail': companyEmail,
      'engineerSignatureBase64': engineerSignatureBase64,
      'customerSignatureBase64': customerSignatureBase64,
    };
  }
}
