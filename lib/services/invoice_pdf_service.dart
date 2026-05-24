import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../models/billing_models.dart';
import '../utils_class/app_pdf_documents.dart';

class InvoicePdfService {
  static Future<File> build(InvoiceDoc d) async {
   final pdf = AppPdfDocument();
    pdf.addPage(pw.MultiPage(
      margin: const pw.EdgeInsets.all(20),
      build: (ctx) => [
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text(d.docType.toUpperCase(), style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.Text('No. ${d.number}', style: const pw.TextStyle(fontSize: 12)),
        ]),
        pw.SizedBox(height: 6),
        pw.Row(children: [
          pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('Customer: ${d.customer}'),
            pw.Text(d.address),
            pw.Text(d.email),
          ])),
          pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
            pw.Text('Date: ${_fmt(d.date)}')
          ])),
        ]),
        pw.SizedBox(height: 12),
        pw.Table.fromTextArray(
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headerDecoration: const pw.BoxDecoration(color: PdfColor(0.9,0.95,0.94)),
          data: <List<String>>[
            ['Item', 'Qty', 'Price', 'Line total'],
            ...d.items.map((i)=>[i.name, i.qty.toStringAsFixed(2), '£${i.price.toStringAsFixed(2)}', '£${i.total.toStringAsFixed(2)}']),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
            pw.Text('Subtotal: £${d.subtotal.toStringAsFixed(2)}'),
            pw.Text('VAT: £${d.vat.toStringAsFixed(2)}'),
            pw.Text('Total: £${d.total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          ])
        ]),
        if (d.notes.isNotEmpty) pw.SizedBox(height: 10),
        if (d.notes.isNotEmpty) pw.Text('Notes: ${d.notes}'),
      ],
    ));
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${d.docType}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
  static String _fmt(DateTime d) => '${d.day.toString().padLeft(2,'0')}-${d.month.toString().padLeft(2,'0')}-${d.year}';
}
