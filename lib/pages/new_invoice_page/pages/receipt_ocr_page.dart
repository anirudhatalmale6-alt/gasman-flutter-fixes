import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/api_service/receipt_ocr_service.dart';

import '../../../utils_class/utils.dart';
import '../../finance/common_ui/outlined_group.dart';
import '../../finance/expense_form_page.dart';
import '../account_storage_file.dart';
import '../data_model/all_models.dart';

class ReceiptOcrPage extends StatefulWidget {
  final AccountStorage storage;
  final VoidCallback onChanged;

  const ReceiptOcrPage({
    super.key,
    required this.storage,
    required this.onChanged,
  });

  @override
  State<ReceiptOcrPage> createState() => _ReceiptOcrPageState();
}

class _ReceiptOcrPageState extends State<ReceiptOcrPage> {
  File? image;
  String text = '';
  final picker = ImagePicker();
  final categoryCtrl = TextEditingController(text: '');
  final supplierCtrl = TextEditingController();
  final netCtrl = TextEditingController();
  final vatCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  DateTime date = DateTime.now();
  //final recognizer = TextRecognizer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Scan Receipt (OCR)'),
      // ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: hook to camera OCR.
                    _pick(ImageSource.camera);
                  },
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Camera'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: hook to gallery OCR.
                    _pick(ImageSource.gallery);
                  },
                  icon: const Icon(Icons.photo_outlined),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('No text recognised yet'),
          const SizedBox(height: 12),
          OutlinedGroup(
            label: 'Category',
            child: TextField(
              controller: categoryCtrl,
              decoration: const InputDecoration(border: InputBorder.none,hintText: "Add category..."),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedGroup(
            label: 'Supplier',
            child: TextField(
              controller: supplierCtrl,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedGroup(
                  label: 'Net (£)',
                  child: TextField(
                    controller: netCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedGroup(
                  label: 'VAT (£)',
                  child: TextField(
                    controller: vatCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedGroup(
            label: 'Date',
            child: InkWell(
              onTap: () async {
                _pickDate();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatDate(date)),
                    const Icon(Icons.edit_calendar_outlined, size: 18),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedGroup(
            label: 'Notes',
            child: TextField(
              controller: notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _saveExpenses();
            },
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save to Expenses'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pick(ImageSource src) async {
    try {
      final x = await picker.pickImage(source: src, imageQuality: 75);
      if (x == null) return;

      final file = File(x.path);

      image = file;

      Utils.showLoading();

      // Convert to Base64
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Detect MIME type dynamically
      final mimeType = _getMimeType(file.path);

      final ReceiptOcrService ocrService = ReceiptOcrService();

      final result = await ocrService.parseInvoiceBase64(
        base64Image: base64Image,
        mimeType: mimeType,
      );

      text = result.toString();
      if(result != null && result.data != null){
        _fillFormFromOcr(result.data);
      }

      Utils.hideLoading();

      log("OCR Result: ${jsonEncode(result)}");
    } catch (e) {
      Utils.hideLoading();
      print("Error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to process invoice")),
      );
    }
  }

  String _getMimeType(String path) {
    final ext = path.toLowerCase().split('.').last;

    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';

      case 'png':
        return 'image/png';

      case 'gif':
        return 'image/gif';

      case 'bmp':
        return 'image/bmp';

      case 'webp':
        return 'image/webp';

      case 'heic':
        return 'image/heic';

      case 'heif':
        return 'image/heif';

      case 'tiff':
      case 'tif':
        return 'image/tiff';

      case 'svg':
        return 'image/svg+xml';

      case 'ico':
        return 'image/x-icon';

      case 'avif':
        return 'image/avif';

      default:
        return 'image/jpeg'; // fallback
    }
  }

  void _tryParse(String t) {
    final vatMatch =
        RegExp(r'(VAT|Vat|vat)\s*[:£]*\s*([0-9]+\.?[0-9]*)').firstMatch(t);
    final totalMatch =
        RegExp(r'(TOTAL|Total|total)\s*[:£]*\s*([0-9]+\.?[0-9]*)')
            .firstMatch(text);
    final netMatch =
        RegExp(r'(NET|Net|Subtotal|Amount)\s*[:£]*\s*([0-9]+\.?[0-9]*)')
            .firstMatch(t);
    if (netMatch != null) netCtrl.text = netMatch.group(2) ?? netCtrl.text;
    if (totalMatch != null) netCtrl.text = totalMatch.group(2) ?? netCtrl.text;
    if (vatMatch != null) vatCtrl.text = vatMatch.group(2) ?? vatCtrl.text;
    if (netCtrl.text.isEmpty && totalMatch != null && vatCtrl.text.isNotEmpty) {
      try {
        final tot = double.parse(totalMatch.group(2)!);
        final v = double.tryParse(vatCtrl.text) ?? 0;
        netCtrl.text = (tot - v).toStringAsFixed(2);
      } catch (_) {}
    }
    // Attempt to get supplier name (first line)
    final lines = t.split('\n').where((s) => s.trim().isNotEmpty).toList();
    if (lines.isNotEmpty)
      supplierCtrl.text =
          lines.first.trim().substring(0, lines.first.length.clamp(0, 32));
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
        initialDate: date);
    if (d != null) setState(() => date = d);
  }

  // Future<void> _save() async {
  //   final data = await StorageService.read('expenses');
  //   final list = (data['list'] ?? []) as List;
  //   list.add(Expense(
  //     id: DateTime.now().microsecondsSinceEpoch.toString(),
  //     category: category,
  //     supplier: supplierCtrl.text,
  //     date: date,
  //     net: double.tryParse(netCtrl.text) ?? 0,
  //     vat: double.tryParse(vatCtrl.text) ?? 0,
  //     notes: notesCtrl.text,
  //   ).toJson()
  //     ..['imagePath'] = (image?.path ?? ''));
  //   await StorageService.write('expenses', {'list': list});
  //   if (!mounted) return;
  //   ScaffoldMessenger.of(context)
  //       .showSnackBar(const SnackBar(content: Text('Expense saved')));
  // }

  Future<void> _saveExpenses() async {
    final amount = double.tryParse(netCtrl.text) ?? 0.0;
    if (categoryCtrl.text.isEmpty || amount <= 0) return;
    final e = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: date,
      category: categoryCtrl.text,
      notes: notesCtrl.text,
      supplier: supplierCtrl.text.trim(),
      amount: amount,
      vatRate: double.tryParse(vatCtrl.text.trim()) ?? 0,
    );
    await widget.storage.saveExpense(e);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Expense saved'),
      duration: Duration(seconds: 2),
    ));
    widget.onChanged();
  }

  void _fillFormFromOcr(OcrData? data) {
    if (data == null) return;

    supplierCtrl.text = data.supplierName ?? '';

    netCtrl.text = data.netTotal != null
        ? data.netTotal!.toStringAsFixed(2)
        : '';

    vatCtrl.text = data.vatAmount != null
        ? data.vatAmount!.toStringAsFixed(2)
        : '';

    notesCtrl.text = data.invoiceNumber ?? '';

    // Optional: Set category default
   // categoryCtrl.text = "General";

    // Parse date safely
    if (data.date != null && data.date!.isNotEmpty) {
      try {
        date = DateTime.parse(data.date!);
      } catch (e) {
        print("Date parse error: $e");
      }
    }

    setState(() {});
  }
}
