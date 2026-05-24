import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:the_gas_man_app/theme/app_theme.dart';

import '../../../utils_class/app_pdf_documents.dart';
import '../account_storage_file.dart';
import '../data_model/all_models.dart';
import 'edit_invoice_page.dart';

class InvoicesTab extends StatefulWidget {
  final AccountStorage storage;
  final VoidCallback onChanged;

  const InvoicesTab({
    super.key,
    required this.storage,
    required this.onChanged,
  });

  @override
  State<InvoicesTab> createState() => _InvoicesTabState();
}

class _InvoicesTabState extends State<InvoicesTab> {
  bool _showEstimates = false;

  @override
  Widget build(BuildContext context) {
    final invoices = widget.storage.invoices
        .where((i) => _showEstimates ? i.isEstimate : !i.isEstimate)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Container(
      color: AppColors.kLightBg,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Invoices'),
                  selected: !_showEstimates,
                  onSelected: (_) => setState(() => _showEstimates = false),
                  selectedColor: AppColors.kTeal.withOpacity(0.15),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Estimates'),
                  selected: _showEstimates,
                  onSelected: (_) => setState(() => _showEstimates = true),
                  selectedColor: AppColors.kTeal.withOpacity(0.15),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () async {
                    final newInvoice = await Navigator.push<Invoice>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InvoiceEditorPage(
                          storage: widget.storage,
                          isEstimate: _showEstimates,
                        ),
                      ),
                    );
                    if (newInvoice != null) {
                      await widget.storage.saveInvoice(newInvoice);
                      widget.onChanged();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: Text(_showEstimates ? 'New Estimate' : 'New Invoice'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: invoices.length,
              itemBuilder: (_, i) {
                final inv = invoices[i];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    title: Text('${inv.number} • ${inv.customerName}'),
                    subtitle: Text(
                      '${_fmtDate(inv.date)} • £${inv.total.toStringAsFixed(2)} • ${inv.isEstimate ? "Estimate" : "Invoice"}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      onPressed: () => _showPdfOptions(inv),
                    ),
                    onTap: () async {
                      final edited = await Navigator.push<Invoice>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InvoiceEditorPage(
                            storage: widget.storage,
                            invoice: inv,
                            isEstimate: inv.isEstimate,
                          ),
                        ),
                      );
                      if (edited != null) {
                        await widget.storage.saveInvoice(edited);
                        widget.onChanged();
                      }
                    },
                    onLongPress: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete?'),
                          content: Text('Delete ${inv.number}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await widget.storage.deleteInvoice(inv.id);
                        widget.onChanged();
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _showPdfOptions(Invoice inv) async {
    final bytes = await _buildInvoicePdf(inv);
    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Preview / Print PDF'),
              onTap: () async {
                Navigator.pop(context);
                await Printing.layoutPdf(
                  onLayout: (_) async => bytes,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Email PDF'),
              onTap: () async {
                Navigator.pop(context);
                final file = await _writeTempFile(bytes, '${inv.number}.pdf');
                await Share.shareXFiles(
                  [XFile(file.path)],
                  subject:
                      '${inv.isEstimate ? "Estimate" : "Invoice"} ${inv.number}',
                  text:
                      'Please find attached your ${inv.isEstimate ? "estimate" : "invoice"} ${inv.number}.',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<File> _writeTempFile(Uint8List bytes, String name) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<Uint8List> _buildInvoicePdf(Invoice inv) async {
   final pdf = AppPdfDocument();

    final _accountStorage = AccountStorage();

    final s = _accountStorage.settings;
    pw.MemoryImage? logo;

    if (s.logoPath != null && s.logoPath!.isNotEmpty) {
      final Uint8List imageBytes = await File(s.logoPath!).readAsBytes();
      logo = pw.MemoryImage(imageBytes);
    }

    /*  String vatLabel(double r) {
      switch (r) {
        case 0:
          return '0%';
        case 5:
          return '5%';
        case 20:
          return '20%';
      }
      return '0%';
    }
*/
    pdf.addPage(
      pw.MultiPage(
        build: (_) => [
          if(logo != null)...[
            pw.Image(logo, width: 80, height: 80),
            pw.SizedBox(height: 8)
          ],
          pw.Text(
            inv.isEstimate ? 'Estimate ${inv.number}' : 'Invoice ${inv.number}',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Date: ${_fmtDate(inv.date)}'),
          if (inv.dueDate != null) pw.Text('Due: ${_fmtDate(inv.dueDate!)}'),
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
          pw.Text(inv.customerName),
         if(inv.customerAddress != null) pw.Text(inv.customerAddress),
          if(inv.customerEmail != null) pw.Text("Email :"+inv.customerEmail),
          if(inv.customerPhone != null) pw.Text("Phone :"+inv.customerPhone),
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
              ...inv.items.map(
                (item) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(item.description!),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(item.qty!.toStringAsFixed(0)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('£${item.price!.toStringAsFixed(2)}'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                          '£${(item.price! * item.qty!) * (item.vat! / 100)}'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('£${item.total.toStringAsFixed(2)}'),
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
                pw.Text('Subtotal: £${inv.subTotal.toStringAsFixed(2)}'),
                pw.Text('VAT : £${inv.vat.toStringAsFixed(2)}'),
                pw.Text(
                  'TOTAL: £${inv.total.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if(inv.notes != null && inv.notes.isNotEmpty)...[
            pw.SizedBox(height: 16),
            pw.Row(
              children: [
                pw.Text('Note: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),pw.Flexible(child: pw.Text('Note: ${inv.notes}', style: pw.TextStyle(fontWeight: pw.FontWeight.normal)))
              ]
            ),
          ]
        ],
      ),
    );

    return pdf.save();
  }
}
