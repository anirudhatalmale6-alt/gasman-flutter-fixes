import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../new_invoice_page/account_storage_file.dart';
import 'cp_17_certificate_model.dart';


class Cp17PdfService {
  static Future<void> shareCertificate(Cp17Certificate certificate) async {
    final bytes = await buildCertificate(certificate);

    await Printing.sharePdf(
      bytes: bytes,
      filename: '${certificate.certificateRef}.pdf',
    );
  }

  static Future<Uint8List> buildCertificate(Cp17Certificate c) async {
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
          _section('Site / Client Details'),
          _box([
            _row('Site Name', c.siteName),
            _row('Site Address', c.siteAddress),
            _row('Client', c.clientName),
            _row('Responsible Person', c.responsiblePerson),
          ]),

          _section('Gas Installation Details'),
          _box([
            _row('Gas Type', c.gasType),
            _row('Meter Location', c.meterLocation),
            _row('Emergency Control Location', c.emergencyControlLocation),
          ]),

          _section('Safety Checks'),
          _box([
            _tick('Tightness test completed', c.tightnessTestCompleted),
            _row('Tightness Test Result', c.tightnessTestResult),
            _tick(
              'Emergency controls accessible',
              c.emergencyControlsAccessible,
            ),
            _tick('Ventilation satisfactory', c.ventilationSatisfactory),
            _tick('Flues satisfactory', c.fluesSatisfactory),
            _tick('Appliances secure / safe condition', c.appliancesSecure),
            _tick(
              'Warning notices present where required',
              c.warningNoticesPresent,
            ),
          ]),

          _section('Defect Classification'),
          _box([
            _row('Classification', c.defectClassification),
            _row('Defect Details', c.defectDetails),
            _row('Action Taken', c.actionTaken),
          ]),

          _section('Observations / Recommendations'),
          _box([
            _row('Observations', c.observations),
            _row('Recommendations', c.recommendations),
          ]),

          _section('Engineer / Company Details'),
          _box([
            _row('Company', c.companyName),
            _row('Company Address', c.companyAddress),
            _row('Company Phone', c.companyPhone),
            _row('Engineer', c.engineerName),
            _row('Gas Safe No.', c.gasSafeNumber),
            _row('Business Email.', c.engineerEmail),
          ]),

          _section('Declaration'),
          _box([
            pw.Text(
              'I confirm that the commercial gas installation safety report details recorded above are accurate to the best of my knowledge. Any unsafe situations, defects, and actions taken are recorded on this report.',
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

  static pw.Widget _header(Cp17Certificate c) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 1.5),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'CP17 COMMERCIAL GAS INSTALLATION',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'SAFETY REPORT',
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
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
      ),
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
          pw.Expanded(
            child: pw.Text(value.isEmpty ? '-' : value),
          ),
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

  static pw.Widget _signatureBox(
      String title,
      pw.MemoryImage? image,
      ) {
    return pw.Container(
      height: 95,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
      ),
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
