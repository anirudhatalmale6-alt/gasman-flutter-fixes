import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:the_gas_man_app/pages/finance/expense_form_page.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/data_models/bill_detail.dart';
import 'package:the_gas_man_app/services/bill_service.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';

import '../../../../services/company_service.dart';
import '../../../../services/email_service.dart';
import '../../../../utils_class/app_pdf_documents.dart';
import '../../../../utils_class/launchers.dart';
import '../../../../utils_class/money.dart';
import '../../../../utils_class/pdf_print.dart';
import '../../../../widgets/attachment_section.dart';
import '../../../new_invoice_page/account_storage_file.dart';
import '../../api_service/api_config.dart';
import '../../pdf_service.dart';
import 'package:pdf/widgets.dart' as pw;

// TODO: create this service
// import '../../../../services/bill_service.dart';

class BillViewScreen extends StatefulWidget {
  final int billId;

  const BillViewScreen({super.key, required this.billId});

  @override
  State<BillViewScreen> createState() => _BillViewScreenState();
}

class _BillViewScreenState extends State<BillViewScreen> {
  final EmailService _emailService = EmailService();
  final CompanyService _companyService = CompanyService();
  final _billService = BillService();

  Future<BillDetails> _loadBill() async {
    BillDetails res = await _billService.getDetail(widget.billId);
    return res;
  }

  Future<void> _sharePdf(BuildContext context, BillDetails billDetails) async {
    try {
      Uint8List bytes = await _buildInvoicePdf(billDetails);
      await PdfPrint.share(bytes,
          filename: "${billDetails.bill?.billNumber ?? 'bill'}.pdf");
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to share PDF: $e")),
        );
      }
    }
  }

  Future<void> _printPdf(BuildContext context, BillDetails billDetails) async {
    try {
      Uint8List bytes = await _buildInvoicePdf(billDetails);
      await PdfPrint.previewAndPrint(bytes,
          filename: "${billDetails.bill?.billNumber ?? 'bill'}.pdf");
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to print PDF: $e")),
        );
      }
    }
  }



  Future<void> _showEmailDialog(BuildContext context) async {
    final emailCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    final formKey = GlobalKey<FormState>();
    bool sending = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Send Bill Email"),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// Email
                      TextFormField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "Email is required";
                          }
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!emailRegex.hasMatch(v)) {
                            return "Enter valid email";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      /// Subject
                      TextFormField(
                        controller: subjectCtrl,
                        decoration: const InputDecoration(
                          labelText: "Subject",
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? "Subject required" : null,
                      ),

                      const SizedBox(height: 12),

                      /// Body
                      TextFormField(
                        controller: bodyCtrl,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: "Message",
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? "Message required" : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: sending
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          setState(() => sending = true);

                          try {
                            await _emailService.sendBillEmail(
                              billId: widget.billId,
                              toEmail: emailCtrl.text,
                              subject: subjectCtrl.text,
                              body: bodyCtrl.text,
                            );

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Email sent successfully")),
                              );
                            }
                          } catch (e) {
                            setState(() => sending = false);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: $e")),
                            );
                          }
                        },
                  child: sending
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Send"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BillDetails>(
      future: _loadBill(),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final bill = snap.data!.bill;
        final billLines = snap.data!.lines;
        final total = bill!.total;

        return Scaffold(
          appBar: AppBar(
            title: Text("Bill ${bill.billNumber}"),
            actions: [
              IconButton(
                tooltip: "Print",
                icon: const Icon(Icons.print),
                onPressed: () => _printPdf(context, snap.data!),
              ),
              IconButton(
                tooltip: "Share PDF",
                icon: const Icon(Icons.share),
                onPressed: () => _sharePdf(context, snap.data!),
              ),
              IconButton(
                tooltip: "Email",
                icon: const Icon(Icons.email),
                onPressed: () => _showEmailDialog(context),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              /// 🔹 Supplier + Total
              Card(
                child: ListTile(
                  title: Text(bill.supplierId.toString()),
                  subtitle: Text("Status: ${bill.status}"),
                  trailing: Text(
                    formatMoney(double.parse(total.toString())),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// 🔹 Bill Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Bill Date: ${bill.billDate}"),
                      Text("Due Date: ${bill.dueDate}"),
                      Text(
                          "Balance: ${formatMoney(double.parse(bill.balance.toString()))}"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// 🔹 Line Items
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Items",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      ...List.generate((billLines as List).length, (i) {
                        final line = billLines![i];

                        final qty = line.quantity;
                        final cost = double.parse(line.unitCost!);
                        final lineTotal =
                            double.parse(line.lineTotal.toString());

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(line.description ?? "Item"),
                          subtitle: Text("Qty: $qty × ${formatMoney(cost)}"),
                          trailing: Text(formatMoney(lineTotal)),
                        );
                      })
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// 🔹 Attachments
              AttachmentSection(
                parentType: "bill",
                parentId: widget.billId,
              ),

              const SizedBox(height: 12),

              /// 🔹 Tip
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Tip",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 6),
                      Text(
                          "To send the bill WITH an attachment, use “Share PDF” and choose Mail/Gmail."),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Uint8List> _buildInvoicePdf(BillDetails billDetails) async {
    final pdf = AppPdfDocument();
    Bill inv = billDetails.bill!;

    // Fetch company info from server API
    Map<String, dynamic> co = {};
    try {
      co = await _companyService.getCompany();
    } catch (_) {}

    final companyName = (co['business_name'] as String?) ??
        (co['name'] as String?) ?? '';
    final companyAddress = (co['address'] as String?) ?? '';
    final companyPhone = (co['phone'] as String?) ?? '';
    final companyEmail = (co['email'] as String?) ?? '';
    final companyVrn = (co['vrn'] as String?) ?? '';
    final gasSafeNumber = (co['gas_safe_number'] as String?) ?? '';
    final paymentDetails = (co['payment_details'] as String?) ?? '';
    final logoUrl = co['logo_url'] as String?;
    final symbol = (co['currency_symbol'] as String?) ?? '£';

    // Download logo from server
    pw.MemoryImage? logo;
    if (logoUrl != null && logoUrl.isNotEmpty) {
      try {
        final fullUrl = '${ApiConfig.baseUrl}$logoUrl';
        final response = await Dio().get(
          fullUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        logo = pw.MemoryImage(Uint8List.fromList(response.data));
      } catch (_) {}
    }

    // Fallback: try local logo
    if (logo == null) {
      try {
        final accountStorage = AccountStorage();
        await accountStorage.load();
        final localPath = accountStorage.settings.logoPath;
        if (localPath != null && localPath.isNotEmpty) {
          final f = File(localPath);
          if (await f.exists()) {
            logo = pw.MemoryImage(await f.readAsBytes());
          }
        }
      } catch (_) {}
    }

    final subTotal = getSubtotal(billDetails.lines ?? []);
    final total = getGrandTotal(billDetails.lines ?? []);
    final vatTotal = getTotalVat(billDetails.lines ?? []);

    pdf.addPage(
      pw.MultiPage(
        build: (_) => [
          // Header: logo + company info
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (logo != null) ...[
                pw.Image(logo, width: 80, height: 80),
                pw.SizedBox(width: 12),
              ],
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (companyName.isNotEmpty)
                      pw.Text(companyName,
                          style: pw.TextStyle(
                              fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    if (companyAddress.isNotEmpty)
                      pw.Text(companyAddress, style: const pw.TextStyle(fontSize: 9)),
                    if (companyPhone.isNotEmpty)
                      pw.Text('Tel: $companyPhone', style: const pw.TextStyle(fontSize: 9)),
                    if (companyEmail.isNotEmpty)
                      pw.Text(companyEmail, style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  if (companyVrn.isNotEmpty)
                    pw.Text('VAT: $companyVrn', style: const pw.TextStyle(fontSize: 8)),
                  if (gasSafeNumber.isNotEmpty)
                    pw.Text('Gas Safe: $gasSafeNumber', style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
            ],
          ),
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Text(
            'BILL ${inv.billNumber ?? ""}',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (inv.billDate != null)
                      pw.Text('Date: ${_fmtDate(DateTime.parse(inv.billDate!))}'),
                    if (inv.dueDate != null)
                      pw.Text('Due: ${_fmtDate(DateTime.parse(inv.dueDate!))}'),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('From:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    if (billDetails.supplier?.name != null)
                      pw.Text(billDetails.supplier!.name!),
                    if (billDetails.supplier?.address != null)
                      pw.Text(billDetails.supplier!.address!),
                    if (billDetails.supplier?.phone != null)
                      pw.Text('Tel: ${billDetails.supplier!.phone}'),
                    if (billDetails.supplier?.email != null)
                      pw.Text(billDetails.supplier!.email!),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(width: 0.4),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFE0F2F1),
                ),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Description',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Qty',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Unit Cost',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('VAT',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Total',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
              ...(billDetails.lines ?? []).map(
                (item) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(item.description ?? ''),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text((item.quantity ?? 0).toStringAsFixed(0)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('$symbol${item.unitCost ?? "0.00"}'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                          '$symbol${((double.tryParse(item.unitCost ?? "0") ?? 0) * (item.quantity ?? 0) * ((double.tryParse(item.vatRate?.toString() ?? "0") ?? 0) / 100)).toStringAsFixed(2)}'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('$symbol${item.lineTotal ?? "0.00"}'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Subtotal: $symbol${subTotal.toStringAsFixed(2)}'),
                pw.Text('VAT: $symbol${vatTotal.toStringAsFixed(2)}'),
                pw.Text(
                  'TOTAL: $symbol${total.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (paymentDetails.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            pw.Divider(),
            pw.Text('Payment Details:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
            pw.Text(paymentDetails, style: const pw.TextStyle(fontSize: 9)),
          ],
        ],
      ),
    );

    return pdf.save();
  }

  double getSubtotal(List<BillLines> lines) {
    return lines.fold(0, (sum, item) {
      final lineTotal = double.tryParse(item.lineTotal ?? "0") ?? 0;
      return sum + lineTotal;
    });
  }

  double getTotalVat(List<BillLines> lines) {
    return lines.fold(0, (sum, item) {
      final lineTotal = double.tryParse(item.lineTotal ?? "0") ?? 0;
      final vatRate = double.tryParse(item.vatRate ?? "0") ?? 0;

      final vat = lineTotal * (vatRate / 100);
      return sum + vat;
    });
  }

  double getGrandTotal(List<BillLines> lines) {
    final subtotal = getSubtotal(lines);
    final vat = getTotalVat(lines);
    return subtotal + vat;
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
