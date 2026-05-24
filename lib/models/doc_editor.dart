/*import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:the_gas_man_app/app/app_model.dart';
import 'package:the_gas_man_app/models/company_settings.dart';
import 'package:the_gas_man_app/pages/new_invoice_page/data_model/all_models.dart';

import '../utils_class/app_pdf_documents.dart';

enum DocumentType { invoice, estimate, quote }

class LineItem {
  final TextEditingController desc = TextEditingController();
  final TextEditingController unit = TextEditingController(text: '0.00');
  final TextEditingController qty = TextEditingController(text: '1');

  double get unitPrice => double.tryParse(unit.text) ?? 0.0;
  int get quantity => int.tryParse(qty.text) ?? 0;
  double get total => unitPrice * quantity;
}

class DocEditorPage extends StatefulWidget {
  static const route = '/docs';
  const DocEditorPage({super.key});

  @override
  State<DocEditorPage> createState() => _DocEditorPageState();
}

class _DocEditorPageState extends State<DocEditorPage> {
  DocumentType docType = DocumentType.invoice;
  final TextEditingController docNumber = TextEditingController();
  DateTime docDate = DateTime.now();

  final TextEditingController billTo = TextEditingController();
  final TextEditingController jobAddress = TextEditingController();

  final List<LineItem> items = [LineItem()];

  double? vatRate;
  final currency = NumberFormat.currency(symbol: '£', decimalDigits: 2);

  double get subTotal => items.fold(0.0, (sum, it) => sum + it.total);
  double get vat => vatRate == null ? 0.0 : subTotal * (vatRate! / 100.0);
  double get grandTotal => subTotal + vat;

  String get docTypeLabel {
    switch (docType) {
      case DocumentType.invoice:
        return 'Invoice';
      case DocumentType.estimate:
        return 'Estimate';
      case DocumentType.quote:
        return 'Quote';
    }
  }

  @override
  void dispose() {
    for (final it in items) {
      it.desc.dispose();
      it.unit.dispose();
      it.qty.dispose();
    }
    docNumber.dispose();
    billTo.dispose();
    jobAddress.dispose();
    super.dispose();
  }

  void _addItem() => setState(() => items.add(LineItem()));

  void _removeItem(int index) {
    setState(() {
      final it = items.removeAt(index);
      it.desc.dispose();
      it.unit.dispose();
      it.qty.dispose();
    });
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: docDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => docDate = d);
  }

  Future<void> _sharePdf(AccountingSettings company) async {
   final pdf = AppPdfDocument();

    pw.Widget companyHeader() => pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 56,
          height: 56,
          decoration: pw.BoxDecoration(
            color: PdfColor.fromInt(0xFF0C7475), // teal
            borderRadius: pw.BorderRadius.circular(12),
          ),
        ),
        pw.SizedBox(width: 12),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(company.businessName,
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              if (company.businessAddress.isNotEmpty) pw.Text(company.businessAddress),
              pw.Text('${company.businessPhone}  •  ${company.businessEmail}'),
              // if (company.gasSafeNumber.isNotEmpty)
              //   pw.Text('Gas Safe: ${company.gasSafeNumber}'),
              if ((company.vatNumber ?? '').isNotEmpty)
                pw.Text('VAT: ${company.vatNumber}'),
            ],
          ),
        ),
        pw.Text(
          docTypeLabel.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromInt(0xFFF59E0B), // amber
          ),
        ),
      ],
    );

    pw.Widget keyValue(String k, String v) => pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(k,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text(v),
      ],
    );

    final tableHeaders = ['Description', 'Qty', 'Unit', 'Total'];
    final tableData = items
        .map((it) => [
      it.desc.text,
      it.quantity.toString(),
      currency.format(it.unitPrice),
      currency.format(it.total),
    ])
        .toList();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: await _pageTheme(),
        build: (ctx) => [
          companyHeader(),
          pw.SizedBox(height: 12),
          pw.Divider(),
          pw.SizedBox(height: 6),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Bill To',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(billTo.text.isEmpty ? '—' : billTo.text),
                    pw.SizedBox(height: 8),
                    pw.Text('Job Address',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(jobAddress.text.isEmpty ? '—' : jobAddress.text),
                  ],
                ),
              ),
              pw.SizedBox(width: 16),
              pw.SizedBox(
                width: 180,
                child: pw.Column(children: [
                  keyValue('Document #',
                      docNumber.text.isEmpty ? '—' : docNumber.text),
                  keyValue('Date', DateFormat('dd/MM/yyyy').format(docDate)),
                  keyValue('Type', docTypeLabel),
                ]),
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headers: tableHeaders,
            headerStyle:
            pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration:
            pw.BoxDecoration(color: PdfColor.fromInt(0xFFEFF4F7)),
            data: tableData,
            border: pw.TableBorder.all(
                color: PdfColor.fromInt(0xFFE5E7EB)),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding:
            const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Container(
                width: 240,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                      color: PdfColor.fromInt(0xFFE5E7EB)),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                padding: const pw.EdgeInsets.all(10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    keyValue('Sub Total', currency.format(subTotal)),
                    keyValue(
                      'VAT',
                      vatRate == null
                          ? 'No VAT'
                          : '${vatRate!.toStringAsFixed(0)}%  (${currency.format(vat)})',
                    ),
                    pw.Divider(),
                    keyValue('Total', currency.format(grandTotal)),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Thank you for your business.',
            style:
            pw.TextStyle(color: PdfColors.grey700),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  Future<pw.PageTheme> _pageTheme() async {
    return const pw.PageTheme(
      margin: pw.EdgeInsets.fromLTRB(32, 36, 32, 40),
    );
  }

  @override
  Widget build(BuildContext context) {
    final company = context.watch<AppModel>().storage.settings;
    return Scaffold(
      appBar: AppBar(
        title: Text(docTypeLabel),
        actions: [
          IconButton(
            tooltip: 'Share / Print PDF',
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _sharePdf(company),
          ),
          PopupMenuButton<DocumentType>(
            tooltip: 'Change type',
            initialValue: docType,
            onSelected: (v) => setState(() => docType = v),
            itemBuilder: (_) => const [
              PopupMenuItem(
                  value: DocumentType.invoice, child: Text('Invoice')),
              PopupMenuItem(
                  value: DocumentType.estimate, child: Text('Estimate')),
              PopupMenuItem(
                  value: DocumentType.quote, child: Text('Quote')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _companyHeaderCard(company),
          const SizedBox(height: 12),
          _metaRow(),
          const SizedBox(height: 8),
          _billToCard(),
          const SizedBox(height: 8),
          _itemsList(),
          const SizedBox(height: 8),
          _totalsCard(),
          const SizedBox(height: 42),
        ],
      ),
    );
  }

  Widget _companyHeaderCard(AccountingSettings c) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF0C7475), // teal
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${c.businessName}\n'
                    '${c.businessAddress}\n'
                    '${c.businessPhone}  •  ${c.businessEmail}\n'
                    'Gas Safe: ${c.gasSafeNumber}'
                    '${(c.vatNumber ?? '').isNotEmpty ? '\nVAT: ${c.vatNumber}' : ''}',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaRow() {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: docNumber,
                decoration: const InputDecoration(
                  labelText: 'Document #',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(docDate)),
                trailing:
                TextButton(onPressed: _pickDate, child: const Text('Change')),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _billToCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child:
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Bill To', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: billTo,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Customer / Company & Address',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Job Address (optional)',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: jobAddress,
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Where the job was carried out',
              border: OutlineInputBorder(),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _itemsList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child:
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              const Expanded(
                  child: Text('Line Items',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Line')),
            ],
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < items.length; i++) _itemRow(i),
        ]),
      ),
    );
  }

  Widget _itemRow(int i) {
    final it = items[i];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: it.desc,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextField(
              controller: it.qty,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Qty',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextField(
              controller: it.unit,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Unit (£)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Total',
                border: OutlineInputBorder(),
              ),
              child: Text(currency.format(it.total)),
            ),
          ),
          IconButton(
            tooltip: 'Remove',
            onPressed: () => _removeItem(i),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }

  Widget _totalsCard() {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints:  BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _row('Sub Total', currency.format(subTotal)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('VAT'),
                  const SizedBox(width: 8),
                  DropdownButton<double?>(
                    value: vatRate,
                    onChanged: (v) => setState(() => vatRate = v),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('No VAT')),
                      DropdownMenuItem(value: 0, child: Text('0%')),
                      DropdownMenuItem(value: 5, child: Text('5%')),
                      DropdownMenuItem(value: 20, child: Text('20%')),
                    ],
                  ),
                  const Spacer(),
                  Text(vatRate == null ? '—' : currency.format(vat)),
                ],
              ),
              const Divider(),
              _row('Total', currency.format(grandTotal),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _row(String k, String v, {TextStyle? style}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(k, style: style), Text(v, style: style)],
    );
  }
}*/
