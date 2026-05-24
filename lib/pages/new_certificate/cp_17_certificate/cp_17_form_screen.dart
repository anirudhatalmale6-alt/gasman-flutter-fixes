import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';

import '../../new_invoice_page/account_storage_file.dart';
import '../../new_invoice_page/data_model/all_models.dart';
import 'cp_17_certificate_model.dart';
import 'cp_17_db_services.dart';
import 'cp_17_pdf_services.dart';

class Cp17FormScreen extends StatefulWidget {
  final Cp17Certificate? existingCertificate;
  final String? nextCertNumber;

  const Cp17FormScreen(
      {super.key, this.existingCertificate, this.nextCertNumber});

  @override
  State<Cp17FormScreen> createState() => _Cp17FormScreenState();
}

class _Cp17FormScreenState extends State<Cp17FormScreen> {
  final formKey = GlobalKey<FormState>();

  late String certificateRef;
  late String inspectionDate;

  int? certificateId;
  bool locked = false;

  static const Color _cardBg = Color(0xFFF3F7F7);
  final certNumber = TextEditingController();
  final siteName = TextEditingController();
  final siteAddress = TextEditingController();
  final clientName = TextEditingController();
  final responsiblePerson = TextEditingController();

  final engineerName = TextEditingController();
  final gasSafeNumber = TextEditingController();
  final companyName = TextEditingController();
  final companyAddress = TextEditingController();
  final companyPhone = TextEditingController();
  final engineerEmail = TextEditingController();

  final meterLocation = TextEditingController();
  final emergencyControlLocation = TextEditingController();

  final defectDetails = TextEditingController();
  final actionTaken = TextEditingController();
  final observations = TextEditingController();
  final recommendations = TextEditingController();

  // Inspection dates (store as text)
  final _nextInspectionDueController = TextEditingController();
  final _inspectionDateController = TextEditingController();
  final _reminderDateController = TextEditingController();

  String gasType = 'Natural Gas';
  String tightnessTestResult = 'Pass';
  String defectClassification = 'Safe';

  bool tightnessTestCompleted = false;
  bool emergencyControlsAccessible = false;
  bool ventilationSatisfactory = false;
  bool fluesSatisfactory = false;
  bool appliancesSecure = false;
  bool warningNoticesPresent = false;

  final engineerSignature = SignatureController(
    penStrokeWidth: 2,
  );

  final customerSignature = SignatureController(
    penStrokeWidth: 2,
  );

  String engineerSignatureBase64 = '';
  String customerSignatureBase64 = '';

  bool get canEdit => !locked;

  @override
  void initState() {
    super.initState();

    certificateRef = 'CP17-${DateTime.now().millisecondsSinceEpoch}';

    inspectionDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

    final c = widget.existingCertificate;

    if (c != null) {
      certNumber.text = c.certificateNumber;
      certificateId = c.id;
      certificateRef = c.certificateRef;
      inspectionDate = c.inspectionDate;
      locked = c.locked;

      siteName.text = c.siteName;
      siteAddress.text = c.siteAddress;
      clientName.text = c.clientName;
      responsiblePerson.text = c.responsiblePerson;

      engineerName.text = c.engineerName;
      gasSafeNumber.text = c.gasSafeNumber;
      companyName.text = c.companyName;
      companyAddress.text = c.companyAddress;
      companyPhone.text = c.companyPhone;
      engineerEmail.text = c.engineerEmail;

      gasType = c.gasType;
      meterLocation.text = c.meterLocation;
      emergencyControlLocation.text = c.emergencyControlLocation;

      tightnessTestCompleted = c.tightnessTestCompleted;
      tightnessTestResult = c.tightnessTestResult;

      emergencyControlsAccessible = c.emergencyControlsAccessible;

      ventilationSatisfactory = c.ventilationSatisfactory;

      fluesSatisfactory = c.fluesSatisfactory;
      appliancesSecure = c.appliancesSecure;

      warningNoticesPresent = c.warningNoticesPresent;

      defectClassification = c.defectClassification;
      defectDetails.text = c.defectDetails;
      actionTaken.text = c.actionTaken;

      observations.text = c.observations;
      recommendations.text = c.recommendations;

      engineerSignatureBase64 = c.engineerSignatureBase64;

      customerSignatureBase64 = c.customerSignatureBase64;
      // Dates
      _nextInspectionDueController.text = c.nextInspectionDue;
      _inspectionDateController.text = c.inspectionDate;
      _reminderDateController.text = c.reminderDate;
    } else {
      certNumber.text = widget.nextCertNumber!;
      setCompanyDetails();
    }
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

  @override
  void dispose() {
    certNumber.dispose();
    siteName.dispose();
    siteAddress.dispose();
    clientName.dispose();
    responsiblePerson.dispose();

    engineerName.dispose();
    gasSafeNumber.dispose();
    companyName.dispose();
    companyAddress.dispose();
    companyPhone.dispose();
    engineerEmail.dispose();

    meterLocation.dispose();
    emergencyControlLocation.dispose();

    defectDetails.dispose();
    actionTaken.dispose();
    observations.dispose();
    recommendations.dispose();

    engineerSignature.dispose();
    customerSignature.dispose();
    _nextInspectionDueController.dispose();
    _inspectionDateController.dispose();
    _reminderDateController.dispose();

    super.dispose();
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

  Cp17Certificate buildCertificate({
    required bool shouldLock,
  }) {
    return Cp17Certificate(
      id: certificateId,
      certificateRef: certificateRef,
      certificateNumber: certNumber.text,
      inspectionDate: _inspectionDateController.text,
      siteName: siteName.text.trim(),
      siteAddress: siteAddress.text.trim(),
      clientName: clientName.text.trim(),
      responsiblePerson: responsiblePerson.text.trim(),
      engineerName: engineerName.text.trim(),
      gasSafeNumber: gasSafeNumber.text.trim(),
      companyName: companyName.text.trim(),
      companyAddress: companyAddress.text.trim(),
      companyPhone: companyPhone.text.trim(),
      engineerEmail: engineerEmail.text.trim(),
      gasType: gasType,
      meterLocation: meterLocation.text.trim(),
      emergencyControlLocation: emergencyControlLocation.text.trim(),
      tightnessTestCompleted: tightnessTestCompleted,
      tightnessTestResult: tightnessTestResult,
      emergencyControlsAccessible: emergencyControlsAccessible,
      ventilationSatisfactory: ventilationSatisfactory,
      fluesSatisfactory: fluesSatisfactory,
      appliancesSecure: appliancesSecure,
      warningNoticesPresent: warningNoticesPresent,
      defectClassification: defectClassification,
      defectDetails: defectDetails.text.trim(),
      actionTaken: actionTaken.text.trim(),
      observations: observations.text.trim(),
      recommendations: recommendations.text.trim(),
      engineerSignatureBase64: engineerSignatureBase64,
      customerSignatureBase64: customerSignatureBase64,
      locked: shouldLock,
      nextInspectionDue: _nextInspectionDueController.text,
      reminderDate: _reminderDateController.text,
    );
  }

  Future<void> save({
    bool lock = false,
  }) async {
    if (!formKey.currentState!.validate()) return;

    engineerSignatureBase64 = await signatureToBase64(
      engineerSignature,
      engineerSignatureBase64,
    );

    customerSignatureBase64 = await signatureToBase64(
      customerSignature,
      customerSignatureBase64,
    );

    final certificate = buildCertificate(
      shouldLock: lock || locked,
    );

    if (lock) {
      if (!certificate.hasSignatures) {
        showMessage(
          'Engineer and customer signatures are required before locking.',
        );
        return;
      }

      if (!certificate.safetyChecksComplete) {
        showMessage(
          'Complete all required safety checks before locking.',
        );
        return;
      }

      if (!certificate.hasRequiredUnsafeInfo) {
        showMessage(
          'AR / ID classifications require defect details and action taken.',
        );
        return;
      }
    }

    final id = await Cp17DbService.saveCertificate(certificate);

    certificateId = id;
    locked = lock || locked;

    if (!mounted) return;

    setState(() {});

    showMessage(
      lock ? 'CP17 locked and saved.' : 'CP17 draft saved.',
    );
  }

  Future<void> exportPdf() async {
    await save(lock: locked);

    await Cp17PdfService.shareCertificate(
      buildCertificate(shouldLock: locked),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void showUnsafeWarning(String value) {
    if (value != 'AR' && value != 'ID') return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          value == 'ID' ? 'Immediately Dangerous' : 'At Risk',
        ),
        content: Text(
          value == 'ID'
              ? 'Immediately Dangerous selected. Record the defect, action taken, isolation/disconnection details, and warning notice information.'
              : 'At Risk selected. Record the defect details and action taken before locking.',
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        enabled: canEdit,
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
              icon: Icons.business,
              children: [
                textField(
                  certNumber,
                  'CP17-XXXXX',
                  required: true,
                )
              ],
            ),
            SectionCard(
              title: 'Site / Client Details',
              icon: Icons.business,
              children: [
                textField(
                  siteName,
                  'Site Name',
                  required: true,
                ),
                textField(
                  siteAddress,
                  'Site Address',
                  required: true,
                ),
                textField(
                  clientName,
                  'Client Name',
                ),
                textField(
                  responsiblePerson,
                  'Responsible Person',
                ),
              ],
            ),
            SectionCard(
              title: 'Engineer / Company',
              icon: Icons.engineering,
              children: [
                textField(
                  companyName,
                  'Company Name',
                ),
                textField(
                  companyAddress,
                  'Company Address',
                ),
                textField(
                  companyPhone,
                  'Company Phone',
                ),
                textField(
                  engineerName,
                  'Engineer Name',
                  required: true,
                ),
                textField(
                  gasSafeNumber,
                  'Gas Safe Number',
                  required: true,
                ),
                textField(
                  engineerEmail,
                  'Business Email',
                  required: true,
                ),
              ],
            ),
            SectionCard(
              title: 'Installation Details',
              icon: Icons.local_fire_department,
              children: [
                dropdown(
                  label: 'Gas Type',
                  value: gasType,
                  values: const [
                    'Natural Gas',
                    'LPG',
                    'Other',
                  ],
                  onChanged: (v) => gasType = v,
                ),
                textField(
                  meterLocation,
                  'Meter Location',
                ),
                textField(
                  emergencyControlLocation,
                  'Emergency Control Location',
                  required: true,
                ),
              ],
            ),
            SectionCard(
              title: 'Safety Checks',
              icon: Icons.health_and_safety,
              children: [
                safetySwitch(
                  'Tightness test completed',
                  tightnessTestCompleted,
                  (v) => tightnessTestCompleted = v,
                ),
                dropdown(
                  label: 'Tightness Test Result',
                  value: tightnessTestResult,
                  values: const ['Pass', 'Fail'],
                  onChanged: (v) => tightnessTestResult = v,
                ),
                safetySwitch(
                  'Emergency controls accessible',
                  emergencyControlsAccessible,
                  (v) => emergencyControlsAccessible = v,
                ),
                safetySwitch(
                  'Ventilation satisfactory',
                  ventilationSatisfactory,
                  (v) => ventilationSatisfactory = v,
                ),
                safetySwitch(
                  'Flues satisfactory',
                  fluesSatisfactory,
                  (v) => fluesSatisfactory = v,
                ),
                safetySwitch(
                  'Appliances secure / safe condition',
                  appliancesSecure,
                  (v) => appliancesSecure = v,
                ),
                safetySwitch(
                  'Warning notices present where required',
                  warningNoticesPresent,
                  (v) => warningNoticesPresent = v,
                ),
              ],
            ),
            SectionCard(
              title: 'Defect Classification',
              icon: Icons.report_problem,
              children: [
                dropdown(
                  label: 'Classification',
                  value: defectClassification,
                  values: const ['Safe', 'AR', 'ID'],
                  onChanged: (v) {
                    defectClassification = v;
                    showUnsafeWarning(v);
                  },
                ),
                textField(
                  defectDetails,
                  'Defect Details',
                ),
                textField(
                  actionTaken,
                  'Action Taken',
                ),
              ],
            ),
            SectionCard(
              title: 'Observations / Recommendations',
              icon: Icons.notes,
              children: [
                textField(
                  observations,
                  'Observations',
                ),
                textField(
                  recommendations,
                  'Recommendations',
                ),
              ],
            ),
            _buildInspectionDatesCard(),
            SectionCard(
              title: 'Signatures',
              icon: Icons.draw,
              children: [
                const Text('Engineer Signature'),
                if (engineerSignatureBase64.isNotEmpty)
                  const Text(
                    'Saved signature already stored.',
                  ),
                if (canEdit)
                  Signature(
                    controller: engineerSignature,
                    height: 120,
                    backgroundColor: Colors.grey,
                  ),
                const SizedBox(height: 12),
                const Text(
                  'Customer / Responsible Person Signature',
                ),
                if (customerSignatureBase64.isNotEmpty)
                  const Text(
                    'Saved signature already stored.',
                  ),
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
              label: const Text('Save & Lock CP17'),
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

class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}
