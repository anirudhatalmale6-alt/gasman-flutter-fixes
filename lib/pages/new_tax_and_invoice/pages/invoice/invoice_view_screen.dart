import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';

import '../../../../services/company_service.dart';
import '../../../../services/email_service.dart';
import '../../../../services/invoice_service.dart';
import '../../../../utils_class/app_pdf_documents.dart';
import '../../../../utils_class/money.dart';
import '../../../../utils_class/pdf_print.dart';
import '../../../../widgets/attachment_section.dart';
import '../../../new_invoice_page/account_storage_file.dart';
import '../../api_service/api_config.dart';
import '../../data_models/invoice_detail.dart';
import 'package:pdf/widgets.dart' as pw;

class InvoiceViewScreen extends StatefulWidget {
  final int invoiceId;

  const InvoiceViewScreen({super.key, required this.invoiceId});

  @override
  State<InvoiceViewScreen> createState() => _InvoiceViewScreenState();
}

class _InvoiceViewScreenState extends State<InvoiceViewScreen> {
  final EmailService _emailService = EmailService();
  final CompanyService _companyService = CompanyService();

  Future<void> _sharePdf(BuildContext context, InvoiceDetailMaster inv) async {
    try {
      final bytes = await _buildInvoicePdf(inv);
      await PdfPrint.share(bytes, filename: "${inv.invoice?.invoiceNumber ?? 'invoice'}.pdf");
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to share PDF: $e")),
        );
      }
    }
  }

  Future<void> _printPdf(BuildContext context, InvoiceDetailMaster inv) async {
    try {
      final bytes = await _buildInvoicePdf(inv);
      await PdfPrint.previewAndPrint(bytes,
          filename: "${inv.invoice?.invoiceNumber ?? 'invoice'}.pdf");
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to print PDF: $e")),
        );
      }
    }
  }

  Future<Uint8List> _buildInvoicePdf(
      InvoiceDetailMaster invoiceDetailsMaster) async {
    final pdf = AppPdfDocument();
    Invoice inv = invoiceDetailsMaster.invoice!;

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
    final companyWebsite = (co['website'] as String?) ?? '';
    final companyVrn = (co['vrn'] as String?) ?? '';
    final companyReg = (co['company_reg'] as String?) ?? '';
    final companyUtr = (co['utr'] as String?) ?? '';
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

    // Fallback: try local logo if server logo failed
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
                    if (companyWebsite.isNotEmpty)
                      pw.Text(companyWebsite, style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  if (companyVrn.isNotEmpty)
                    pw.Text('VAT: $companyVrn', style: const pw.TextStyle(fontSize: 8)),
                  if (companyReg.isNotEmpty)
                    pw.Text('Co. Reg: $companyReg', style: const pw.TextStyle(fontSize: 8)),
                  if (companyUtr.isNotEmpty)
                    pw.Text('UTR: $companyUtr', style: const pw.TextStyle(fontSize: 8)),
                  if (gasSafeNumber.isNotEmpty)
                    pw.Text('Gas Safe: $gasSafeNumber', style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
            ],
          ),
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Text(
            'INVOICE',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          // Invoice details and Bill To side by side
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Invoice No: ${inv.invoiceNumber ?? ""}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    if (inv.invoiceDate != null)
                      pw.Text('Date: ${_fmtDate(DateTime.parse(inv.invoiceDate!))}'),
                    if (inv.dueDate != null)
                      pw.Text('Due: ${_fmtDate(DateTime.parse(inv.dueDate!))}'),
                    pw.Text('Status: ${inv.status ?? "UNPAID"}'),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Bill To:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(invoiceDetailsMaster.customer?.name ?? ''),
                    if ((invoiceDetailsMaster.customer?.address ?? '').isNotEmpty)
                      pw.Text(invoiceDetailsMaster.customer!.address!),
                    if ((invoiceDetailsMaster.customer?.phone ?? '').isNotEmpty)
                      pw.Text('Tel: ${invoiceDetailsMaster.customer!.phone}'),
                    if ((invoiceDetailsMaster.customer?.email ?? '').isNotEmpty)
                      pw.Text(invoiceDetailsMaster.customer!.email!),
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
                    child: pw.Text('Price',
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
              ...(invoiceDetailsMaster.lines ?? []).map(
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
                      child: pw.Text('$symbol${(item.unitPrice ?? "0.00")}'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                          '$symbol${((double.tryParse(item.unitPrice ?? "0") ?? 0) * (item.quantity ?? 0) * ((double.tryParse(item.vatRate?.toString() ?? "0") ?? 0) / 100)).toStringAsFixed(2)}'),
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
                pw.Text('Subtotal: $symbol${inv.netTotal ?? "0.00"}'),
                pw.Text('VAT: $symbol${inv.vatTotal ?? "0.00"}'),
                pw.Text(
                  'TOTAL: $symbol${inv.total ?? "0.00"}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if ((inv.note ?? '').isNotEmpty) ...[
            pw.SizedBox(height: 12),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Note: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Expanded(child: pw.Text(inv.note ?? '')),
              ],
            ),
          ],
          if (paymentDetails.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            pw.Divider(),
            pw.Text('Payment Details:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
            pw.Text(paymentDetails, style: const pw.TextStyle(fontSize: 9)),
          ],
          pw.SizedBox(height: 16),
          pw.Center(
            child: pw.Text('Thank you for your business.',
                style: pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFF888888))),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final service = InvoiceService();

    return FutureBuilder<InvoiceDetailMaster>(
      future: service.getDetail(widget.invoiceId),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final detail = snap.data!;
        final items = snap.data!.lines;
        final inv = detail.invoice;

        final total = double.tryParse(inv!.total!);

        return Scaffold(
          appBar: AppBar(
            title: Text("Invoice ${inv.invoiceNumber}"),
            actions: [
              IconButton(
                tooltip: "Print",
                icon: const Icon(Icons.print),
                onPressed: () => _printPdf(context, detail),
              ),
              IconButton(
                tooltip: "Share PDF",
                icon: const Icon(Icons.share),
                onPressed: () => _sharePdf(context, detail),
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
              Card(
                child: ListTile(
                  title: Text(inv!.customerId!.toString()),
                  subtitle: Text("Status: ${inv.status}"),
                  trailing: Text(
                    formatMoney(double.parse(inv.total!)),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Items",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      ...List.generate((items as List).length, (i) {
                        final line = items![i];

                        final qty = line.quantity;
                        final cost = double.parse(line.unitPrice!);
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

              // Attachments
              AttachmentSection(
                parentType: "invoice",
                parentId: widget.invoiceId,
              ),

              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Tip",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      const Text(
                          "To send the invoice WITH the PDF attached, use “Share PDF” and choose Mail/Gmail."),
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

  Future<void> _sendEmailFromBackend(BuildContext context) async {
    try {
      await _emailService.sendInvoiceEmail(invoiceId: widget.invoiceId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invoice email sent successfully.")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send email: $e")),
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
                      await _emailService.sendInvoiceEmail(
                        invoiceId: widget.invoiceId,
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

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
