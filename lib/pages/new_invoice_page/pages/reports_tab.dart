import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:the_gas_man_app/theme/app_theme.dart';

import '../../../utils_class/app_pdf_documents.dart';
import '../account_storage_file.dart';
import '../common_ui/expense_pie_chart.dart';
import '../common_ui/vat_bar_chart.dart';



class ReportsTab extends StatefulWidget {
  final AccountStorage storage;
  const ReportsTab({super.key, required this.storage});

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  String _period = 'month'; // month / quarter / year

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    late DateTime start;
    late DateTime end;

    if (_period == 'month') {
      start = DateTime(now.year, now.month, 1);
      end = DateTime(now.year, now.month + 1, 0);
    } else if (_period == 'quarter') {
      final q = ((now.month - 1) ~/ 3) + 1;
      final startMonth = (q - 1) * 3 + 1;
      start = DateTime(now.year, startMonth, 1);
      end = DateTime(now.year, startMonth + 3, 0);
    } else {
      start = DateTime(now.year, 1, 1);
      end = DateTime(now.year, 12, 31);
    }

    bool inRange(DateTime d) => !d.isBefore(start) && !d.isAfter(end);

    final invoices = widget.storage.invoices
        .where((i) => !i.isEstimate && inRange(i.date));
    final expenses = widget.storage.expenses.where((e) => inRange(e.date));

    final income = invoices.fold(0.0, (s, i) => s + i.total);
    final expensesTotal = expenses.fold(0.0, (s, e) => s + e.amount);
    final profit = income - expensesTotal;

    final incomeVat = invoices.fold(0.0, (s, i) => s + i.vat);
    final expensesVat = expenses.fold(
      0.0,
          (s, e) => s + (double.tryParse(e.vat.toString()) ?? 0),
    );
    final vatDue = incomeVat - expensesVat;
    print("Expense Vat ${expensesVat}");

    // Expense categories for pie chart
    final Map<String, double> catTotals = {};
    for (final e in expenses) {
      catTotals[e.category] = (catTotals[e.category] ?? 0) + e.amount;
    }

    return Container(
      color: AppColors.kLightBg,
      padding: const EdgeInsets.all(12),
      child: ListView(
        children: [
          Row(
            children: [
              const Text('Period:'),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _period,
                items: const [
                  DropdownMenuItem(value: 'month', child: Text('This month')),
                  DropdownMenuItem(value: 'quarter', child: Text('This quarter')),
                  DropdownMenuItem(value: 'year', child: Text('This year')),
                ],
                onChanged: (v) => setState(() => _period = v ?? 'month'),
              ),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kTeal,
                  foregroundColor: Colors.white,
                ),
                onPressed: _exportTaxPack,
                icon: const Icon(Icons.folder_zip_outlined),
                label: const Text('Export Tax Pack'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _card(
            'Income & Expenses',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _line('Income', income),
                _line('Expenses', expensesTotal),
                const Divider(),
                _line('Profit', profit, bold: true),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _card(
            'VAT Summary',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _line('VAT on Sales', incomeVat),
                _line('VAT on Purchases', expensesVat),
                const Divider(),
                _line('VAT Due (to HMRC)', vatDue, bold: true),
                const SizedBox(height: 12),
                VatBarChart(vatSales: incomeVat, vatPurchases: expensesVat),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _card(
            'Expenses by Category',
            ExpensePieChart(data: catTotals),
          ),
        ],
      ),
    );
  }

  Widget _card(String title, Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: kSectionTitleStyle),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _line(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '£${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- TAX PACK EXPORT ----------------

  Future<void> _exportTaxPack() async {
    final now = DateTime.now();
    final year = now.year;

    // Gather all invoices & expenses for the whole year
    final start = DateTime(year, 1, 1);
    final end = DateTime(year, 12, 31);

    bool inRange(DateTime d) => !d.isBefore(start) && !d.isAfter(end);

    final invoices =
    widget.storage.invoices.where((i) => !i.isEstimate && inRange(i.date));
    final expenses =
    widget.storage.expenses.where((e) => inRange(e.date));

    // Build CSVs
    final invoiceCsv = StringBuffer()
      ..writeln(
          'Number,Date,Customer,Net,VAT,Total,Status');
    for (final i in invoices) {
      invoiceCsv.writeln(
          '${i.number},${i.date.toIso8601String()},${i.customerName.replaceAll(',', ' ')},${i.subTotal.toStringAsFixed(2)},${i.vat.toStringAsFixed(2)},${i.total.toStringAsFixed(2)},${i.status.name}');
    }

    final expenseCsv = StringBuffer()
      ..writeln('Date,Category,Supplier,Amount,VAT');
    for (final e in expenses) {
      expenseCsv.writeln(
          '${e.date.toIso8601String()},${e.category.replaceAll(',', ' ')},${e.supplier.replaceAll(',', ' ')},${e.amount.toStringAsFixed(2)},${e.vat.toStringAsFixed(2)}');
    }

    // Build summary PDF (P&L + VAT)
   final pdf = AppPdfDocument();
    final totalIncome = invoices.fold(0.0, (s, i) => s + i.total);
    final totalExpenses = expenses.fold(0.0, (s, e) => s + e.amount);
    final incomeVat = invoices.fold(0.0, (s, i) => s + i.vat);
    final expensesVat = expenses.fold(0.0, (s, e) => s + e.vat);
    final profit = totalIncome - totalExpenses;
    final vatDue = incomeVat - expensesVat;

    pdf.addPage(
      pw.MultiPage(
        build: (_) => [
          pw.Text(
            'Tax Pack Summary $year',
            style:
            pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 16),
          pw.Text('Profit & Loss'),
          pw.SizedBox(height: 8),
          pw.Text('Total Income: £${totalIncome.toStringAsFixed(2)}'),
          pw.Text('Total Expenses: £${totalExpenses.toStringAsFixed(2)}'),
          pw.Text('Profit: £${profit.toStringAsFixed(2)}'),
          pw.SizedBox(height: 16),
          pw.Text('VAT Summary'),
          pw.SizedBox(height: 8),
          pw.Text('VAT on Sales: £${incomeVat.toStringAsFixed(2)}'),
          pw.Text('VAT on Purchases: £${expensesVat.toStringAsFixed(2)}'),
          pw.Text('VAT Due: £${vatDue.toStringAsFixed(2)}'),
        ],
      ),
    );

    final pdfBytes = await pdf.save();

    // Create ZIP in temp dir
    final tempDir = await getTemporaryDirectory();
    final zipPath = '${tempDir.path}/gasman_tax_pack_$year.zip';

    final encoder = ZipFileEncoder();
    encoder.create(zipPath);
    encoder.addFile(
      await _writeTemp(tempDir.path, 'invoices_$year.csv', invoiceCsv.toString()),
    );
    encoder.addFile(
      await _writeTemp(tempDir.path, 'expenses_$year.csv', expenseCsv.toString()),
    );
    encoder.addFile(
      await _writeTempBytes(tempDir.path, 'summary_$year.pdf', pdfBytes),
    );
    encoder.close();

    await Share.shareXFiles(
      [XFile(zipPath)],
      subject: 'Tax Pack $year - The Gas Man',
      text: 'ZIP file contains invoices, expenses and summary for $year.',
    );
  }

  Future<File> _writeTemp(
      String dir, String name, String content) async {
    final f = File('$dir/$name');
    await f.writeAsString(content, flush: true);
    return f;
  }

  Future<File> _writeTempBytes(
      String dir, String name, Uint8List bytes) async {
    final f = File('$dir/$name');
    await f.writeAsBytes(bytes, flush: true);
    return f;
  }
}
