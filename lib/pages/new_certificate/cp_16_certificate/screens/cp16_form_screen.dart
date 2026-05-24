import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../../../new_invoice_page/account_storage_file.dart';
import '../../../new_invoice_page/data_model/all_models.dart';
import '../cp16_pdf_service/cp16_pdf_service.dart';
import '../db_services/cp16_db_service.dart';
import '../models/cp_16_certificate.dart';
import '../widgets/section_card.dart';

class Cp16FormScreen extends StatefulWidget {
  final Cp16Certificate? existingCertificate;

  final String? nextCertNumber;

  const Cp16FormScreen(
      {super.key, this.existingCertificate, this.nextCertNumber});

  @override
  State<Cp16FormScreen> createState() => _Cp16FormScreenState();
}

class _Cp16FormScreenState extends State<Cp16FormScreen> {
  final formKey = GlobalKey<FormState>();
  static const Color _cardBg = Color(0xFFF3F7F7);

  late String certificateRef;

  int? certificateId;
  bool locked = false;

  final certNumber = TextEditingController(text: 'CP16-00001');

  final siteName = TextEditingController();
  final siteAddress = TextEditingController();
  final clientName = TextEditingController();
  final contractorName = TextEditingController();

  final engineerName = TextEditingController();
  final gasSafeNumber = TextEditingController();
  final companyName = TextEditingController();
  final companyAddress = TextEditingController();
  final companyPhone = TextEditingController();
  final engineerEmail = TextEditingController();

  final pipeMaterial = TextEditingController();
  final pipeSize = TextEditingController();
  final installationLength = TextEditingController();
  final installationVolume = TextEditingController();

  final strengthTestPressure = TextEditingController();
  final strengthTestDuration = TextEditingController();
  final strengthPressureDrop = TextEditingController();

  final tightnessTestPressure = TextEditingController();
  final tightnessStartPressure = TextEditingController();
  final tightnessEndPressure = TextEditingController();
  final tightnessStabilisationPeriod = TextEditingController();
  final tightnessDuration = TextEditingController();
  final tightnessPressureDrop = TextEditingController();

  final purgeVolume = TextEditingController();
  final purgePoint = TextEditingController();
  final purgeVentLocation = TextEditingController();
  final ventTerminationLocation = TextEditingController();
  final gasDetectorUsed = TextEditingController();
  final purgeSafetyPrecautions = TextEditingController();

  final defectsFound = TextEditingController();
  final remedialAction = TextEditingController();
  final isolationDetails = TextEditingController();
  final comments = TextEditingController();

  // Inspection dates (store as text)
  final _inspectionDateController = TextEditingController();
  final _nextInspectionDueController = TextEditingController();
  final _reminderDateController = TextEditingController();

  String gasType = 'Natural Gas';
  String testMedium = 'Air';
  String strengthTestResult = 'Pass';
  String tightnessResult = 'Pass';
  String purgeMethod = 'Direct Purge';

  bool riskAssessmentCompleted = false;
  bool areaVentilated = false;
  bool noIgnitionSources = false;
  bool warningNoticesDisplayed = false;
  bool emergencyProceduresInPlace = false;
  bool fireExtinguisherAvailable = false;
  bool responsiblePersonPresent = false;

  final engineerSignature = SignatureController(penStrokeWidth: 2);
  final customerSignature = SignatureController(penStrokeWidth: 2);

  String engineerSignatureBase64 = '';
  String customerSignatureBase64 = '';

  bool get canEdit => !locked;

  @override
  void initState() {
    super.initState();

    certificateRef = 'CP16-${DateTime.now().millisecondsSinceEpoch}';

    final c = widget.existingCertificate;

    if (c != null) {
      certificateId = c.id;
      certificateRef = c.certificateRef;
      locked = c.locked;
      certNumber.text = c.certificateNumber;
      siteName.text = c.siteName;
      siteAddress.text = c.siteAddress;
      clientName.text = c.clientName;
      contractorName.text = c.contractorName;

      engineerName.text = c.engineerName;
      gasSafeNumber.text = c.gasSafeNumber;
      companyName.text = c.companyName;
      companyAddress.text = c.companyAddress;
      companyPhone.text = c.companyPhone;
      engineerEmail.text = c.engineerEmail;

      gasType = c.gasType;
      pipeMaterial.text = c.pipeMaterial;
      pipeSize.text = c.pipeSize;
      installationLength.text = c.installationLength;
      installationVolume.text = c.installationVolume;

      testMedium = c.testMedium;

      strengthTestPressure.text = c.strengthTestPressure;
      strengthTestDuration.text = c.strengthTestDuration;
      strengthPressureDrop.text = c.strengthPressureDrop;
      strengthTestResult = c.strengthTestResult;

      tightnessTestPressure.text = c.tightnessTestPressure;
      tightnessStartPressure.text = c.tightnessStartPressure;
      tightnessEndPressure.text = c.tightnessEndPressure;
      tightnessStabilisationPeriod.text = c.tightnessStabilisationPeriod;
      tightnessDuration.text = c.tightnessDuration;
      tightnessPressureDrop.text = c.tightnessPressureDrop;
      tightnessResult = c.tightnessResult;

      purgeMethod = c.purgeMethod;
      purgeVolume.text = c.purgeVolume;
      purgePoint.text = c.purgePoint;
      purgeVentLocation.text = c.purgeVentLocation;
      ventTerminationLocation.text = c.ventTerminationLocation;
      gasDetectorUsed.text = c.gasDetectorUsed;
      purgeSafetyPrecautions.text = c.purgeSafetyPrecautions;

      riskAssessmentCompleted = c.riskAssessmentCompleted;
      areaVentilated = c.areaVentilated;
      noIgnitionSources = c.noIgnitionSources;
      warningNoticesDisplayed = c.warningNoticesDisplayed;
      emergencyProceduresInPlace = c.emergencyProceduresInPlace;
      fireExtinguisherAvailable = c.fireExtinguisherAvailable;
      responsiblePersonPresent = c.responsiblePersonPresent;

      defectsFound.text = c.defectsFound;
      remedialAction.text = c.remedialAction;
      isolationDetails.text = c.isolationDetails;
      comments.text = c.comments;

      engineerSignatureBase64 = c.engineerSignatureBase64;
      customerSignatureBase64 = c.customerSignatureBase64;

      // Dates
      _inspectionDateController.text = c.inspectionDate;
      _nextInspectionDueController.text = c.nextInspectionDue;
      _reminderDateController.text = c.reminderDate;
    } else {
      certNumber.text = widget.nextCertNumber ?? "CP16-00001";
      setCompanyDetails();
    }
  }

  @override
  void dispose() {
    siteName.dispose();
    siteAddress.dispose();
    clientName.dispose();
    contractorName.dispose();

    engineerName.dispose();
    gasSafeNumber.dispose();
    companyName.dispose();
    companyAddress.dispose();
    companyPhone.dispose();
    engineerEmail.dispose();

    pipeMaterial.dispose();
    pipeSize.dispose();
    installationLength.dispose();
    installationVolume.dispose();

    strengthTestPressure.dispose();
    strengthTestDuration.dispose();
    strengthPressureDrop.dispose();

    tightnessTestPressure.dispose();
    tightnessStartPressure.dispose();
    tightnessEndPressure.dispose();
    tightnessStabilisationPeriod.dispose();
    tightnessDuration.dispose();
    tightnessPressureDrop.dispose();

    purgeVolume.dispose();
    purgePoint.dispose();
    purgeVentLocation.dispose();
    ventTerminationLocation.dispose();
    gasDetectorUsed.dispose();
    purgeSafetyPrecautions.dispose();

    defectsFound.dispose();
    remedialAction.dispose();
    isolationDetails.dispose();
    comments.dispose();

    engineerSignature.dispose();
    customerSignature.dispose();

    _inspectionDateController.dispose();
    _nextInspectionDueController.dispose();
    _reminderDateController.dispose();

    super.dispose();
  }

  void setCompanyDetails() async {
    AccountStorage _storage = AccountStorage();
    AccountingSettings companySettings = _storage.settings;
    if (companySettings != null) {
      engineerName.text = companySettings.engineerName;
      companyName.text = companySettings.businessName;
      companyAddress.text = companySettings.businessAddress;
      gasSafeNumber.text = companySettings.gasSafeNumber;
      companyPhone.text = companySettings.businessPhone;
      engineerEmail.text = companySettings.businessEmail;
    }
  }

  double calculatePipeVolumeM3() {
    final diameterMm = double.tryParse(pipeSize.text.trim()) ?? 0;
    final lengthM = double.tryParse(installationLength.text.trim()) ?? 0;

    if (diameterMm <= 0 || lengthM <= 0) return 0;

    final diameterM = diameterMm / 1000;
    final radiusM = diameterM / 2;

    return 3.14159265359 * radiusM * radiusM * lengthM;
  }

  void updateCalculatedPurgeVolume() {
    final volume = calculatePipeVolumeM3();

    if (volume <= 0) return;

    purgeVolume.text = volume.toStringAsFixed(4);
  }

  Future<String> signatureToBase64(
    SignatureController controller,
    String existing,
  ) async {
    if (controller.isEmpty) return existing;

    final bytes = await controller.toPngBytes();

    if (bytes == null) return existing;

    return base64Encode(bytes);
  }

  Cp16Certificate buildCertificate({
    required bool shouldLock,
  }) {
    return Cp16Certificate(
      id: certificateId,
      certificateNumber: certNumber.text,
      certificateRef: certificateRef,
      siteName: siteName.text.trim(),
      siteAddress: siteAddress.text.trim(),
      clientName: clientName.text.trim(),
      contractorName: contractorName.text.trim(),
      engineerName: engineerName.text.trim(),
      gasSafeNumber: gasSafeNumber.text.trim(),
      companyName: companyName.text.trim(),
      companyAddress: companyAddress.text.trim(),
      companyPhone: companyPhone.text.trim(),
      engineerEmail: engineerEmail.text.trim(),
      gasType: gasType,
      pipeMaterial: pipeMaterial.text.trim(),
      pipeSize: pipeSize.text.trim(),
      installationLength: installationLength.text.trim(),
      installationVolume: installationVolume.text.trim(),
      testMedium: testMedium,
      strengthTestPressure: strengthTestPressure.text.trim(),
      strengthTestDuration: strengthTestDuration.text.trim(),
      strengthPressureDrop: strengthPressureDrop.text.trim(),
      strengthTestResult: strengthTestResult,
      tightnessTestPressure: tightnessTestPressure.text.trim(),
      tightnessStartPressure: tightnessStartPressure.text.trim(),
      tightnessEndPressure: tightnessEndPressure.text.trim(),
      tightnessStabilisationPeriod: tightnessStabilisationPeriod.text.trim(),
      tightnessDuration: tightnessDuration.text.trim(),
      tightnessPressureDrop: tightnessPressureDrop.text.trim(),
      tightnessResult: tightnessResult,
      purgeMethod: purgeMethod,
      purgeVolume: purgeVolume.text.trim(),
      purgePoint: purgePoint.text.trim(),
      purgeVentLocation: purgeVentLocation.text.trim(),
      ventTerminationLocation: ventTerminationLocation.text.trim(),
      gasDetectorUsed: gasDetectorUsed.text.trim(),
      purgeSafetyPrecautions: purgeSafetyPrecautions.text.trim(),
      riskAssessmentCompleted: riskAssessmentCompleted,
      areaVentilated: areaVentilated,
      noIgnitionSources: noIgnitionSources,
      warningNoticesDisplayed: warningNoticesDisplayed,
      emergencyProceduresInPlace: emergencyProceduresInPlace,
      fireExtinguisherAvailable: fireExtinguisherAvailable,
      responsiblePersonPresent: responsiblePersonPresent,
      defectsFound: defectsFound.text.trim(),
      remedialAction: remedialAction.text.trim(),
      isolationDetails: isolationDetails.text.trim(),
      comments: comments.text.trim(),
      engineerSignatureBase64: engineerSignatureBase64,
      customerSignatureBase64: customerSignatureBase64,
      locked: shouldLock,
      inspectionDate: _inspectionDateController.text.trim(),
      nextInspectionDue: _nextInspectionDueController.text.trim(),
      reminderDate: _reminderDateController.text.trim(),
    );
  }

  Future<void> save({
    bool lock = false,
  }) async {
    if (!formKey.currentState!.validate()) return;

    if (lock) {
      updateCalculatedPurgeVolume();

      final safetyOk = riskAssessmentCompleted &&
          areaVentilated &&
          noIgnitionSources &&
          emergencyProceduresInPlace &&
          responsiblePersonPresent;

      if (!safetyOk) {
        showMessage(
          'Complete required safety controls before locking.',
        );
        return;
      }

      if (strengthTestResult == 'Fail' || tightnessResult == 'Fail') {
        if (defectsFound.text.trim().isEmpty ||
            remedialAction.text.trim().isEmpty) {
          showMessage(
            'Failed tests require defects found and remedial action before locking.',
          );
          return;
        }
      }

      if (purgeVolume.text.trim().isEmpty) {
        showMessage('Purge volume is required before locking.');
        return;
      }
    }

    engineerSignatureBase64 = await signatureToBase64(
      engineerSignature,
      engineerSignatureBase64,
    );

    customerSignatureBase64 = await signatureToBase64(
      customerSignature,
      customerSignatureBase64,
    );

    if (lock &&
        (engineerSignatureBase64.isEmpty || customerSignatureBase64.isEmpty)) {
      showMessage(
        'Engineer and customer signatures are required before locking.',
      );
      return;
    }

    final certificate = buildCertificate(
      shouldLock: lock || locked,
    );

    final id = await Cp16DbService.saveCertificate(certificate);

    certificateId = id;
    locked = lock || locked;

    if (!mounted) return;

    setState(() {});

    showMessage(
      lock ? 'CP16 locked and saved.' : 'CP16 draft saved.',
    );
  }

  Future<void> exportPdf() async {
    await save(lock: locked);

    await Cp16PdfService.shareCertificate(
      buildCertificate(shouldLock: locked),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void showFailWarning(String testName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Test Failed'),
        content: Text(
          '$testName has been marked as Fail. Record defects, remedial action, and do not lock the certificate unless the issue is resolved or properly documented.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  InputDecoration decoration(String label) {
    return InputDecoration(labelText: label);
  }

  Widget textField(
    TextEditingController controller,
    String label, {
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        enabled: canEdit,
        keyboardType: keyboardType,
        decoration: decoration(label),
        validator: required
            ? (v) => v == null || v.trim().isEmpty ? 'Required' : null
            : null,
      ),
    );
  }

  Widget dropdown({
    required String label,
    required String value,
    required List<String> values,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: decoration(label),
        items: values
            .map(
              (v) => DropdownMenuItem(
                value: v,
                child: Text(v),
              ),
            )
            .toList(),
        onChanged: canEdit
            ? (v) {
                if (v == null) return;
                setState(() => onChanged(v));
              }
            : null,
      ),
    );
  }

  Widget safetySwitch(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: canEdit
          ? (v) {
              setState(() => onChanged(v));
            }
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingCertificate != null
            ? widget.existingCertificate!.certificateNumber
            : widget.nextCertNumber!),
        actions: [
          if (locked)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.lock),
            ),
        ],
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            SectionCard(
              title: 'Certificate Number',
              icon: Icons.numbers,
              children: [
                textField(certNumber, 'CP-XXXXXX', required: true),
              ],
            ),
            SectionCard(
              title: 'Site / Project Details',
              icon: Icons.business,
              children: [
                textField(siteName, 'Site Name', required: true),
                textField(siteAddress, 'Site Address', required: true),
                textField(clientName, 'Client Name'),
                textField(contractorName, 'Contractor Name'),
              ],
            ),
            SectionCard(
              title: 'Engineer / Company',
              icon: Icons.engineering,
              children: [
                textField(companyName, 'Company Name'),
                textField(companyAddress, 'Company Address'),
                textField(companyPhone, 'Company Phone'),
                textField(engineerName, 'Engineer Name', required: true),
                textField(gasSafeNumber, 'Gas Safe Number', required: true),
                textField(engineerEmail, 'Business Email', required: true),
              ],
            ),
            SectionCard(
              title: 'Installation Details',
              icon: Icons.account_tree,
              children: [
                dropdown(
                  label: 'Gas Type',
                  value: gasType,
                  values: const ['Natural Gas', 'LPG', 'Other'],
                  onChanged: (v) => gasType = v,
                ),
                textField(pipeMaterial, 'Pipe Material', required: true),
                TextFormField(
                  controller: pipeSize,
                  enabled: canEdit,
                  keyboardType: TextInputType.number,
                  decoration: decoration('Pipe Size / Diameter (mm)'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                  onChanged: (_) => updateCalculatedPurgeVolume(),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: installationLength,
                  enabled: canEdit,
                  keyboardType: TextInputType.number,
                  decoration: decoration('Installation Length (m)'),
                  onChanged: (_) => updateCalculatedPurgeVolume(),
                ),
                const SizedBox(height: 10),
                textField(
                  installationVolume,
                  'Installation Volume (optional)',
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            SectionCard(
              title: 'Strength Test',
              icon: Icons.speed,
              children: [
                dropdown(
                  label: 'Test Medium',
                  value: testMedium,
                  values: const ['Air', 'Nitrogen', 'Other'],
                  onChanged: (v) => testMedium = v,
                ),
                textField(
                  strengthTestPressure,
                  'Strength Test Pressure',
                  required: true,
                ),
                textField(
                  strengthTestDuration,
                  'Strength Test Duration',
                  required: true,
                ),
                textField(
                  strengthPressureDrop,
                  'Strength Pressure Drop',
                  required: true,
                ),
                dropdown(
                  label: 'Strength Test Result',
                  value: strengthTestResult,
                  values: const ['Pass', 'Fail'],
                  onChanged: (v) {
                    strengthTestResult = v;
                    if (v == 'Fail') showFailWarning('Strength test');
                  },
                ),
              ],
            ),
            SectionCard(
              title: 'Tightness Test',
              icon: Icons.compress,
              children: [
                textField(
                  tightnessTestPressure,
                  'Tightness Test Pressure',
                  required: true,
                ),
                textField(
                  tightnessStartPressure,
                  'Start Pressure',
                  required: true,
                ),
                textField(
                  tightnessEndPressure,
                  'End Pressure',
                  required: true,
                ),
                textField(
                  tightnessStabilisationPeriod,
                  'Stabilisation Period',
                  required: true,
                ),
                textField(
                  tightnessDuration,
                  'Duration',
                  required: true,
                ),
                textField(
                  tightnessPressureDrop,
                  'Tightness Pressure Drop',
                  required: true,
                ),
                dropdown(
                  label: 'Tightness Test Result',
                  value: tightnessResult,
                  values: const ['Pass', 'Fail'],
                  onChanged: (v) {
                    tightnessResult = v;
                    if (v == 'Fail') showFailWarning('Tightness test');
                  },
                ),
              ],
            ),
            SectionCard(
              title: 'Purging',
              icon: Icons.air,
              children: [
                dropdown(
                  label: 'Purge Method',
                  value: purgeMethod,
                  values: const ['Direct Purge', 'Indirect Purge', 'Other'],
                  onChanged: (v) => purgeMethod = v,
                ),
                textField(
                  purgeVolume,
                  'Auto Calculated Purge Volume (m³)',
                  keyboardType: TextInputType.number,
                ),
                if (canEdit)
                  OutlinedButton.icon(
                    onPressed: () {
                      updateCalculatedPurgeVolume();
                      showMessage('Purge volume recalculated.');
                    },
                    icon: const Icon(Icons.calculate),
                    label: const Text('Calculate Purge Volume'),
                  ),
                const SizedBox(
                  height: 10.0,
                ),
                textField(purgePoint, 'Purge Point', required: true),
                textField(
                  purgeVentLocation,
                  'Purge Vent Location',
                  required: true,
                ),
                textField(
                  ventTerminationLocation,
                  'Vent Termination Location',
                  required: true,
                ),
                textField(gasDetectorUsed, 'Gas Detector Used'),
                textField(
                  purgeSafetyPrecautions,
                  'Safety Precautions',
                  required: true,
                ),
              ],
            ),
            SectionCard(
              title: 'Safety Controls',
              icon: Icons.health_and_safety,
              children: [
                safetySwitch(
                  'Risk assessment completed',
                  riskAssessmentCompleted,
                  (v) => riskAssessmentCompleted = v,
                ),
                safetySwitch(
                  'Area ventilated',
                  areaVentilated,
                  (v) => areaVentilated = v,
                ),
                safetySwitch(
                  'No ignition sources present',
                  noIgnitionSources,
                  (v) => noIgnitionSources = v,
                ),
                safetySwitch(
                  'Warning notices displayed',
                  warningNoticesDisplayed,
                  (v) => warningNoticesDisplayed = v,
                ),
                safetySwitch(
                  'Emergency procedures in place',
                  emergencyProceduresInPlace,
                  (v) => emergencyProceduresInPlace = v,
                ),
                safetySwitch(
                  'Fire extinguisher available',
                  fireExtinguisherAvailable,
                  (v) => fireExtinguisherAvailable = v,
                ),
                safetySwitch(
                  'Responsible person present',
                  responsiblePersonPresent,
                  (v) => responsiblePersonPresent = v,
                ),
              ],
            ),
            SectionCard(
              title: 'Defects / Actions / Comments',
              icon: Icons.report_problem,
              children: [
                textField(defectsFound, 'Defects Found'),
                textField(remedialAction, 'Remedial Action'),
                textField(isolationDetails, 'Isolation Details'),
                textField(comments, 'Comments'),
              ],
            ),
            _buildInspectionDatesCard(),
            SectionCard(
              title: 'Signatures',
              icon: Icons.draw,
              children: [
                const Text('Engineer Signature'),
                if (engineerSignatureBase64.isNotEmpty)
                  const Text('Saved signature already stored.'),
                if (canEdit)
                  Signature(
                    controller: engineerSignature,
                    height: 120,
                    backgroundColor: Colors.grey,
                  ),
                const SizedBox(height: 12),
                const Text('Customer / Responsible Person Signature'),
                if (customerSignatureBase64.isNotEmpty)
                  const Text('Saved signature already stored.'),
                if (canEdit)
                  Signature(
                    controller: customerSignature,
                    height: 120,
                    backgroundColor: Colors.grey,
                  ),
              ],
            ),
            FilledButton.icon(
              onPressed: canEdit ? () => save(lock: false) : null,
              icon: const Icon(Icons.save),
              label: const Text('Save Draft'),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: canEdit ? () => save(lock: true) : null,
              icon: const Icon(Icons.lock),
              label: const Text('Save & Lock CP16'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: exportPdf,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Export / Share PDF'),
            ),
          ],
        ),
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

  Widget _card({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
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
}
