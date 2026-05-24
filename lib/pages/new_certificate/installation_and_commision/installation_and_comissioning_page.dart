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

class InstallationCommissioningPage extends StatefulWidget {

  final InstallationCommissioningRecord? record;
  const InstallationCommissioningPage({super.key,this.record});

  @override
  State<InstallationCommissioningPage> createState() =>
      _InstallationCommissioningPageState();
}

class _InstallationCommissioningPageState
    extends State<InstallationCommissioningPage> {
  static const Color _teal = Color(0xFF4F7F7F);
  static const Color _cardBg = Color(0xFFF3F7F7);

  final _formKey = GlobalKey<FormState>();

  // Record info
  final _certificateNumberController =
  TextEditingController(text: 'IC-00001');

  // Customer / property
  final _customerNameController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _customerPostcodeController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerEmailController = TextEditingController();

  final _propertyAddressController = TextEditingController();
  final _propertyPostcodeController = TextEditingController();
  final _occupierNameController = TextEditingController();

  // Appliance (single)
  final _applianceTypeController = TextEditingController();
  final _applianceMakeController = TextEditingController();
  final _applianceModelController = TextEditingController();
  final _applianceSerialController = TextEditingController();
  final _applianceLocationController = TextEditingController();
  String _gasType = 'NG'; // NG / LPG / Other
  String _flueType = 'Room-sealed'; // Room-sealed / Open / Balanced

  // Gas supply & pipework
  final _pipeSizeController = TextEditingController();
  final _standingPressureController = TextEditingController();
  final _workingPressureMeterController = TextEditingController();
  final _workingPressureApplianceController = TextEditingController();
  bool _ecvAccessible = true;
  bool _ecvLabelled = true;
  bool _pipeworkSupported = true;
  bool _bondingChecked = true;

  // Ventilation
  final _requiredVentController = TextEditingController();
  final _actualVentController = TextEditingController();
  bool _ventAdequate = true;

  // Water/system commissioning
  bool _systemFlushed = true;
  String _flushMethod = 'Powerflush'; // Powerflush / Chemical / Other
  bool _inhibitorAdded = true;
  bool _magneticFilterInstalled = true;
  bool _waterSampleTaken = false;
  final _systemPressureColdController = TextEditingController();
  final _systemPressureHotController = TextEditingController();
  bool _expansionVesselChecked = true;
  bool _prvTested = true;
  bool _condensateCompliant = true;

  // Combustion analysis (high & low)
  final _coHighController = TextEditingController();
  final _co2HighController = TextEditingController();
  final _coCo2HighController = TextEditingController();
  final _coLowController = TextEditingController();
  final _co2LowController = TextEditingController();
  final _coCo2LowController = TextEditingController();
  String _applianceSetAt = 'Auto'; // High / Low / Auto
  bool _flueIntegrityTestDone = true;
  bool _samplingPointPresent = true;
  bool _caseSealsIntact = true;

  // Safety devices
  bool _flameSafetyOk = true;
  bool _overheatStatOk = true;
  bool _fanOk = true;
  bool _prvOk = true;
  bool _condensateTrapOk = true;
  bool _polarityCorrect = true;
  bool _earthContinuityOk = true;

  // Tightness test
  bool _tightnessDone = true;
  final _stabilisationTimeController = TextEditingController();
  final _testPressureController = TextEditingController();
  final _endPressureController = TextEditingController();
  final _pressureDropController = TextEditingController();
  bool _tightnessPass = true;

  // Commissioning checks
  bool _cleanedBeforeCommissioning = true;
  bool _burnerPressureChecked = true;
  bool _gasRateMeasured = true;
  bool _condensateDisposalCorrect = true;
  bool _flueGuardRequired = false;
  bool _flueGuardFitted = false;
  bool _benchmarkCompleted = true;
  bool _handoverCompleted = true;

  // Final assessment
  bool _applianceSafeToUse = true;
  bool _meetsManufacturerInstructions = true;
  bool _meetsGasSafeRequirements = true;

  // User handover
  bool _userShownControls = true;
  bool _userShownTopUp = true;
  bool _userShownIsolate = true;
  bool _warrantyExplained = true;
  bool _serviceScheduleExplained = true;

  // Dates
  final _installDateController = TextEditingController();
  final _commissionDateController = TextEditingController();
  final _nextServiceDueController = TextEditingController();

  // Engineer/company
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
    Future.delayed(Duration.zero,(){
      setCompanyDetails();
       if(widget.record != null){
         setData(widget.record!);
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
    final String? data = prefs.getString('latest_install_commission_record');

    if (data == null) {
      return "IC-00001"; // first record
    }

    final List decoded = jsonDecode(data);

    if (decoded.isEmpty) {
      return "IC-00001";
    }

    /// 🔥 Get last record
    final last = decoded.last;

    final lastNumberStr = last['certificateNumber'] ?? "IC-00000";

    /// Extract numeric part
    final numberPart = lastNumberStr.toString().replaceAll("IC-", "");

    int number = int.tryParse(numberPart) ?? 0;

    number++; // increment

    /// Format with leading zeros
    final newNumber = number.toString().padLeft(5, '0');
    _certificateNumberController.text = "IC-"+newNumber;

    return "IC-$newNumber";
  }



  void setData(InstallationCommissioningRecord record) {
    setState(() {
      // Certificate
      _certificateNumberController.text = record.certificateNumber;

      // Customer / property
      _customerNameController.text = record.customerName ?? '';
      _customerAddressController.text = record.customerAddress ?? '';
      _customerPostcodeController.text = record.customerPostcode ?? '';
      _customerPhoneController.text = record.customerPhone ?? '';
      _customerEmailController.text = record.customerEmail ?? '';

      _propertyAddressController.text = record.propertyAddress ?? '';
      _propertyPostcodeController.text = record.propertyPostcode ?? '';
      _occupierNameController.text = record.occupierName ?? '';

      // Appliance
      _applianceTypeController.text = record.applianceType ?? '';
      _applianceMakeController.text = record.applianceMake ?? '';
      _applianceModelController.text = record.applianceModel ?? '';
      _applianceSerialController.text = record.applianceSerial ?? '';
      _applianceLocationController.text = record.applianceLocation ?? '';

      _gasType = record.gasType ?? 'NG';
      _flueType = record.flueType ?? 'Room-sealed';

      // Gas supply
      _pipeSizeController.text = record.pipeSize ?? '';
      _standingPressureController.text = record.standingPressure ?? '';
      _workingPressureMeterController.text =
          record.workingPressureMeter ?? '';
      _workingPressureApplianceController.text =
          record.workingPressureAppliance ?? '';

      _ecvAccessible = record.ecvAccessible ?? true;
      _ecvLabelled = record.ecvLabelled ?? true;
      _pipeworkSupported = record.pipeworkSupported ?? true;
      _bondingChecked = record.bondingChecked ?? true;

      // Ventilation
      _requiredVentController.text = record.requiredVent ?? '';
      _actualVentController.text = record.actualVent ?? '';
      _ventAdequate = record.ventAdequate ?? true;

      // System
      _systemFlushed = record.systemFlushed ?? true;
      _flushMethod = record.flushMethod ?? 'Powerflush';
      _inhibitorAdded = record.inhibitorAdded ?? true;
      _magneticFilterInstalled = record.magneticFilterInstalled ?? true;
      _waterSampleTaken = record.waterSampleTaken ?? false;

      _systemPressureColdController.text = record.systemPressureCold ?? '';
      _systemPressureHotController.text = record.systemPressureHot ?? '';

      _expansionVesselChecked = record.expansionVesselChecked ?? true;
      _prvTested = record.prvTested ?? true;
      _condensateCompliant = record.condensateCompliant ?? true;

      // Combustion
      _coHighController.text = record.coHigh ?? '';
      _co2HighController.text = record.co2High ?? '';
      _coCo2HighController.text = record.coCo2High ?? '';

      _coLowController.text = record.coLow ?? '';
      _co2LowController.text = record.co2Low ?? '';
      _coCo2LowController.text = record.coCo2Low ?? '';

      _applianceSetAt = record.applianceSetAt ?? 'Auto';

      _flueIntegrityTestDone = record.flueIntegrityTestDone ?? true;
      _samplingPointPresent = record.samplingPointPresent ?? true;
      _caseSealsIntact = record.caseSealsIntact ?? true;

      // Safety
      _flameSafetyOk = record.flameSafetyOk ?? true;
      _overheatStatOk = record.overheatStatOk ?? true;
      _fanOk = record.fanOk ?? true;
      _prvOk = record.prvOk ?? true;
      _condensateTrapOk = record.condensateTrapOk ?? true;

      _polarityCorrect = record.polarityCorrect ?? true;
      _earthContinuityOk = record.earthContinuityOk ?? true;

      // Tightness
      _tightnessDone = record.tightnessDone ?? true;
      _stabilisationTimeController.text =
          record.stabilisationTime ?? '';
      _testPressureController.text = record.testPressure ?? '';
      _endPressureController.text = record.endPressure ?? '';
      _pressureDropController.text = record.pressureDrop ?? '';
      _tightnessPass = record.tightnessPass ?? true;

      // Commissioning
      _cleanedBeforeCommissioning =
          record.cleanedBeforeCommissioning ?? true;
      _burnerPressureChecked = record.burnerPressureChecked ?? true;
      _gasRateMeasured = record.gasRateMeasured ?? true;

      _condensateDisposalCorrect =
          record.condensateDisposalCorrect ?? true;
      _flueGuardRequired = record.flueGuardRequired ?? false;
      _flueGuardFitted = record.flueGuardFitted ?? false;

      _benchmarkCompleted = record.benchmarkCompleted ?? true;
      _handoverCompleted = record.handoverCompleted ?? true;

      // Final
      _applianceSafeToUse = record.applianceSafeToUse ?? true;
      _meetsManufacturerInstructions =
          record.meetsManufacturerInstructions ?? true;
      _meetsGasSafeRequirements =
          record.meetsGasSafeRequirements ?? true;

      // User handover
      _userShownControls = record.userShownControls ?? true;
      _userShownTopUp = record.userShownTopUp ?? true;
      _userShownIsolate = record.userShownIsolate ?? true;

      _warrantyExplained = record.warrantyExplained ?? true;
      _serviceScheduleExplained =
          record.serviceScheduleExplained ?? true;

      // Dates
      _installDateController.text = record.installDate ?? '';
      _commissionDateController.text = record.commissionDate ?? '';
      _nextServiceDueController.text = record.nextServiceDue ?? '';

      // Engineer
      _engineerNameController.text = record.engineerName ?? '';
      _gasSafeNumberController.text = record.gasSafeNumber ?? '';
      _companyNameController.text = record.companyName ?? '';
      _companyAddressController.text = record.companyAddress ?? '';
      _companyPostcodeController.text = record.companyPostcode ?? '';
      _companyPhoneController.text = record.companyPhone ?? '';
      _companyEmailController.text = record.companyEmail ?? '';

      // Signatures
      _engineerSignatureBytes = record.engineerSignatureBase64 != null
          ? base64Decode(record.engineerSignatureBase64!)
          : null;

      _customerSignatureBytes = record.customerSignatureBase64 != null
          ? base64Decode(record.customerSignatureBase64!)
          : null;
    });
    setState(() {

    });
  }

  @override
  void dispose() {
    _certificateNumberController.dispose();
    _customerNameController.dispose();
    _customerAddressController.dispose();
    _customerPostcodeController.dispose();
    _customerPhoneController.dispose();
    _customerEmailController.dispose();
    _propertyAddressController.dispose();
    _propertyPostcodeController.dispose();
    _occupierNameController.dispose();
    _applianceTypeController.dispose();
    _applianceMakeController.dispose();
    _applianceModelController.dispose();
    _applianceSerialController.dispose();
    _applianceLocationController.dispose();
    _pipeSizeController.dispose();
    _standingPressureController.dispose();
    _workingPressureMeterController.dispose();
    _workingPressureApplianceController.dispose();
    _requiredVentController.dispose();
    _actualVentController.dispose();
    _systemPressureColdController.dispose();
    _systemPressureHotController.dispose();
    _coHighController.dispose();
    _co2HighController.dispose();
    _coCo2HighController.dispose();
    _coLowController.dispose();
    _co2LowController.dispose();
    _coCo2LowController.dispose();
    _stabilisationTimeController.dispose();
    _testPressureController.dispose();
    _endPressureController.dispose();
    _pressureDropController.dispose();
    _installDateController.dispose();
    _commissionDateController.dispose();
    _nextServiceDueController.dispose();
    _engineerNameController.dispose();
    _gasSafeNumberController.dispose();
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _companyPostcodeController.dispose();
    _companyPhoneController.dispose();
    _companyEmailController.dispose();
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
    final String? data =
    prefs.getString('latest_install_commission_record');

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
    await prefs.setString(
      'latest_install_commission_record',
      jsonEncode(list),
    );

    if (mounted) {
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
  }

  InstallationCommissioningRecord _buildRecord() {
    return InstallationCommissioningRecord(
      certificateNumber: _certificateNumberController.text.trim(),
      customerName: _customerNameController.text.trim(),
      customerAddress: _customerAddressController.text.trim(),
      customerPostcode: _customerPostcodeController.text.trim(),
      customerPhone: _customerPhoneController.text.trim(),
      customerEmail: _customerEmailController.text.trim(),
      propertyAddress: _propertyAddressController.text.trim(),
      propertyPostcode: _propertyPostcodeController.text.trim(),
      occupierName: _occupierNameController.text.trim(),
      applianceType: _applianceTypeController.text.trim(),
      applianceMake: _applianceMakeController.text.trim(),
      applianceModel: _applianceModelController.text.trim(),
      applianceSerial: _applianceSerialController.text.trim(),
      applianceLocation: _applianceLocationController.text.trim(),
      gasType: _gasType,
      flueType: _flueType,
      pipeSize: _pipeSizeController.text.trim(),
      standingPressure: _standingPressureController.text.trim(),
      workingPressureMeter: _workingPressureMeterController.text.trim(),
      workingPressureAppliance: _workingPressureApplianceController.text.trim(),
      ecvAccessible: _ecvAccessible,
      ecvLabelled: _ecvLabelled,
      pipeworkSupported: _pipeworkSupported,
      bondingChecked: _bondingChecked,
      requiredVent: _requiredVentController.text.trim(),
      actualVent: _actualVentController.text.trim(),
      ventAdequate: _ventAdequate,
      systemFlushed: _systemFlushed,
      flushMethod: _flushMethod,
      inhibitorAdded: _inhibitorAdded,
      magneticFilterInstalled: _magneticFilterInstalled,
      waterSampleTaken: _waterSampleTaken,
      systemPressureCold: _systemPressureColdController.text.trim(),
      systemPressureHot: _systemPressureHotController.text.trim(),
      expansionVesselChecked: _expansionVesselChecked,
      prvTested: _prvTested,
      condensateCompliant: _condensateCompliant,
      coHigh: _coHighController.text.trim(),
      co2High: _co2HighController.text.trim(),
      coCo2High: _coCo2HighController.text.trim(),
      coLow: _coLowController.text.trim(),
      co2Low: _co2LowController.text.trim(),
      coCo2Low: _coCo2LowController.text.trim(),
      applianceSetAt: _applianceSetAt,
      flueIntegrityTestDone: _flueIntegrityTestDone,
      samplingPointPresent: _samplingPointPresent,
      caseSealsIntact: _caseSealsIntact,
      flameSafetyOk: _flameSafetyOk,
      overheatStatOk: _overheatStatOk,
      fanOk: _fanOk,
      prvOk: _prvOk,
      condensateTrapOk: _condensateTrapOk,
      polarityCorrect: _polarityCorrect,
      earthContinuityOk: _earthContinuityOk,
      tightnessDone: _tightnessDone,
      stabilisationTime: _stabilisationTimeController.text.trim(),
      testPressure: _testPressureController.text.trim(),
      endPressure: _endPressureController.text.trim(),
      pressureDrop: _pressureDropController.text.trim(),
      tightnessPass: _tightnessPass,
      cleanedBeforeCommissioning: _cleanedBeforeCommissioning,
      burnerPressureChecked: _burnerPressureChecked,
      gasRateMeasured: _gasRateMeasured,
      condensateDisposalCorrect: _condensateDisposalCorrect,
      flueGuardRequired: _flueGuardRequired,
      flueGuardFitted: _flueGuardFitted,
      benchmarkCompleted: _benchmarkCompleted,
      handoverCompleted: _handoverCompleted,
      applianceSafeToUse: _applianceSafeToUse,
      meetsManufacturerInstructions: _meetsManufacturerInstructions,
      meetsGasSafeRequirements: _meetsGasSafeRequirements,
      userShownControls: _userShownControls,
      userShownTopUp: _userShownTopUp,
      userShownIsolate: _userShownIsolate,
      warrantyExplained: _warrantyExplained,
      serviceScheduleExplained: _serviceScheduleExplained,
      installDate: _installDateController.text.trim(),
      commissionDate: _commissionDateController.text.trim(),
      nextServiceDue: _nextServiceDueController.text.trim(),
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

  Future<Uint8List> _generatePdfBytes(
      InstallationCommissioningRecord record) async {
   final pdf = AppPdfDocument();

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

    pw.Widget boolRow(String label, bool value) {
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(value ? 'Yes' : 'No'),
        ],
      );
    }

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
            'Gas Appliance Installation & Commissioning Certificate',
            style: pw.TextStyle(
                fontSize: 18, fontWeight: pw.FontWeight.bold),
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
          pw.Text('Certificate #: ${record.certificateNumber}'),
          pw.SizedBox(height: 16),

          // Customer / property
          pw.Text('Customer Details',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(record.customerName),
          pw.Text(record.customerAddress),
          pw.Text(record.customerPostcode),
          pw.Text('Phone: ${record.customerPhone}'),
          pw.Text('Email: ${record.customerEmail}'),
          pw.SizedBox(height: 10),

          pw.Text('Property Details',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('Occupier: ${record.occupierName}'),
          pw.Text(record.propertyAddress),
          pw.Text(record.propertyPostcode),
          pw.SizedBox(height: 12),

          // Appliance
          pw.Text('Appliance Installed',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(
              '${record.applianceType} – ${record.applianceMake} ${record.applianceModel}'),
          pw.Text('Serial: ${record.applianceSerial}'),
          pw.Text('Location: ${record.applianceLocation}'),
          pw.Text('Gas type: ${record.gasType}'),
          pw.Text('Flue type: ${record.flueType}'),
          pw.SizedBox(height: 12),

          // Gas supply & pipework
          pw.Text('Gas Supply & Pipework',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('Pipe size from meter to appliance: ${record.pipeSize}'),
          pw.Text('Standing pressure: ${record.standingPressure} mbar'),
          pw.Text(
              'Working pressure at meter: ${record.workingPressureMeter} mbar'),
          pw.Text(
              'Working pressure at appliance: ${record.workingPressureAppliance} mbar'),
          boolRow('ECV accessible', record.ecvAccessible),
          boolRow('ECV labelled', record.ecvLabelled),
          boolRow('Pipework adequately supported', record.pipeworkSupported),
          boolRow('Bonding checked', record.bondingChecked),
          pw.SizedBox(height: 12),

          // Ventilation
          pw.Text('Ventilation',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('Required: ${record.requiredVent}'),
          pw.Text('Actual: ${record.actualVent}'),
          boolRow('Ventilation adequate', record.ventAdequate),
          pw.SizedBox(height: 12),

          // Water/system commissioning
          pw.Text('Water/System Commissioning (BS 7593)',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          boolRow('System flushed', record.systemFlushed),
          pw.Text('Flush method: ${record.flushMethod}'),
          boolRow('Inhibitor added', record.inhibitorAdded),
          boolRow('Magnetic filter installed', record.magneticFilterInstalled),
          boolRow('Water sample taken', record.waterSampleTaken),
          pw.Text('System pressure (cold): ${record.systemPressureCold}'),
          pw.Text('System pressure (hot): ${record.systemPressureHot}'),
          boolRow('Expansion vessel checked', record.expansionVesselChecked),
          boolRow('PRV tested', record.prvTested),
          boolRow('Condensate run compliant', record.condensateCompliant),
          pw.SizedBox(height: 12),

          // Combustion
          pw.Text('Combustion Analysis',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(
              'HIGH rate: CO ${record.coHigh} ppm, CO₂ ${record.co2High} %, CO/CO₂ ${record.coCo2High}'),
          pw.Text(
              'LOW rate: CO ${record.coLow} ppm, CO₂ ${record.co2Low} %, CO/CO₂ ${record.coCo2Low}'),
          pw.Text('Appliance left set at: ${record.applianceSetAt}'),
          boolRow('Flue integrity test done', record.flueIntegrityTestDone),
          boolRow('Sampling point present', record.samplingPointPresent),
          boolRow('Case seals intact', record.caseSealsIntact),
          pw.SizedBox(height: 12),

          // Safety devices
          pw.Text('Safety Devices & Electrical Checks',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          boolRow('Flame safety device operational', record.flameSafetyOk),
          boolRow('Overheat thermostat operational', record.overheatStatOk),
          boolRow('Fan operating correctly', record.fanOk),
          boolRow('Pressure relief valve operational', record.prvOk),
          boolRow('Condensate trap checked', record.condensateTrapOk),
          boolRow('Polarity correct', record.polarityCorrect),
          boolRow('Earth continuity OK', record.earthContinuityOk),
          pw.SizedBox(height: 12),

          // Tightness
          pw.Text('Tightness Test (Post Installation)',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          boolRow('Tightness test carried out', record.tightnessDone),
          if (record.tightnessDone) ...[
            pw.Text(
                'Stabilisation time: ${record.stabilisationTime}   Test pressure: ${record.testPressure}'),
            pw.Text(
                'End pressure: ${record.endPressure}   Pressure drop: ${record.pressureDrop}'),
            boolRow('Tightness test passed', record.tightnessPass),
          ],
          pw.SizedBox(height: 12),

          // Commissioning checks
          pw.Text('Commissioning Checks',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          boolRow('Appliance cleaned before commissioning',
              record.cleanedBeforeCommissioning),
          boolRow('Burner pressure checked', record.burnerPressureChecked),
          boolRow('Gas rate measured', record.gasRateMeasured),
          boolRow('Condensate disposal correct',
              record.condensateDisposalCorrect),
          boolRow('Flue guard required', record.flueGuardRequired),
          boolRow('Flue guard fitted', record.flueGuardFitted),
          boolRow('Benchmark completed', record.benchmarkCompleted),
          boolRow('Handover completed', record.handoverCompleted),
          pw.SizedBox(height: 12),

          // Final assessment
          pw.Text('Final Assessment',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          boolRow('Appliance safe to use', record.applianceSafeToUse),
          boolRow('Meets manufacturer instructions',
              record.meetsManufacturerInstructions),
          boolRow('Meets Gas Safe requirements',
              record.meetsGasSafeRequirements),
          pw.SizedBox(height: 12),

          // Handover
          pw.Text('User Handover',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          boolRow('User shown controls', record.userShownControls),
          boolRow('User shown system top-up', record.userShownTopUp),
          boolRow('User shown how to isolate', record.userShownIsolate),
          boolRow('Warranty explained', record.warrantyExplained),
          boolRow('Service schedule explained',
              record.serviceScheduleExplained),
          pw.SizedBox(height: 12),

          // Dates
          pw.Text('Dates',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text('Installation date: ${record.installDate}'),
          pw.Text('Commissioning date: ${record.commissionDate}'),
          pw.Text('Next service due: ${record.nextServiceDue}'),
          pw.SizedBox(height: 12),

          // Engineer details
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

  Future<File> _writePdfToTempFile(Uint8List bytes,
      {String fileName = 'installation_commissioning.pdf'}) async {
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
      subject:
      'Installation & Commissioning Certificate ${record.certificateNumber}',
      text:
      'Please find attached the installation & commissioning certificate for ${record.propertyAddress}.',
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
        title: const Text('Installation & Commissioning'),
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
                  controller: _certificateNumberController,
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
              _buildApplianceCard(),
              const SizedBox(height: 12),
              _buildGasSupplyCard(),
              const SizedBox(height: 12),
              _buildVentilationCard(),
              const SizedBox(height: 12),
              _buildWaterSystemCard(),
              const SizedBox(height: 12),
              _buildCombustionCard(),
              const SizedBox(height: 12),
              _buildSafetyCard(),
              const SizedBox(height: 12),
              _buildTightnessCard(),
              const SizedBox(height: 12),
              _buildCommissioningChecksCard(),
              const SizedBox(height: 12),
              _buildFinalAssessmentCard(),
              const SizedBox(height: 12),
              _buildHandoverCard(),
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _buildApplianceCard() {
    return _card(
      title: 'Appliance Installed',
      child: Column(
        children: [
          _textField(label: 'Appliance type', controller: _applianceTypeController),
          _textField(label: 'Make', controller: _applianceMakeController),
          _textField(label: 'Model', controller: _applianceModelController),
          _textField(label: 'Serial number', controller: _applianceSerialController),
          _textField(label: 'Location', controller: _applianceLocationController),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _gasType,
                  decoration: InputDecoration(
                    labelText: 'Gas type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'NG', child: Text('Natural Gas')),
                    DropdownMenuItem(value: 'LPG', child: Text('LPG')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (v) {
                    setState(() => _gasType = v ?? 'NG');
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _flueType,
                  decoration: InputDecoration(
                    labelText: 'Flue type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'Room-sealed', child: Text('Room-sealed')),
                    DropdownMenuItem(value: 'Open flue', child: Text('Open')),
                    DropdownMenuItem(
                        value: 'Balanced flue', child: Text('Balanced')),
                  ],
                  onChanged: (v) {
                    setState(() => _flueType = v ?? 'Room-sealed');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGasSupplyCard() {
    return _card(
      title: 'Gas Supply & Pipework',
      child: Column(
        children: [
          _textField(
              label: 'Pipe size (meter to appliance)',
              controller: _pipeSizeController),
          _textField(
              label: 'Standing pressure (mbar)',
              controller: _standingPressureController),
          Row(
            children: [
              Expanded(
                child: _textField(
                    label: 'Working pressure at meter (mbar)',
                    controller: _workingPressureMeterController),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _textField(
                    label: 'Working pressure at appliance (mbar)',
                    controller: _workingPressureApplianceController),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _switchRow('ECV accessible', _ecvAccessible,
                  (v) => setState(() => _ecvAccessible = v)),
          _switchRow('ECV labelled', _ecvLabelled,
                  (v) => setState(() => _ecvLabelled = v)),
          _switchRow('Pipework adequately supported', _pipeworkSupported,
                  (v) => setState(() => _pipeworkSupported = v)),
          _switchRow('Bonding checked', _bondingChecked,
                  (v) => setState(() => _bondingChecked = v)),
        ],
      ),
    );
  }

  Widget _buildVentilationCard() {
    return _card(
      title: 'Ventilation',
      child: Column(
        children: [
          _textField(
              label: 'Required ventilation',
              controller: _requiredVentController,
              required: false),
          _textField(
              label: 'Actual ventilation',
              controller: _actualVentController,
              required: false),
          _switchRow('Ventilation adequate', _ventAdequate,
                  (v) => setState(() => _ventAdequate = v)),
        ],
      ),
    );
  }

  Widget _buildWaterSystemCard() {
    return _card(
      title: 'Water / System Commissioning (BS 7593)',
      child: Column(
        children: [
          _switchRow('System flushed', _systemFlushed,
                  (v) => setState(() => _systemFlushed = v)),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _flushMethod,
                  decoration: InputDecoration(
                    labelText: 'Flush method',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'Powerflush', child: Text('Powerflush')),
                    DropdownMenuItem(
                        value: 'Chemical flush',
                        child: Text('Chemical flush')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (v) {
                    setState(() => _flushMethod = v ?? 'Powerflush');
                  },
                ),
              ),
            ],
          ),
          _switchRow('Inhibitor added', _inhibitorAdded,
                  (v) => setState(() => _inhibitorAdded = v)),
          _switchRow('Magnetic filter installed', _magneticFilterInstalled,
                  (v) => setState(() => _magneticFilterInstalled = v)),
          _switchRow('Water sample taken', _waterSampleTaken,
                  (v) => setState(() => _waterSampleTaken = v)),
          Row(
            children: [
              Expanded(
                child: _textField(
                    label: 'System pressure cold (bar)',
                    controller: _systemPressureColdController,
                    required: false),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _textField(
                    label: 'System pressure hot (bar)',
                    controller: _systemPressureHotController,
                    required: false),
              ),
            ],
          ),
          _switchRow('Expansion vessel checked', _expansionVesselChecked,
                  (v) => setState(() => _expansionVesselChecked = v)),
          _switchRow('PRV tested', _prvTested,
                  (v) => setState(() => _prvTested = v)),
          _switchRow('Condensate run compliant', _condensateCompliant,
                  (v) => setState(() => _condensateCompliant = v)),
        ],
      ),
    );
  }

  Widget _buildCombustionCard() {
    return _card(
      title: 'Combustion Analysis',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('High rate readings',
              style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _textField(
                    label: 'CO (ppm)', controller: _coHighController),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _textField(
                    label: 'CO₂ (%)', controller: _co2HighController),
              ),
            ],
          ),
          _textField(
              label: 'CO / CO\u2082 ratio',
              controller: _coCo2HighController),
          const SizedBox(height: 8),
          const Text('Low rate readings',
              style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _textField(
                    label: 'CO (ppm)', controller: _coLowController),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _textField(
                    label: 'CO₂ (%)', controller: _co2LowController),
              ),
            ],
          ),
          _textField(
              label: 'CO / CO\u2082 ratio',
              controller: _coCo2LowController),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _applianceSetAt,
            decoration: InputDecoration(
              labelText: 'Appliance left set at',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              isDense: true,
            ),
            items: const [
              DropdownMenuItem(value: 'High', child: Text('High')),
              DropdownMenuItem(value: 'Low', child: Text('Low')),
              DropdownMenuItem(value: 'Auto', child: Text('Auto')),
            ],
            onChanged: (v) {
              setState(() => _applianceSetAt = v ?? 'Auto');
            },
          ),
          const SizedBox(height: 8),
          _switchRow('Flue integrity test done', _flueIntegrityTestDone,
                  (v) => setState(() => _flueIntegrityTestDone = v)),
          _switchRow('Sampling point present', _samplingPointPresent,
                  (v) => setState(() => _samplingPointPresent = v)),
          _switchRow('Case seals intact', _caseSealsIntact,
                  (v) => setState(() => _caseSealsIntact = v)),
        ],
      ),
    );
  }

  Widget _buildSafetyCard() {
    return _card(
      title: 'Safety Devices & Electrical Checks',
      child: Column(
        children: [
          _switchRow('Flame safety device operational', _flameSafetyOk,
                  (v) => setState(() => _flameSafetyOk = v)),
          _switchRow('Overheat thermostat operational', _overheatStatOk,
                  (v) => setState(() => _overheatStatOk = v)),
          _switchRow('Fan operating correctly', _fanOk,
                  (v) => setState(() => _fanOk = v)),
          _switchRow('Pressure relief valve operational', _prvOk,
                  (v) => setState(() => _prvOk = v)),
          _switchRow('Condensate trap checked', _condensateTrapOk,
                  (v) => setState(() => _condensateTrapOk = v)),
          _switchRow('Polarity correct', _polarityCorrect,
                  (v) => setState(() => _polarityCorrect = v)),
          _switchRow('Earth continuity OK', _earthContinuityOk,
                  (v) => setState(() => _earthContinuityOk = v)),
        ],
      ),
    );
  }

  Widget _buildTightnessCard() {
    return _card(
      title: 'Tightness Test (Post Installation)',
      child: Column(
        children: [
          _switchRow('Tightness test carried out', _tightnessDone,
                  (v) => setState(() => _tightnessDone = v)),
          if (_tightnessDone) ...[
            _textField(
                label: 'Stabilisation time (mins)',
                controller: _stabilisationTimeController,
                required: false),
            _textField(
                label: 'Test pressure',
                controller: _testPressureController,
                required: false),
            _textField(
                label: 'End pressure',
                controller: _endPressureController,
                required: false),
            _textField(
                label: 'Pressure drop',
                controller: _pressureDropController,
                required: false),
            _switchRow('Tightness test passed', _tightnessPass,
                    (v) => setState(() => _tightnessPass = v)),
          ],
        ],
      ),
    );
  }

  Widget _buildCommissioningChecksCard() {
    return _card(
      title: 'Commissioning Checks',
      child: Column(
        children: [
          _switchRow('Appliance cleaned before commissioning',
              _cleanedBeforeCommissioning,
                  (v) => setState(() => _cleanedBeforeCommissioning = v)),
          _switchRow('Burner pressure checked', _burnerPressureChecked,
                  (v) => setState(() => _burnerPressureChecked = v)),
          _switchRow('Gas rate measured', _gasRateMeasured,
                  (v) => setState(() => _gasRateMeasured = v)),
          _switchRow('Condensate disposal correct',
              _condensateDisposalCorrect,
                  (v) => setState(() => _condensateDisposalCorrect = v)),
          _switchRow('Flue guard required', _flueGuardRequired,
                  (v) => setState(() => _flueGuardRequired = v)),
          _switchRow('Flue guard fitted', _flueGuardFitted,
                  (v) => setState(() => _flueGuardFitted = v)),
          _switchRow('Benchmark completed', _benchmarkCompleted,
                  (v) => setState(() => _benchmarkCompleted = v)),
          _switchRow('Handover completed', _handoverCompleted,
                  (v) => setState(() => _handoverCompleted = v)),
        ],
      ),
    );
  }

  Widget _buildFinalAssessmentCard() {
    return _card(
      title: 'Final Assessment',
      child: Column(
        children: [
          _switchRow('Appliance safe to use', _applianceSafeToUse,
                  (v) => setState(() => _applianceSafeToUse = v)),
          _switchRow('Meets manufacturer instructions',
              _meetsManufacturerInstructions,
                  (v) => setState(() => _meetsManufacturerInstructions = v)),
          _switchRow('Meets Gas Safe requirements',
              _meetsGasSafeRequirements,
                  (v) => setState(() => _meetsGasSafeRequirements = v)),
        ],
      ),
    );
  }

  Widget _buildHandoverCard() {
    return _card(
      title: 'User Handover',
      child: Column(
        children: [
          _switchRow('User shown how to use controls', _userShownControls,
                  (v) => setState(() => _userShownControls = v)),
          _switchRow('User shown how to top up system', _userShownTopUp,
                  (v) => setState(() => _userShownTopUp = v)),
          _switchRow('User shown how to isolate appliance',
              _userShownIsolate,
                  (v) => setState(() => _userShownIsolate = v)),
          _switchRow('Warranty registration explained', _warrantyExplained,
                  (v) => setState(() => _warrantyExplained = v)),
          _switchRow('Service schedule explained',
              _serviceScheduleExplained,
                  (v) => setState(() => _serviceScheduleExplained = v)),
        ],
      ),
    );
  }

  Widget _buildDatesCard() {
    return _card(
      title: 'Dates',
      child: Column(
        children: [
          _dateField('Installation date', _installDateController),
          _dateField('Commissioning date', _commissionDateController),
          _dateField('Next service due', _nextServiceDueController),
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
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          isDense: true,
        ),
        onTap: () => _pickDate(controller),
        validator: (v) =>
        (v == null || v.isEmpty) ? 'Required' : null,
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
              label: 'Engineer name',
              controller: _engineerNameController),
          _textField(
              label: 'Gas Safe registration no.',
              controller: _gasSafeNumberController),
          const Divider(height: 24),
          _textField(
              label: 'Company name',
              controller: _companyNameController),
          _textField(
              label: 'Company address',
              controller: _companyAddressController),
          _textField(
              label: 'Postcode',
              controller: _companyPostcodeController),
          _textField(
              label: 'Phone', controller: _companyPhoneController),
          _textField(
              label: 'Email', controller: _companyEmailController),
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

  Widget _switchRow(
      String label, bool value, ValueChanged<bool> onChanged) {
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
                style:
                TextStyle(fontSize: 12, color: Colors.black54),
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
// Data model
// ---------------------------------------------------------------------------

class InstallationCommissioningRecord {
  final String certificateNumber;
  final String customerName;
  final String customerAddress;
  final String customerPostcode;
  final String customerPhone;
  final String customerEmail;

  final String propertyAddress;
  final String propertyPostcode;
  final String occupierName;

  final String applianceType;
  final String applianceMake;
  final String applianceModel;
  final String applianceSerial;
  final String applianceLocation;
  final String gasType;
  final String flueType;

  final String pipeSize;
  final String standingPressure;
  final String workingPressureMeter;
  final String workingPressureAppliance;
  final bool ecvAccessible;
  final bool ecvLabelled;
  final bool pipeworkSupported;
  final bool bondingChecked;

  final String requiredVent;
  final String actualVent;
  final bool ventAdequate;

  final bool systemFlushed;
  final String flushMethod;
  final bool inhibitorAdded;
  final bool magneticFilterInstalled;
  final bool waterSampleTaken;
  final String systemPressureCold;
  final String systemPressureHot;
  final bool expansionVesselChecked;
  final bool prvTested;
  final bool condensateCompliant;

  final String coHigh;
  final String co2High;
  final String coCo2High;
  final String coLow;
  final String co2Low;
  final String coCo2Low;
  final String applianceSetAt;
  final bool flueIntegrityTestDone;
  final bool samplingPointPresent;
  final bool caseSealsIntact;

  final bool flameSafetyOk;
  final bool overheatStatOk;
  final bool fanOk;
  final bool prvOk;
  final bool condensateTrapOk;
  final bool polarityCorrect;
  final bool earthContinuityOk;

  final bool tightnessDone;
  final String stabilisationTime;
  final String testPressure;
  final String endPressure;
  final String pressureDrop;
  final bool tightnessPass;

  final bool cleanedBeforeCommissioning;
  final bool burnerPressureChecked;
  final bool gasRateMeasured;
  final bool condensateDisposalCorrect;
  final bool flueGuardRequired;
  final bool flueGuardFitted;
  final bool benchmarkCompleted;
  final bool handoverCompleted;

  final bool applianceSafeToUse;
  final bool meetsManufacturerInstructions;
  final bool meetsGasSafeRequirements;

  final bool userShownControls;
  final bool userShownTopUp;
  final bool userShownIsolate;
  final bool warrantyExplained;
  final bool serviceScheduleExplained;

  final String installDate;
  final String commissionDate;
  final String nextServiceDue;

  final String engineerName;
  final String gasSafeNumber;
  final String companyName;
  final String companyAddress;
  final String companyPostcode;
  final String companyPhone;
  final String companyEmail;

  final String? engineerSignatureBase64;
  final String? customerSignatureBase64;

  InstallationCommissioningRecord({
    required this.certificateNumber,
    required this.customerName,
    required this.customerAddress,
    required this.customerPostcode,
    required this.customerPhone,
    required this.customerEmail,
    required this.propertyAddress,
    required this.propertyPostcode,
    required this.occupierName,
    required this.applianceType,
    required this.applianceMake,
    required this.applianceModel,
    required this.applianceSerial,
    required this.applianceLocation,
    required this.gasType,
    required this.flueType,
    required this.pipeSize,
    required this.standingPressure,
    required this.workingPressureMeter,
    required this.workingPressureAppliance,
    required this.ecvAccessible,
    required this.ecvLabelled,
    required this.pipeworkSupported,
    required this.bondingChecked,
    required this.requiredVent,
    required this.actualVent,
    required this.ventAdequate,
    required this.systemFlushed,
    required this.flushMethod,
    required this.inhibitorAdded,
    required this.magneticFilterInstalled,
    required this.waterSampleTaken,
    required this.systemPressureCold,
    required this.systemPressureHot,
    required this.expansionVesselChecked,
    required this.prvTested,
    required this.condensateCompliant,
    required this.coHigh,
    required this.co2High,
    required this.coCo2High,
    required this.coLow,
    required this.co2Low,
    required this.coCo2Low,
    required this.applianceSetAt,
    required this.flueIntegrityTestDone,
    required this.samplingPointPresent,
    required this.caseSealsIntact,
    required this.flameSafetyOk,
    required this.overheatStatOk,
    required this.fanOk,
    required this.prvOk,
    required this.condensateTrapOk,
    required this.polarityCorrect,
    required this.earthContinuityOk,
    required this.tightnessDone,
    required this.stabilisationTime,
    required this.testPressure,
    required this.endPressure,
    required this.pressureDrop,
    required this.tightnessPass,
    required this.cleanedBeforeCommissioning,
    required this.burnerPressureChecked,
    required this.gasRateMeasured,
    required this.condensateDisposalCorrect,
    required this.flueGuardRequired,
    required this.flueGuardFitted,
    required this.benchmarkCompleted,
    required this.handoverCompleted,
    required this.applianceSafeToUse,
    required this.meetsManufacturerInstructions,
    required this.meetsGasSafeRequirements,
    required this.userShownControls,
    required this.userShownTopUp,
    required this.userShownIsolate,
    required this.warrantyExplained,
    required this.serviceScheduleExplained,
    required this.installDate,
    required this.commissionDate,
    required this.nextServiceDue,
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

  Map<String, dynamic> toJson() => {
    'certificateNumber': certificateNumber,
    'customerName': customerName,
    'customerAddress': customerAddress,
    'customerPostcode': customerPostcode,
    'customerPhone': customerPhone,
    'customerEmail': customerEmail,
    'propertyAddress': propertyAddress,
    'propertyPostcode': propertyPostcode,
    'occupierName': occupierName,
    'applianceType': applianceType,
    'applianceMake': applianceMake,
    'applianceModel': applianceModel,
    'applianceSerial': applianceSerial,
    'applianceLocation': applianceLocation,
    'gasType': gasType,
    'flueType': flueType,
    'pipeSize': pipeSize,
    'standingPressure': standingPressure,
    'workingPressureMeter': workingPressureMeter,
    'workingPressureAppliance': workingPressureAppliance,
    'ecvAccessible': ecvAccessible,
    'ecvLabelled': ecvLabelled,
    'pipeworkSupported': pipeworkSupported,
    'bondingChecked': bondingChecked,
    'requiredVent': requiredVent,
    'actualVent': actualVent,
    'ventAdequate': ventAdequate,
    'systemFlushed': systemFlushed,
    'flushMethod': flushMethod,
    'inhibitorAdded': inhibitorAdded,
    'magneticFilterInstalled': magneticFilterInstalled,
    'waterSampleTaken': waterSampleTaken,
    'systemPressureCold': systemPressureCold,
    'systemPressureHot': systemPressureHot,
    'expansionVesselChecked': expansionVesselChecked,
    'prvTested': prvTested,
    'condensateCompliant': condensateCompliant,
    'coHigh': coHigh,
    'co2High': co2High,
    'coCo2High': coCo2High,
    'coLow': coLow,
    'co2Low': co2Low,
    'coCo2Low': coCo2Low,
    'applianceSetAt': applianceSetAt,
    'flueIntegrityTestDone': flueIntegrityTestDone,
    'samplingPointPresent': samplingPointPresent,
    'caseSealsIntact': caseSealsIntact,
    'flameSafetyOk': flameSafetyOk,
    'overheatStatOk': overheatStatOk,
    'fanOk': fanOk,
    'prvOk': prvOk,
    'condensateTrapOk': condensateTrapOk,
    'polarityCorrect': polarityCorrect,
    'earthContinuityOk': earthContinuityOk,
    'tightnessDone': tightnessDone,
    'stabilisationTime': stabilisationTime,
    'testPressure': testPressure,
    'endPressure': endPressure,
    'pressureDrop': pressureDrop,
    'tightnessPass': tightnessPass,
    'cleanedBeforeCommissioning': cleanedBeforeCommissioning,
    'burnerPressureChecked': burnerPressureChecked,
    'gasRateMeasured': gasRateMeasured,
    'condensateDisposalCorrect': condensateDisposalCorrect,
    'flueGuardRequired': flueGuardRequired,
    'flueGuardFitted': flueGuardFitted,
    'benchmarkCompleted': benchmarkCompleted,
    'handoverCompleted': handoverCompleted,
    'applianceSafeToUse': applianceSafeToUse,
    'meetsManufacturerInstructions': meetsManufacturerInstructions,
    'meetsGasSafeRequirements': meetsGasSafeRequirements,
    'userShownControls': userShownControls,
    'userShownTopUp': userShownTopUp,
    'userShownIsolate': userShownIsolate,
    'warrantyExplained': warrantyExplained,
    'serviceScheduleExplained': serviceScheduleExplained,
    'installDate': installDate,
    'commissionDate': commissionDate,
    'nextServiceDue': nextServiceDue,
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

  factory InstallationCommissioningRecord.fromJson(Map<String, dynamic> json) {
    return InstallationCommissioningRecord(
      certificateNumber: json['certificateNumber'] ?? '',
      customerName: json['customerName'] ?? '',
      customerAddress: json['customerAddress'] ?? '',
      customerPostcode: json['customerPostcode'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      customerEmail: json['customerEmail'] ?? '',

      propertyAddress: json['propertyAddress'] ?? '',
      propertyPostcode: json['propertyPostcode'] ?? '',
      occupierName: json['occupierName'] ?? '',

      applianceType: json['applianceType'] ?? '',
      applianceMake: json['applianceMake'] ?? '',
      applianceModel: json['applianceModel'] ?? '',
      applianceSerial: json['applianceSerial'] ?? '',
      applianceLocation: json['applianceLocation'] ?? '',
      gasType: json['gasType'] ?? 'NG',
      flueType: json['flueType'] ?? 'Room-sealed',

      pipeSize: json['pipeSize'] ?? '',
      standingPressure: json['standingPressure'] ?? '',
      workingPressureMeter: json['workingPressureMeter'] ?? '',
      workingPressureAppliance: json['workingPressureAppliance'] ?? '',
      ecvAccessible: json['ecvAccessible'] ?? true,
      ecvLabelled: json['ecvLabelled'] ?? true,
      pipeworkSupported: json['pipeworkSupported'] ?? true,
      bondingChecked: json['bondingChecked'] ?? true,

      requiredVent: json['requiredVent'] ?? '',
      actualVent: json['actualVent'] ?? '',
      ventAdequate: json['ventAdequate'] ?? true,

      systemFlushed: json['systemFlushed'] ?? true,
      flushMethod: json['flushMethod'] ?? 'Powerflush',
      inhibitorAdded: json['inhibitorAdded'] ?? true,
      magneticFilterInstalled: json['magneticFilterInstalled'] ?? true,
      waterSampleTaken: json['waterSampleTaken'] ?? false,
      systemPressureCold: json['systemPressureCold'] ?? '',
      systemPressureHot: json['systemPressureHot'] ?? '',
      expansionVesselChecked: json['expansionVesselChecked'] ?? true,
      prvTested: json['prvTested'] ?? true,
      condensateCompliant: json['condensateCompliant'] ?? true,

      coHigh: json['coHigh'] ?? '',
      co2High: json['co2High'] ?? '',
      coCo2High: json['coCo2High'] ?? '',
      coLow: json['coLow'] ?? '',
      co2Low: json['co2Low'] ?? '',
      coCo2Low: json['coCo2Low'] ?? '',
      applianceSetAt: json['applianceSetAt'] ?? 'Auto',
      flueIntegrityTestDone: json['flueIntegrityTestDone'] ?? true,
      samplingPointPresent: json['samplingPointPresent'] ?? true,
      caseSealsIntact: json['caseSealsIntact'] ?? true,

      flameSafetyOk: json['flameSafetyOk'] ?? true,
      overheatStatOk: json['overheatStatOk'] ?? true,
      fanOk: json['fanOk'] ?? true,
      prvOk: json['prvOk'] ?? true,
      condensateTrapOk: json['condensateTrapOk'] ?? true,
      polarityCorrect: json['polarityCorrect'] ?? true,
      earthContinuityOk: json['earthContinuityOk'] ?? true,

      tightnessDone: json['tightnessDone'] ?? true,
      stabilisationTime: json['stabilisationTime'] ?? '',
      testPressure: json['testPressure'] ?? '',
      endPressure: json['endPressure'] ?? '',
      pressureDrop: json['pressureDrop'] ?? '',
      tightnessPass: json['tightnessPass'] ?? true,

      cleanedBeforeCommissioning: json['cleanedBeforeCommissioning'] ?? true,
      burnerPressureChecked: json['burnerPressureChecked'] ?? true,
      gasRateMeasured: json['gasRateMeasured'] ?? true,
      condensateDisposalCorrect: json['condensateDisposalCorrect'] ?? true,
      flueGuardRequired: json['flueGuardRequired'] ?? false,
      flueGuardFitted: json['flueGuardFitted'] ?? false,
      benchmarkCompleted: json['benchmarkCompleted'] ?? true,
      handoverCompleted: json['handoverCompleted'] ?? true,

      applianceSafeToUse: json['applianceSafeToUse'] ?? true,
      meetsManufacturerInstructions:
      json['meetsManufacturerInstructions'] ?? true,
      meetsGasSafeRequirements: json['meetsGasSafeRequirements'] ?? true,

      userShownControls: json['userShownControls'] ?? true,
      userShownTopUp: json['userShownTopUp'] ?? true,
      userShownIsolate: json['userShownIsolate'] ?? true,
      warrantyExplained: json['warrantyExplained'] ?? true,
      serviceScheduleExplained: json['serviceScheduleExplained'] ?? true,

      installDate: json['installDate'] ?? '',
      commissionDate: json['commissionDate'] ?? '',
      nextServiceDue: json['nextServiceDue'] ?? '',

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
}


