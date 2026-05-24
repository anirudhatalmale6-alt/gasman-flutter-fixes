import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:signature/signature.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils_class/app_pdf_documents.dart';
import '../../../utils_class/utils.dart';
import '../../new_invoice_page/account_storage_file.dart';
import '../../new_tax_and_invoice/pages/customer/customer_list_screen.dart';

/// ================= MODEL =================
class BreakdownRecord {
  final String id;
  final String customer;
  final String address;
  final String fault;
  final String diagnosis;
  final String parts;
  final String work;
  final String timeOnSite;
  final String? engineerSignature;
  final String? customerSignature;
  final DateTime createdAt;

  BreakdownRecord({
    required this.id,
    required this.customer,
    required this.address,
    required this.fault,
    required this.diagnosis,
    required this.parts,
    required this.work,
    required this.timeOnSite,
    this.engineerSignature,
    this.customerSignature,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory BreakdownRecord.fromJson(Map<String, dynamic> json) {
    return BreakdownRecord(
      id: json['id'],
      customer: json['customer'] ?? '',
      address: json['address'] ?? '',
      fault: json['fault'] ?? '',
      diagnosis: json['diagnosis'] ?? '',
      parts: json['parts'] ?? '',
      work: json['work'] ?? '',
      timeOnSite: json['timeOnSite'] ?? '',
      engineerSignature: json['engineerSignature'],
      customerSignature: json['customerSignature'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "customer": customer,
        "address": address,
        "fault": fault,
        "diagnosis": diagnosis,
        "parts": parts,
        "work": work,
        "timeOnSite": timeOnSite,
        "engineerSignature": engineerSignature,
        "customerSignature": customerSignature,
        "createdAt": createdAt.toIso8601String(),
      };
}

/// ================= UI =================
class BreakdownRecordPage extends StatefulWidget {
  final BreakdownRecord? breakdownRecord;

  const BreakdownRecordPage({super.key, this.breakdownRecord});

  @override
  State<BreakdownRecordPage> createState() => _BreakdownRecordPageState();
}

class _BreakdownRecordPageState extends State<BreakdownRecordPage> {
  final customer = TextEditingController();
  final address = TextEditingController();
  final fault = TextEditingController();
  final diagnosis = TextEditingController();
  final parts = TextEditingController();
  final work = TextEditingController();
  final timeOnSite = TextEditingController();

  // final sigEng = SignatureController(penStrokeWidth: 2);
  // final sigCust = SignatureController(penStrokeWidth: 2);

  Uint8List? _engineerSignatureBytes;
  Uint8List? _customerSignatureBytes;

  SignatureController sigEng = SignatureController();
  SignatureController sigCust = SignatureController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.breakdownRecord != null) {
      setRecord(widget.breakdownRecord!);
    }
  }

  @override
  void dispose() {
    customer.dispose();
    address.dispose();
    fault.dispose();
    diagnosis.dispose();
    parts.dispose();
    work.dispose();
    timeOnSite.dispose();
    sigEng.dispose();
    sigCust.dispose();
    super.dispose();
  }

  void setRecord(BreakdownRecord r) {
    customer.text = r.customer;
    address.text = r.address;
    fault.text = r.fault;
    diagnosis.text = r.diagnosis;
    parts.text = r.parts;
    work.text = r.work;
    timeOnSite.text = r.timeOnSite;

    /// LOAD EXISTING SIGNATURES
    if (r.engineerSignature != null) {
      _engineerSignatureBytes = base64Decode(r.engineerSignature!);
    }

    if (r.customerSignature != null) {
      _customerSignatureBytes = base64Decode(r.customerSignature!);
    }

    setState(() {});
  }

  /// ================= SAVE =================
  Future<void> _saveRecord() async {
    final prefs = await SharedPreferences.getInstance();

    /// 👇 GET NEW SIGNATURE FROM CANVAS
    final engDrawn = await sigEng.toPngBytes();
    final custDrawn = await sigCust.toPngBytes();

    /// 👇 IF USER DRAWS → UPDATE BYTES
    if (engDrawn != null) {
      _engineerSignatureBytes = engDrawn;
    }

    if (custDrawn != null) {
      _customerSignatureBytes = custDrawn;
    }

    final record = BreakdownRecord(
      id: widget.breakdownRecord?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      customer: customer.text.trim(),
      address: address.text.trim(),
      fault: fault.text.trim(),
      diagnosis: diagnosis.text.trim(),
      parts: parts.text.trim(),
      work: work.text.trim(),
      timeOnSite: timeOnSite.text.trim(),
      engineerSignature: _engineerSignatureBytes != null
          ? base64Encode(_engineerSignatureBytes!)
          : null,
      customerSignature: _customerSignatureBytes != null
          ? base64Encode(_customerSignatureBytes!)
          : null,
    );

    final String? data = prefs.getString('breakdown_records');

    List list = [];
    if (data != null) {
      list = jsonDecode(data);
    }

    final index = list.indexWhere((e) => e['id'] == record.id);

    if (index != -1) {
      list[index] = record.toJson();
    } else {
      list.add(record.toJson());
    }

    await prefs.setString('breakdown_records', jsonEncode(list));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(index != -1
            ? "Record updated successfully"
            : "Record saved successfully"),
      ),
    );

    Navigator.pop(context);
  }

  /// ================= PDF =================
  Future<void> _pdf() async {
    final pdf = AppPdfDocument();

    final engPng = _engineerSignatureBytes;
    final custPng = _customerSignatureBytes;

    final accountStorage = AccountStorage();
    await accountStorage.load();
    final s = accountStorage.settings;
    pw.MemoryImage? logo;
    if (s.logoPath != null && s.logoPath!.isNotEmpty) {
      final Uint8List imageBytes = await File(s.logoPath!).readAsBytes();
      logo = pw.MemoryImage(imageBytes);
    }
    pw.Widget boolRow(String label, bool value) {
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(value ? 'Yes' : 'No'),
        ],
      );
    }

    final gasSafeLogo = await imageFromAssetBundle(
      'assets/ic_gas_safe.png',
    );

    pw.Widget row(String a, String b) => pw.Row(children: [
          pw.SizedBox(
              width: 150,
              child: pw.Text(a,
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.grey700))),
          pw.Expanded(child: pw.Text(b))
        ]);

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(16),
        build: (_) => [
          pw.Center(
            child: pw.Text(
              'BREAKDOWN / REPAIR RECORD',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 8),
          if (logo != null) ...[
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
              pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Image(gasSafeLogo, width: 60, height: 60)),
              pw.SizedBox(width: 8),
              pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Image(logo, width: 60, height: 60))
            ]),
            pw.SizedBox(height: 8)
          ],
          _box([
            row('Customer', customer.text),
            row('Address', address.text),
            row('Fault', fault.text),
            row('Diagnosis', diagnosis.text),
            row('Parts', parts.text),
            row('Time', timeOnSite.text),
          ]),
          pw.SizedBox(height: 10),
          pw.Text('Work carried out'),
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(border: pw.Border.all()),
            child: pw.Text(work.text),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(children: [
                  pw.Text('Engineer Signature'),
                  if (engPng != null)
                    pw.Image(pw.MemoryImage(engPng), height: 60),
                ]),
              ),
              pw.Expanded(
                child: pw.Column(children: [
                  pw.Text('Customer Signature'),
                  if (custPng != null)
                    pw.Image(pw.MemoryImage(custPng), height: 60),
                ]),
              ),
            ],
          ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/breakdown_${DateTime.now().millisecondsSinceEpoch}.pdf');

    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], subject: 'Breakdown Record');
  }

  pw.Widget _box(List<pw.Widget> kids) => pw.Container(
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(border: pw.Border.all()),
        child: pw.Column(children: kids),
      );

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Breakdown Record')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section("Customer Details", [
            _tf('Customer Name', customer),
            _tf('Address', address, lines: 2),
          ], onCustomerButtonClick: () async {
            dynamic customerD = await push(CustomerListScreen(
              fromScreen: "invoice",
            ));
            if (customerD != null) {
              customer.text = customerD["name"]?.toString() ?? "";

              address.text = customerD["address"]?.toString() ?? "";
            }
          }),
          const SizedBox(height: 16),
          _section("Fault Details", [
            _tf('Fault reported', fault, lines: 2),
            _tf('Diagnosis', diagnosis, lines: 2),
          ]),
          const SizedBox(height: 16),
          _section("Work Details", [
            _tf('Parts used / required', parts, lines: 2),
            _tf('Work carried out', work, lines: 3),
            _tf('Time on site', timeOnSite),
          ]),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _sig(
                  'Engineer Signature',
                  sigEng,
                  _engineerSignatureBytes,
                  () => _engineerSignatureBytes = null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _sig(
                  'Customer Signature',
                  sigCust,
                  _customerSignatureBytes,
                  () => _customerSignatureBytes = null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saveRecord,
                  icon: const Icon(Icons.save),
                  label: const Text("Save"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pdf,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("PDF"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children,
      {Function? onCustomerButtonClick}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16),
                ),
                if (onCustomerButtonClick != null)
                  IconButton(
                      onPressed: () {
                        onCustomerButtonClick();
                      },
                      icon: Icon(Icons.person_search_rounded))
              ],
            ),
            const SizedBox(height: 10),
            ...children.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: e,
                )),
          ],
        ),
      ),
    );
  }

  Widget _tf(String label, TextEditingController c, {int lines = 1}) {
    return TextField(
      controller: c,
      minLines: lines,
      maxLines: lines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _sig(
    String title,
    SignatureController controller,
    Uint8List? bytes,
    VoidCallback onClear,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),

            /// 🖊 ALWAYS SHOW DRAW AREA
            Container(
              height: 120,
              color: Colors.white,
              child: Signature(
                controller: controller,
                backgroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 6),

            /// 👇 SHOW OLD SIGNATURE (PREVIEW)
            if (bytes != null)
              Container(
                height: 60,
                decoration: BoxDecoration(border: Border.all()),
                child: Image.memory(bytes),
              ),

            Row(
              children: [
                TextButton(
                  onPressed: () {
                    controller.clear();
                    onClear();
                    setState(() {});
                  },
                  child: const Text('Clear'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
