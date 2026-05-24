import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:the_gas_man_app/services/email_service.dart';
import 'package:the_gas_man_app/services/reports_service.dart';
import 'package:the_gas_man_app/services/vat_return_service.dart';

import '../../../../services/customer_service.dart';
import '../../../../utils_class/app_pdf_documents.dart';
import '../../../../utils_class/money.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class VatSummaryScreen extends StatefulWidget {
  const VatSummaryScreen({super.key});

  @override
  State<VatSummaryScreen> createState() => _VatSummaryScreenState();
}

class _VatSummaryScreenState extends State<VatSummaryScreen> {
  final _svc = MasterDataService();
  final _reportService = ReportsService();
  final _vrs = VatReturnService();

  DateTime _dateFrom = DateTime(DateTime.now().year, 1, 1);
  DateTime _dateTo = DateTime.now();

  bool _loading = false;
  Map<String, dynamic>? _data;

  Map<String, String> vatReturnData = Map();
  Map<String, dynamic> vatApiData = Map();

  DateTime? returnFromDate;

  DateTime? returnToDate;

  /// Format for UI → dd/MM/yyyy
  String get displayFrom => DateFormat('dd/MM/yyyy').format(_dateFrom);

  String get displayTo => DateFormat('dd/MM/yyyy').format(_dateTo);

  /// Format for API → yyyy-MM-dd
  String get apiFrom => DateFormat('yyyy-MM-dd').format(_dateFrom);

  String get apiTo => DateFormat('yyyy-MM-dd').format(_dateTo);

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _dateFrom : _dateTo,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          _dateFrom = picked;
        } else {
          _dateTo = picked;
        }
      });
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _data = await _svc.getVatSummary(
        dateFrom: apiFrom, // API format
        dateTo: apiTo, // API format
      );
      vatApiData =
          await _reportService.vatReturn(dateFrom: apiFrom, dateTo: apiTo);
    } catch (e) {
      debugPrint("Failed to load VAT summary: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double _num(String key) {
    final v = _data?[key];
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final salesBreakdown = (_data?["salesBreakdown"] as List?) ?? [];
    final purchasesBreakdown = (_data?["purchasesBreakdown"] as List?) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("VAT Summary"),
        actions: [
          IconButton(
              onPressed: () async {
                final pdf = await VatPdfService.generateVatPdf(
                  dateFrom: _dateFrom,
                  dateTo: _dateTo,
                  summaryData: _data ?? {},
                  vatReturnValues: vatApiData,
                  // from widget
                  returnFrom: _dateFrom,
                  returnTo: _dateTo,
                );

                await Printing.layoutPdf(
                  onLayout: (format) async => pdf.save(),
                );
              },
              icon: Icon(Icons.picture_as_pdf)),
          IconButton(
              onPressed: () async {
                _showEmailDialog(context);
              },
              icon: Icon(Icons.email)),
          IconButton(
            tooltip: "Refresh",
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading ? Center(child: CircularProgressIndicator(),): ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// Date From
          TextField(
            readOnly: true,
            controller: TextEditingController(text: displayFrom),
            decoration: const InputDecoration(
              labelText: "Date From",
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onTap: () => _pickDate(isFrom: true),
          ),

          const SizedBox(height: 8),

          /// Date To
          TextField(
            readOnly: true,
            controller: TextEditingController(text: displayTo),
            decoration: const InputDecoration(
              labelText: "Date To",
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onTap: () => _pickDate(isFrom: false),
          ),

          const SizedBox(height: 12),

          FilledButton(
            onPressed: _loading ? null : _load,
            child: _loading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text("Load VAT Summary"),
          ),

          const SizedBox(height: 16),

          /// Summary Cards
          Card(
            child: ListTile(
              title: const Text("VAT Collected"),
              trailing: Text(formatMoney(_num("vatCollected"))),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text("VAT Paid"),
              trailing: Text(formatMoney(_num("vatPaid"))),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text("VAT Owed"),
              trailing: Text(
                formatMoney(_num("vatOwed")),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// Sales Breakdown
          const Text(
            "Sales Breakdown",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...salesBreakdown.map((e) {
            final row = e as Map<String, dynamic>;
            return Card(
              child: ListTile(
                title: Text(row["label"]?.toString() ?? "Sales"),
                trailing: Text(
                  formatMoney((row["amount"] as num?)?.toDouble() ?? 0),
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          /// Purchases Breakdown
          const Text(
            "Purchases Breakdown",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...purchasesBreakdown.map((e) {
            final row = e as Map<String, dynamic>;
            return Card(
              child: ListTile(
                title: Text(row["label"]?.toString() ?? "Purchases"),
                trailing: Text(
                  formatMoney((row["amount"] as num?)?.toDouble() ?? 0),
                ),
              ),
            );
          }),
          VatReturnWidget(
            vatApiData: vatApiData,
            fromDate: apiFrom,
            toDate: apiTo,
            onChanged: (Map<String, String> vatReturnData, DateTime? rFromDate,
                DateTime? rToDate) {
              this.vatReturnData = vatReturnData;
              this.returnFromDate = rFromDate;
              this.returnToDate = rToDate;
            },
          )
        ],
      ),
    );
  }

  Future<void> _showEmailDialog(BuildContext context) async {
    final emailCtrl = TextEditingController();

    DateTime? fromDate;
    DateTime? toDate;

    final formKey = GlobalKey<FormState>();
    bool sending = false;

    String formatDate(DateTime date) {
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    }

    Future<void> pickFromDate(StateSetter setState) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: fromDate ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );

      if (picked != null) {
        setState(() => fromDate = picked);
      }
    }

    Future<void> pickToDate(StateSetter setState) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: toDate ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );

      if (picked != null) {
        setState(() => toDate = picked);
      }
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Send VAT Summary"),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// 📧 Email
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

                      /// 📅 FROM DATE
                      InkWell(
                        onTap: () => pickFromDate(setState),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: "From Date",
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            fromDate != null
                                ? formatDate(fromDate!)
                                : "Select From Date",
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// 📅 TO DATE
                      InkWell(
                        onTap: () => pickToDate(setState),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: "To Date",
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            toDate != null
                                ? formatDate(toDate!)
                                : "Select To Date",
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
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

                          if (fromDate == null || toDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Select date range")),
                            );
                            return;
                          }

                          setState(() => sending = true);

                          try {
                            await EmailService().sendVatSummaryEmail(
                              toEmail: emailCtrl.text,
                              dateFrom: formatDate(fromDate!),
                              dateTo: formatDate(toDate!),
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
}

class VatReturnWidget extends StatefulWidget {
  final Function(Map<String, String>, DateTime?, DateTime?) onChanged;
  final Map<String, dynamic> vatApiData;
  final String? fromDate;
  final String? toDate;

  const VatReturnWidget(
      {super.key, required this.onChanged, required this.vatApiData,this.fromDate,this.toDate});

  @override
  State<VatReturnWidget> createState() => _VatReturnWidgetState();
}

class _VatReturnWidgetState extends State<VatReturnWidget> {
  final Map<String, TextEditingController> controllers = {};
  final Map<String, DateTime?> rowDates = {};

  DateTime? fromDate;
  DateTime? toDate;

  TextEditingController getController(String key) {
    return controllers.putIfAbsent(key, () => TextEditingController());
  }

  double getValue(String key) {
    return double.tryParse(getController(key).text) ?? 0;
  }

  /// 🔥 SEND DATA TO PARENT
  void notifyParent() {
    final data = controllers.map((key, controller) {
      return MapEntry(key, controller.text);
    });

    widget.onChanged(data, fromDate, toDate);
  }

  String formatDate(DateTime? date) {
    if (date == null) return "Select Date";
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> pickRowDate(String key) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: rowDates[key] ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => rowDates[key] = picked);
      notifyParent();
    }
  }

  Future<void> pickFromToDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          isFrom ? (fromDate ?? DateTime.now()) : (toDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });

      notifyParent(); // 🔥 IMPORTANT
    }
  }

  @override
  void dispose() {
    for (var c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box1 = getValue("VAT due on sales and other outputs");
    final box2 =
        getValue("VAT due on acquisitions from other EC Member States");
    final box3 = box1 + box2;
    final box4 = getValue("VAT reclaimed on purchases and other inputs");
    final box5 = box3 - box4;

    return Container(
      color: Colors.grey.shade200,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          /// HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.green,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "VAT Return",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        color: Colors.white,
                        child: Text(
                          widget.fromDate!,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        color: Colors.white,
                        child: Text(
                          widget.toDate!,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// BODY
          Column(
            children: [
              vatRow("VAT due on sales and other outputs", "1"),
              vatRow(
                  "VAT due on acquisitions from other EC Member States", "2"),
              displayRow("Total VAT due (1 + 2)", "3", box3),
              vatRow("VAT reclaimed on purchases and other inputs", "4"),
              highlightDisplayRow("Net VAT (3 - 4)", "5", box5),
              vatRow("Total value of sales excluding VAT", "6"),
              vatRow("Total value of purchases excluding VAT", "7"),
              vatRow("Supplies to EC member states", "8"),
              vatRow("Acquisitions from EC member states", "9"),
            ],
          ),
        ],
      ),
    );
  }

  Widget vatRow(String title, String box) {
    final controller = getController(title);
    if (widget.vatApiData != null && widget.vatApiData['boxes'] != null) {
      controller.text = widget.vatApiData['boxes']['box$box'].toString() ?? "";
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Container(
            width: 35,
            height: 45,
            color: Colors.green,
            alignment: Alignment.center,
            child: Text(box, style: const TextStyle(color: Colors.white)),
          ),
          Container(
            width: 100,
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(border: Border.all(color: Colors.green)),
            child: TextField(
              controller: controller,
              enabled: false,
              style: TextStyle(
                color: Colors.black
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                border: InputBorder.none,

                // prefixText: "£ ",
              ),
              onChanged: (_) {
                setState(() {});
                notifyParent(); // 🔥 IMPORTANT
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget displayRow(String title, String box, double value) {
    if (widget.vatApiData != null && widget.vatApiData['boxes'] != null) {
      value = double.tryParse(widget.vatApiData['boxes']['box$box'].toString()) ?? 0.0;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          boxUI(box),
          valueUI(value),
        ],
      ),
    );
  }

  Widget highlightDisplayRow(String title, String box, double value) {
    if (widget.vatApiData != null && widget.vatApiData['boxes'] != null) {
      value = double.tryParse(widget.vatApiData['boxes']['box$box'].toString()) ?? 0;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      color: Colors.green,
      child: Row(
        children: [
          Expanded(
              child: Text(title, style: const TextStyle(color: Colors.white))),
          boxUI(box, dark: true),
          valueUI(value, bold: true),
        ],
      ),
    );
  }

  Widget boxUI(String box, {bool dark = false}) {
    return Container(
      width: 35,
      height: 45,
      color: dark ? Colors.green.shade800 : Colors.green,
      alignment: Alignment.center,
      child: Text(box, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget valueUI(double value, {bool bold = false}) {
    return Container(
      width: 90,
      height: 45,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        color: Colors.white,
      ),
      child: Text(
        value.toStringAsFixed(2),
        style:
            TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal),
      ),
    );
  }
}

class VatPdfService {
  static Future<pw.Document> generateVatPdf({
    required DateTime dateFrom,
    required DateTime dateTo,
    required Map<String, dynamic> summaryData,
    required Map<String, dynamic> vatReturnValues,
    required DateTime? returnFrom,
    required DateTime? returnTo,
  }) async {
    final pdf = AppPdfDocument();

    String formatDate(DateTime? d) {
      if (d == null) return "-";
      return DateFormat('dd/MM/yyyy').format(d);
    }

    double getNum(String key) {
      final v = summaryData[key];
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    final sales = (summaryData["salesBreakdown"] as List?) ?? [];
    final purchases = (summaryData["purchasesBreakdown"] as List?) ?? [];

    pw.Widget sectionTitle(String text) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 10, top: 20),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      );
    }

    pw.Widget infoRow(String title, String value,
        {bool bold = false}) {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 6),
        child: pw.Row(
          mainAxisAlignment:
          pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Text(
                title,
                style: pw.TextStyle(
                  fontWeight: bold
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal,
                ),
              ),
            ),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontWeight: bold
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    }

    pw.Widget tableHeader(String text) {
      return pw.Padding(
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
      );
    }

    pw.Widget tableCell(String text) {
      return pw.Padding(
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(
          text,
          style: const pw.TextStyle(fontSize: 10),
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          /// HEADER
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.green700,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment:
              pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "VAT SUMMARY REPORT",
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 8),

                pw.Text(
                  "From: ${formatDate(dateFrom)}",
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                  ),
                ),

                pw.Text(
                  "To: ${formatDate(dateTo)}",
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                  ),
                ),
              ],
            ),
          ),

          /// SUMMARY
          sectionTitle("VAT Summary"),

          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                color: PdfColors.grey400,
              ),
              borderRadius:
              pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              children: [
                infoRow(
                  "VAT Collected",
                  "£${getNum("vatCollected").toStringAsFixed(2)}",
                ),

                infoRow(
                  "VAT Paid",
                  "£${getNum("vatPaid").toStringAsFixed(2)}",
                ),

                pw.Divider(),

                infoRow(
                  "VAT Owed",
                  "£${getNum("vatOwed").toStringAsFixed(2)}",
                  bold: true,
                ),
              ],
            ),
          ),

          /// SALES BREAKDOWN
          sectionTitle("Sales Breakdown"),

          pw.Table(
            border: pw.TableBorder.all(
              color: PdfColors.grey400,
            ),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: PdfColors.green700,
                ),
                children: [
                  tableHeader("Description"),
                  tableHeader("Amount"),
                ],
              ),

              ...sales.map((e) {
                final row =
                e as Map<String, dynamic>;

                return pw.TableRow(
                  children: [
                    tableCell(
                      row["label"]
                          ?.toString() ??
                          "",
                    ),

                    tableCell(
                      "£${((row["amount"] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}",
                    ),
                  ],
                );
              }),
            ],
          ),

          /// PURCHASE BREAKDOWN
          sectionTitle("Purchases Breakdown"),

          pw.Table(
            border: pw.TableBorder.all(
              color: PdfColors.grey400,
            ),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: PdfColors.green700,
                ),
                children: [
                  tableHeader("Description"),
                  tableHeader("Amount"),
                ],
              ),

              ...purchases.map((e) {
                final row =
                e as Map<String, dynamic>;

                return pw.TableRow(
                  children: [
                    tableCell(
                      row["label"]
                          ?.toString() ??
                          "",
                    ),

                    tableCell(
                      "£${((row["amount"] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}",
                    ),
                  ],
                );
              }),
            ],
          ),

          /// VAT RETURN
          /// VAT RETURN
          sectionTitle("VAT Return"),

          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                color: PdfColors.green700,
              ),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(10),
                  color: PdfColors.green700,
                  child: pw.Text(
                    "VAT Return Period",
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),

                pw.SizedBox(height: 10),

                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.green700),
                        ),
                        child: pw.Text(
                          "From: ${formatDate(returnFrom)}",
                        ),
                      ),
                    ),

                    pw.SizedBox(width: 10),

                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.green700),
                        ),
                        child: pw.Text(
                          "To: ${formatDate(returnTo)}",
                        ),
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 16),

                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColors.green700,
                    width: 1,
                  ),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(5),
                    1: const pw.FlexColumnWidth(1),
                    2: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    /// HEADER
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.green700,
                      ),
                      children: [
                        tableHeader("Description"),
                        tableHeader("Box"),
                        tableHeader("Value"),
                      ],
                    ),

                    /// ROWS
                    vatPdfRow(
                      "VAT due on sales and other outputs",
                      "1",
                      vatReturnValues['boxes']['box1'].toString() ?? "",
                    ),

                    vatPdfRow(
                      "VAT due on acquisitions from other EC Member States",
                      "2",
                      vatReturnValues['boxes']['box2'].toString() ??
                          "",
                    ),

                    vatPdfRow(
                      "Total VAT due (1 + 2)",
                      "3",
                      double.parse(vatReturnValues['boxes']['box3'].toString()).toStringAsFixed(2) ?? "",
                    ),

                    vatPdfRow(
                      "VAT reclaimed on purchases and other inputs",
                      "4",
                      vatReturnValues['boxes']['box4'].toString() ??
                          "",
                    ),

                    vatPdfRow(
                      "Net VAT (3 - 4)",
                      "5",
                      double.parse(vatReturnValues['boxes']['box5'].toString()).toStringAsFixed(2) ?? "",
                      highlight: true,
                    ),

                    vatPdfRow(
                      "Total value of sales excluding VAT",
                      "6",
                      vatReturnValues['boxes']['box6'].toString() ??
                          "",
                    ),

                    vatPdfRow(
                      "Total value of purchases excluding VAT",
                      "7",
                      vatReturnValues['boxes']['box7'].toString() ??
                          "",
                    ),

                    vatPdfRow(
                      "Supplies to EC member states",
                      "8",
                      vatReturnValues['boxes']['box8'].toString() ?? "",
                    ),

                    vatPdfRow(
                      "Acquisitions from EC member states",
                      "9",
                      vatReturnValues['boxes']['box9'].toString() ??
                          "",
                    ),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 30),

          /// FOOTER
          pw.Center(
            child: pw.Text(
              "Generated by The Gas Man App",
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
          ),
        ],
      ),
    );

    return pdf;
  }

  static pw.TableRow vatPdfRow(
      String title,
      String box,
      String value, {
        bool highlight = false,
      }) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(
        color: highlight
            ? PdfColors.green100
            : PdfColors.white,
      ),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontWeight: highlight
                  ? pw.FontWeight.bold
                  : pw.FontWeight.normal,
              fontSize: 10,
            ),
          ),
        ),

        pw.Container(
          alignment: pw.Alignment.center,
          padding: const pw.EdgeInsets.all(8),
          color: PdfColors.green700,
          child: pw.Text(
            box,
            style: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),

        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            value.isEmpty ? "-" : value,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              fontWeight: highlight
                  ? pw.FontWeight.bold
                  : pw.FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
