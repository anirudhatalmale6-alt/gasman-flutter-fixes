import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../new_invoice_page/account_storage_file.dart';
import '../models/cp_16_certificate.dart';




class Cp16PdfService {
  static Future<void> shareCertificate(Cp16Certificate certificate) async {
    final bytes = await buildCertificate(certificate);

    await Printing.sharePdf(
      bytes: bytes,
      filename: '${certificate.certificateRef}.pdf',
    );
  }

  static Future<Uint8List> buildCertificate(Cp16Certificate c) async {
    final pdf = pw.Document();

    final engineerSig = c.engineerSignatureBase64.isEmpty
        ? null
        : pw.MemoryImage(base64Decode(c.engineerSignatureBase64));

    final customerSig = c.customerSignatureBase64.isEmpty
        ? null
        : pw.MemoryImage(base64Decode(c.customerSignatureBase64));

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

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(22),
        build: (context) => [
          if(logo != null)...[
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
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
          _header(c),
          _section('Site / Project Details'),
          _box([
            _row('Site Name', c.siteName),
            _row('Site Address', c.siteAddress),
            _row('Client', c.clientName),
            _row('Contractor', c.contractorName),
          ]),
          _section('Installation Details'),
          _box([
            _row('Gas Type', c.gasType),
            _row('Pipe Material', c.pipeMaterial),
            _row('Pipe Size / Diameter', c.pipeSize),
            _row('Installation Length', c.installationLength),
            _row('Installation Volume', c.installationVolume),
            _row('Purge Volume', c.purgeVolume),
            _row('Purge Point', c.purgePoint),
            _row('Vent Location', c.purgeVentLocation),
            _row('Vent Termination', c.ventTerminationLocation),
            _row('Gas Detector Used', c.gasDetectorUsed),
          ]),
          _section('Strength Test'),
          _box([
            _row('Test Medium', c.testMedium),
            _row('Test Pressure', c.strengthTestPressure),
            _row('Duration', c.strengthTestDuration),
            _row('Pressure Drop', c.strengthPressureDrop),
            _row('Result', c.strengthTestResult),
          ]),
          _section('Tightness Test'),
          _box([
            _row('Test Pressure', c.tightnessTestPressure),
            _row('Start Pressure', c.tightnessStartPressure),
            _row('End Pressure', c.tightnessEndPressure),
            _row('Stabilisation Period', c.tightnessStabilisationPeriod),
            _row('Duration', c.tightnessDuration),
            _row('Pressure Drop', c.tightnessPressureDrop),
            _row('Result', c.tightnessResult),
          ]),
          _section('Purging Method / Safety Precautions'),
          _box([
            _row('Method', c.purgeMethod),
            _row('Safety Precautions', c.purgeSafetyPrecautions),
          ]),
          _section('Safety Controls'),
          _box([
            _tick('Risk assessment completed', c.riskAssessmentCompleted),
            _tick('Area ventilated', c.areaVentilated),
            _tick('No ignition sources present', c.noIgnitionSources),
            _tick('Warning notices displayed', c.warningNoticesDisplayed),
            _tick('Emergency procedures in place',
                c.emergencyProceduresInPlace),
            _tick('Fire extinguisher available',
                c.fireExtinguisherAvailable),
            _tick('Responsible person present', c.responsiblePersonPresent),
          ]),
          _section('Defects / Remedial Action / Comments'),
          _box([
            _row('Defects Found', c.defectsFound),
            _row('Remedial Action', c.remedialAction),
            _row('Isolation Details', c.isolationDetails),
            _row('Comments', c.comments),
          ]),
          _section('Engineer / Company Details'),
          _box([
            _row('Company', c.companyName),
            _row('Company Address', c.companyAddress),
            _row('Company Phone', c.companyPhone),
            _row('Engineer', c.engineerName),
            _row('Gas Safe No.', c.gasSafeNumber),
            _row('Business Email', c.engineerEmail),
          ]),
          _section('Declaration'),
          _box([
            pw.Text(
              'I confirm that the commercial gas installation testing and purging details recorded above are accurate to the best of my knowledge and that the safety precautions noted were observed.',
            ),
          ]),
          _section('Signatures'),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _signatureBox('Engineer Signature', engineerSig),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: _signatureBox(
                  'Client / Responsible Person',
                  customerSig,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _header(Cp16Certificate c) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 1.5)),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'CP16 COMMERCIAL GAS INSTALLATION',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'TESTING AND PURGING RECORD',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                c.companyName.isEmpty
                    ? 'GasPro Certificate'
                    : c.companyName,
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Ref: ${c.certificateRef}'),
              pw.Text('Date: ${c.inspectionDate}'),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _section(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 11, bottom: 4),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 12.5,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _box(List<pw.Widget> children) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(border: pw.Border.all()),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  static pw.Widget _row(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 135,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(child: pw.Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }

  static pw.Widget _tick(String label, bool checked) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Text('${checked ? 'YES' : 'NO'} - $label'),
    );
  }

  static pw.Widget _signatureBox(String title, pw.MemoryImage? image) {
    return pw.Container(
      height: 95,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(border: pw.Border.all()),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          if (image != null)
            pw.Image(image, height: 50)
          else
            pw.Text('Not signed'),
        ],
      ),
    );
  }
}


