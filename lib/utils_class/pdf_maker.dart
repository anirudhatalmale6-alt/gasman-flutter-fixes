import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:the_gas_man_app/pages/new_invoice_page/data_model/all_models.dart';
import '../models/company_settings.dart';
import '../models/landlord_gas_safety.dart';


class PdfMaker {
  static Future<Uint8List> landlordCert({
    required AccountingSettings settings,
    required LandlordGasSafety cert,
  }) async {
    final doc = pw.Document();
    final df = DateFormat('dd/MM/yyyy');

    pw.Widget row(String a, String b) => pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [pw.Expanded(child: pw.Text(a)), pw.SizedBox(width: 8), pw.Expanded(child: pw.Text(b))],
    );

    doc.addPage(
      pw.Page(
        build: (c) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Text('GAS SAFETY RECORD', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.Container(color: PdfColor.fromInt(0xFF147D7E), height: 2),
            pw.SizedBox(height: 10),
            pw.Text(settings.businessName, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.Text('Engineer: ${settings.businessName}   Gas Safe: ${settings.gasSafeNumber}'),
            pw.Text(settings.businessAddress),
            pw.Text('Tel: ${settings.businessPhone}   Email: ${settings.businessEmail}'),
            pw.SizedBox(height: 12),
            row('Landlord/Agent', cert.landlord),
            row('Property Address', cert.propertyAddress),
            row('Tenant', cert.tenant),
            row('Date of Issue', df.format(cert.dateOfIssue)),
            row('Next Inspection Due', df.format(cert.nextInspectionDue)),
            pw.SizedBox(height: 12),
            pw.Text('Appliances', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Table.fromTextArray(
              headers: ['Location','Type','Make/Model','Tightness','Ventilation','Flue'],
              data: cert.appliances.map((a)=>[
                a.location, a.type, a.makeModel,
                a.tightnessOk ? 'Yes' : 'No',
                a.ventilationOk ? 'Yes' : 'No',
                a.flueOk ? 'Yes' : 'No'
              ]).toList(),
              headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFEFF8F8)),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Comments / Defects'),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(border: pw.Border.all()),
              child: pw.Text(cert.comments),
            ),
          ],
        ),
      ),
    );
    return doc.save();
  }
}

