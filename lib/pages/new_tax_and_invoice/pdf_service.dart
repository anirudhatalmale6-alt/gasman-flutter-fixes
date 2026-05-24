
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../utils_class/app_pdf_documents.dart';




class PdfService {
  static Future<Uint8List> generateInvoicePdf({
    required String invoiceNumber,
    required String invoiceDate,
    required String customerName,
    required String customerAddress,
    required List<Map<String, dynamic>> lines,
    required double netTotal,
    required double vatTotal,
    required double total,
    required bool isPaid,
    String? companyName,
    String? companyAddress,
  }) async {
   final pdf = AppPdfDocument();

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(24),
        build: (_) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (companyName != null) pw.Text(companyName, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              if (companyAddress != null) pw.Text(companyAddress),
              pw.SizedBox(height: 16),

              pw.Text("INVOICE", style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold)),
              pw.Text("Invoice: $invoiceNumber"),
              pw.Text("Date: $invoiceDate"),
              pw.Text("Status: ${isPaid ? "PAID" : "UNPAID"}",
                style: pw.TextStyle(color: isPaid ? PdfColors.green : PdfColors.red),
              ),

              pw.SizedBox(height: 16),
              pw.Text("Bill To:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(customerName),
              pw.Text(customerAddress),

              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: ["Description", "Qty", "Rate", "Total"],
                data: lines.map((l) => [
                  l["description"]?.toString() ?? "",
                  l["qty"].toString(),
                  "£${(l["price"] as num).toDouble().toStringAsFixed(2)}",
                  "£${(l["total"] as num).toDouble().toStringAsFixed(2)}",
                ]).toList(),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                border: pw.TableBorder.all(width: 0.5),
              ),

              pw.SizedBox(height: 16),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text("Net: £${netTotal.toStringAsFixed(2)}"),
                    pw.Text("VAT: £${vatTotal.toStringAsFixed(2)}"),
                    pw.Text("TOTAL: £${total.toStringAsFixed(2)}",
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateCustomerStatementPdf({
    required String customerName,
    required String periodStart,
    required String periodEnd,
    required List<Map<String, dynamic>> lines,
    required double totalInvoiced,
    required double totalPaid,
    required double totalOutstanding,
  }) async {
   final pdf = AppPdfDocument();
    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(24),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Customer Statement", style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.Text("Customer: $customerName"),
            pw.Text("Period: $periodStart to $periodEnd"),
            pw.SizedBox(height: 12),
            pw.Table.fromTextArray(
              headers: ["Date", "Invoice", "Due", "Total", "Balance"],
              data: lines.map((l) => [
                l["date"], l["number"], l["dueDate"],
                "£${(l["total"] as double).toStringAsFixed(2)}",
                "£${(l["balance"] as double).toStringAsFixed(2)}",
              ]).toList(),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              border: pw.TableBorder.all(width: 0.5),
            ),
            pw.SizedBox(height: 12),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text("Total Invoiced: £${totalInvoiced.toStringAsFixed(2)}"),
                  pw.Text("Total Paid: £${totalPaid.toStringAsFixed(2)}"),
                  pw.Text("Outstanding: £${totalOutstanding.toStringAsFixed(2)}",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return pdf.save();
  }

  static Future<Uint8List> generatePayslipPdf({
    required String employeeName,
    required String period,
    required double gross,
    required double tax,
    required double ni,
    required double net,
  }) async {
   final pdf = AppPdfDocument();
    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(24),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("PAYSLIP", style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.Text("Employee: $employeeName"),
            pw.Text("Period: $period"),
            pw.SizedBox(height: 12),
            pw.Text("Gross Pay: £${gross.toStringAsFixed(2)}"),
            pw.Text("Income Tax: -£${tax.toStringAsFixed(2)}"),
            pw.Text("National Insurance: -£${ni.toStringAsFixed(2)}"),
            pw.SizedBox(height: 8),
            pw.Text("Net Pay: £${net.toStringAsFixed(2)}",
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ),
    );
    return pdf.save();
  }
  static Future<Uint8List> simpleInvoicePdf({
    required String invoiceNo,
    required String customer,
    required double total,
  }) async {
   final pdf = AppPdfDocument();
    pdf.addPage(
      pw.Page(
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("INVOICE", style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text("Invoice: $invoiceNo"),
            pw.Text("Customer: $customer"),
            pw.SizedBox(height: 12),
            pw.Text("Total: £${total.toStringAsFixed(2)}"),
          ],
        ),
      ),
    );
    return pdf.save();
  }
  /****** Stock Print pdf service ********/

  Future<pw.Document> buildStockReport(Map data) async {
   final pdf = AppPdfDocument();

    final items = data["items"] as List;
    final totals = data["totals"];

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Stock Valuation Report",
                  style: pw.TextStyle(fontSize: 20)),

              pw.SizedBox(height: 16),

              pw.Table.fromTextArray(
                headers: ["Product", "Qty", "Avg Cost", "Value"],
                data: items.map((e) {
                  return [
                    e["name"],
                    e["stock_qty"].toString(),
                    "£${e["avg_cost"]}",
                    "£${e["total_value"]}",
                  ];
                }).toList(),
              ),

              pw.SizedBox(height: 16),

              pw.Text(
                "Total Qty: ${totals["total_qty"]}",
              ),
              pw.Text(
                "Total Value: £${totals["total_value"]}",
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  Future<void> exportPdf(Map data) async {
    final pdf = await buildStockReport(data);

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  /******* CSV Report *****/

  // String generateCsv(Map data) {
  //   final items = data["items"] as List;
  //
  //   List<List<String>> rows = [
  //     ["Product", "Qty", "Avg Cost", "Value"]
  //   ];
  //
  //   for (var e in items) {
  //     rows.add([
  //       e["name"],
  //       e["stock_qty"].toString(),
  //       e["avg_cost"].toString(),
  //       e["total_value"].toString(),
  //     ]);
  //   }
  //
  //   return const ListToCsvConverter().convert(rows);
  // }





}
