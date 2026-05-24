import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';

import '../../../../services/email_service.dart';
import '../../../../services/invoice_service.dart';
import '../../../../utils_class/app_pdf_documents.dart';
import '../../../../utils_class/money.dart';
import '../../../../utils_class/pdf_print.dart';
import '../../../../widgets/attachment_section.dart';
import '../../../new_invoice_page/account_storage_file.dart';
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

  Future<void> _sharePdf(BuildContext context, InvoiceDetailMaster inv) async {
    final bytes = await _buildInvoicePdf(inv!);
    await PdfPrint.share(bytes, filename: "${inv.invoice!.invoiceNumber!}.pdf");
  }

  Future<void> _printPdf(BuildContext context, InvoiceDetailMaster inv) async {
    final bytes = await _buildInvoicePdf(inv);
    await PdfPrint.previewAndPrint(bytes,
        filename: "${inv.invoice!.invoiceNumber}.pdf");
  }

  Future<Uint8List> _buildInvoicePdf(
      InvoiceDetailMaster invoiceDetailsMaster) async {
   final pdf = AppPdfDocument();
    final accountStorage = AccountStorage();
    await accountStorage.load();
    final s = accountStorage.settings;
    Invoice inv = invoiceDetailsMaster.invoice!;
    pw.MemoryImage? logo;
    if(s.logoPath != null && s.logoPath!.isNotEmpty){
      final Uint8List imageBytes = await File(s.logoPath!).readAsBytes();
      logo = pw.MemoryImage(imageBytes);
    }


    // String vatLabel(double r) {
    //   switch (r) {
    //     case 0:
    //       return '0%';
    //     case 5:
    //       return '5%';
    //     case 20:
    //       return '20%';
    //   }
    //   return '0%';
    // }

    pdf.addPage(
      pw.MultiPage(
        build: (_) => [
          if(logo != null)...[
            pw.Image(logo, width: 80, height: 80),
            pw.SizedBox(height: 8)
          ],
          pw.Text(
            'Invoice ${inv.invoiceNumber}',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Date: ${_fmtDate(DateTime.parse(inv.invoiceDate!))}'),
          if (inv.dueDate != null)
            pw.Text('Due: ${_fmtDate(DateTime.parse(inv.dueDate!))}'),
          pw.SizedBox(height: 16),
          pw.Text('From:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(s.businessName),
          if (s.businessAddress.isNotEmpty) pw.Text(s.businessAddress),
          if (s.businessPhone.isNotEmpty) pw.Text('Phone: ${s.businessPhone}'),
          if (s.businessEmail.isNotEmpty) pw.Text('Email: ${s.businessEmail}'),
          if (s.vatRegistered && s.vatNumber.isNotEmpty)
            pw.Text('VAT: ${s.vatNumber}'),
          pw.SizedBox(height: 12),
          pw.Text('To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          //pw.Text(inv.customerId!.toString()),
          pw.Text("${invoiceDetailsMaster.customer!.name}"),
          pw.Text("${invoiceDetailsMaster.customer!.address} "),
          pw.Text('Phone: ${invoiceDetailsMaster.customer!.phone}'),
          pw.Text('Email: ${invoiceDetailsMaster.customer!.email}'),
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
                    child: pw.Text('Description'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Qty'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Unit'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Vat'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Total'),
                  ),
                ],
              ),
              ...invoiceDetailsMaster.lines!.map(
                (item) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(item.description!),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(item.quantity!.toStringAsFixed(0)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('£${item.unitPrice!.toTwoDecimal()}'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                          '£${(double.parse(item.unitPrice!) * item.quantity!) * (double.parse(item.vatRate.toString()) / 100)}'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('£${invoiceDetailsMaster.invoice!.total}'),
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
                pw.Text('Subtotal: £${inv.netTotal!}'),
                pw.Text('VAT : £${inv.vatTotal}'),
                pw.Text(
                  'TOTAL: £${inv.total}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Align(
            alignment: pw.Alignment.centerLeft,
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Text('Note : ',style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold
                )),
                pw.Text('${inv.note!}',style: pw.TextStyle(
                  fontWeight: pw.FontWeight.normal
                )),

              ],
            ),
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
