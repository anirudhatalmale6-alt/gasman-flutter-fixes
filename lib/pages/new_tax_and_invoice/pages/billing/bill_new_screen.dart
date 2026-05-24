import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the_gas_man_app/pages/new_invoice_page/account_storage_file.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/data_models/bill_detail.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/billing/bill_view_screen.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/supplier/supplier_list_screen.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';

import '../../../../services/attachment_service.dart';
import '../../../../services/bill_service.dart';
import '../../../../utils_class/image_pick.dart';
import '../../../../utils_class/money.dart';
import '../../../new_invoice_page/data_model/all_models.dart';
import '../../api_service/receipt_ocr_service.dart';

class BillNewScreen extends StatefulWidget {
  final BillDetails? billDetails;

  const BillNewScreen({super.key, this.billDetails});

  @override
  State<BillNewScreen> createState() => _BillNewScreenState();
}

class _BillNewScreenState extends State<BillNewScreen> {
  final picker = ImagePicker();
  String text = '';
  double? grandTotal = 0;

  String _status = "UNPAID";
  final List<String> _statusList = ["PAID", "UNPAID"];

  // final recognizer = TextRecognizer();

  final BillService _billService = BillService();
  final AttachmentService _attachmentService = AttachmentService();

  bool saving = false;

  String? _supplierId;

  final _billNumber = TextEditingController();
  final _supplierIdTE = TextEditingController(); // replace with picker
  final List<File> queuedAttachments = [];

  List<TextEditingController> descriptionControllers = [
    TextEditingController()
  ];
  List<TextEditingController> quantityControllers = [TextEditingController()];
  List<TextEditingController> unitCostControllers = [TextEditingController()];

  List<Map<String, dynamic>> _lineItems = [
    {
      "description": "",
      "quantity": 1,
      "unitCost": 0,
      "vatRate": 0,
      "productId": null,
    }
  ];

  double calculateTotal() {
    double total = 0;

    for (var item in _lineItems) {
      final qty = (item["quantity"] ?? 0).toDouble();
      final rate = double.tryParse(item["unitCost"].toString()) ?? 0;
      final vat = double.tryParse(item["vatRate"].toString()) ?? 0;

      final base = qty * rate;
      final itemTotal = base + (base * vat / 100);

      total += itemTotal;
    }

    return total;
  }

  Future<void> _addFromCamera() async {
    final f = await ImagePick.camera();
    if (f == null) return;
    setState(() => queuedAttachments.add(f));
  }

  Future<void> _addFromGallery() async {
    final f = await ImagePick.gallery();
    if (f == null) return;
    setState(() => queuedAttachments.add(f));
  }

  void _removeQueued(int index) =>
      setState(() => queuedAttachments.removeAt(index));

  Future<void> _saveBill() async {
    if (_billNumber.text.isEmpty) {
      showRedSnackbar("Please enter bill number");
      return;
    } else if (_supplierId == null || _supplierId!.isEmpty) {
      showRedSnackbar("Please select supplier to save bill");
      return;
    } else if (_lineItems.isEmpty || grandTotal == 0) {
      showRedSnackbar("Atleast one item should be added to bill");
      return;
    }

    setState(() => saving = true);
    try {
      // final supplierId = int.tryParse(_supplierIdTE.text) ?? 1;

      final body = {
        "supplierId": _supplierId,
        "billNumber": _billNumber.text.trim(),
        "billDate": DateTime.now().toIso8601String().substring(0, 10),
        "status": _status,
        "dueDate": DateTime.now()
            .add(const Duration(days: 30))
            .toIso8601String()
            .substring(0, 10),
        "lines": _lineItems,
      };

      final created = await _billService.create(body,
          id: widget.billDetails != null ? widget.billDetails!.bill!.id : null);
      final billId = created["id"] as int;

      for (final f in queuedAttachments) {
        await _attachmentService.upload(
            parentType: "bill", parentId: billId, file: f);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Bill created. Uploaded ${queuedAttachments.length} attachments.")),
      );

      Navigator.pop(context);
      if (widget.billDetails == null) {
        push(BillViewScreen(billId: billId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create bill: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void _resetForm() {
    // Dispose existing controllers
    for (final c in descriptionControllers) {
      c.dispose();
    }
    for (final c in quantityControllers) {
      c.dispose();
    }
    for (final c in unitCostControllers) {
      c.dispose();
    }

    // Clear lists
    descriptionControllers.clear();
    quantityControllers.clear();
    unitCostControllers.clear();
    _lineItems.clear();
    queuedAttachments.clear();

    // Reset fields
    _supplierId = null;
    _supplierIdTE.clear();
    _status = "UNPAID";

    // Reset bill number (generate new)
    AccountStorage().nextBillNumber().then((value) {
      _billNumber.text = value;
    });

    // Add one empty row (IMPORTANT)
    _lineItems.add({
      "description": "",
      "quantity": 1,
      "unitCost": 0,
      "vatRate": 0,
      "productId": null,
    });

    descriptionControllers.add(TextEditingController());
    quantityControllers.add(TextEditingController(text: "1"));
    unitCostControllers.add(TextEditingController(text: "0"));

    grandTotal = 0;

    setState(() {});
  }

  @override
  void dispose() {
    _billNumber.dispose();
    _supplierIdTE.dispose();

    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setBillData();
  }

  void setBillData() async {
    if (widget.billDetails != null) {
      final bill = widget.billDetails!.bill;

      _billNumber.text = bill!.billNumber!;
      _supplierIdTE.text = widget.billDetails!.supplier!.name.toString() +
          " | " +
          widget.billDetails!.supplier!.email.toString() +
          " | " +
          widget.billDetails!.supplier!.phone.toString();
      _supplierId = widget.billDetails!.supplier!.id!.toString();
      _status = bill.status ?? "UNPAID";

      // 🧹 Clear old data (IMPORTANT)
      _lineItems.clear();
      descriptionControllers.clear();
      quantityControllers.clear();
      unitCostControllers.clear();

      // ✅ Fill data + controllers together
      for (var lineElement in widget.billDetails!.lines!) {
        _lineItems.add({
          "id": lineElement.id,
          "description": lineElement.description ?? "",
          "quantity": lineElement.quantity ?? 1,
          "unitCost": lineElement.unitCost ?? 0,
          "vatRate": lineElement.vatRate ?? 0,
          "productId": null,
        });

        descriptionControllers.add(
          TextEditingController(text: lineElement.description ?? ""),
        );

        quantityControllers.add(
          TextEditingController(text: (lineElement.quantity ?? 1).toString()),
        );

        unitCostControllers.add(
          TextEditingController(text: (lineElement.unitCost ?? 0).toString()),
        );
      }

      // Optional: recalc total once
      grandTotal = calculateTotal();
      setState(() {});
    } else {
      _billNumber.text = await AccountStorage().nextBillNumber();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Bill"),
        actions: [
          IconButton(
              onPressed: () {
                _resetForm();
              },
              icon: Icon(Icons.lock_reset))
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _billNumber,
            decoration: const InputDecoration(labelText: "Bill Number"),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _supplierIdTE,
            decoration: InputDecoration(
                labelText: "Choose from supplier list",
                labelStyle: TextStyle(color: Colors.red),
                suffixIcon: InkWell(
                  onTap: () async {
                    dynamic sDetails = await push(SupplierListScreen());
                    if (sDetails != null) {
                      print("Data => ${jsonEncode(sDetails)}");
                      _supplierIdTE.text =
                          "${sDetails['name'] ?? ""} | ${sDetails['phone'] ?? ""}  | ${sDetails['email'] ?? ""}";
                      _supplierId = sDetails['id'].toString();
                      setState(() {});
                    }
                  },
                  child: const Icon(Icons.person),
                )),
          ),
          const SizedBox(height: 2),

          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Line Items',
                    style: theme.textTheme.titleMedium,
                  ),
                  const Spacer(),
                  const SizedBox(width: 4),
                  TextButton.icon(
                    onPressed: _addLineItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Line'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._lineItems.asMap().entries.map(
                (entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            TextFormField(
                              // key: UniqueKey(),
                              controller: descriptionControllers[index],
                              //  initialValue: item["description"] ?? "",
                              decoration: const InputDecoration(
                                labelText: 'Description',
                              ),
                              onChanged: (value) => item['description'] = value,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    //   key: UniqueKey(),
                                    controller: quantityControllers[index],
                                    //   initialValue: item["quantity"].toString(),
                                    decoration:
                                        const InputDecoration(labelText: 'Qty'),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      item['quantity'] = int.tryParse(value) ??
                                          item['quantity'];
                                      grandTotal = calculateTotal();
                                      setState(() {});
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    //    key: UniqueKey(),
                                    controller: unitCostControllers[index],
                                    // initialValue: double.tryParse(
                                    //         item['unitCost'].toString())!
                                    //     .toStringAsFixed(2),
                                    decoration: const InputDecoration(
                                        labelText: 'Unit (£)'),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      item['unitCost'] =
                                          double.tryParse(value) ??
                                              item['unitCost'];
                                      grandTotal = calculateTotal();
                                      setState(() {});
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButtonFormField<double>(
                                    initialValue: double.parse(
                                        item['vatRate'].toString()),
                                    isExpanded: true,
                                    elevation: 0,
                                    decoration: InputDecoration(
                                        labelText: "Vat",
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always),
                                    items: const [
                                      DropdownMenuItem(
                                          value: 0, child: Text('0%')),
                                      DropdownMenuItem(
                                          value: 5, child: Text('5%')),
                                      DropdownMenuItem(
                                          value: 20, child: Text('20%')),
                                    ],
                                    onChanged: (v) {
                                      item['vatRate'] = v ?? 0;
                                      grandTotal = calculateTotal();
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '£${(((int.tryParse(item['quantity'].toString()) ?? 1) * (double.tryParse(item['unitCost'].toString()) ?? 0)) * (1 + (double.tryParse(item['vatRate'].toString()) ?? 0) / 100)).toStringAsFixed(2)}',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _removeLineItem(index),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),

          /// ✅ STATUS DROPDOWN
          DropdownButtonFormField<String>(
            value: _status,
            decoration: const InputDecoration(
              labelText: "Bill Status",
              border: OutlineInputBorder(),
            ),
            items: _statusList.map((s) {
              return DropdownMenuItem(
                value: s,
                child: Text(s.toUpperCase()),
              );
            }).toList(),
            onChanged: (v) => setState(() => _status = v!),
          ),

          const SizedBox(height: 12),

          Card(
            child: ListTile(
              title: const Text("Total (incl VAT)"),
              trailing: Text(
                formatMoney(grandTotal!),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Attachments (queued)",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: saving ? null : _addFromCamera,
                icon: const Icon(Icons.photo_camera),
                label: const Text("Camera"),
              ),
              OutlinedButton.icon(
                onPressed: saving ? null : _addFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text("Gallery"),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  _pick(ImageSource.gallery);
                },
                icon: const Icon(Icons.photo_library),
                label: const Text("OCR"),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (queuedAttachments.isEmpty)
            const Text("No queued attachments.")
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: queuedAttachments.length,
              itemBuilder: (_, i) {
                final f = queuedAttachments[i];
                return ListTile(
                  leading: const Icon(Icons.attach_file),
                  title: Text(f.path.split('/').last),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: saving ? null : () => _removeQueued(i),
                  ),
                );
              },
            ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: saving ? null : _saveBill,
            child: saving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text("Save Bill"),
          ),
        ],
      ),
    );
  }

  void _addLineItem() {
    setState(() {
      _lineItems.add({
        "description": "",
        "quantity": 1,
        "unitCost": 0,
        "vatRate": 0,
        "productId": null,
      });

      descriptionControllers.add(TextEditingController());
      quantityControllers.add(TextEditingController(text: "1"));
      unitCostControllers.add(TextEditingController(text: "0"));
    });
  }

  void _removeLineItem(int index) {
    descriptionControllers[index].dispose();
    quantityControllers[index].dispose();
    unitCostControllers[index].dispose();

    descriptionControllers.removeAt(index);
    quantityControllers.removeAt(index);
    unitCostControllers.removeAt(index);

    _lineItems.removeAt(index);

    setState(() {});
  }

  Future<void> _pick(ImageSource src) async {
    try {
      final x = await picker.pickImage(source: src, imageQuality: 75);
      if (x == null) return;

      final file = File(x.path);

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
      if (result != null && result.data != null) {
        _fillFormFromOcr(result.data);
      } else {
        print("No data received......");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No data received......")),
        );
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

  void _fillFormFromOcr(OcrData? data) {
    if (data == null) return;

    _billNumber.text = data.invoiceNumber ?? '';

    // 🧹 Clear previous data + controllers
    _lineItems.clear();

    for (final controller in descriptionControllers) {
      controller.dispose();
    }
    for (final controller in quantityControllers) {
      controller.dispose();
    }
    for (final controller in unitCostControllers) {
      controller.dispose();
    }

    descriptionControllers.clear();
    quantityControllers.clear();
    unitCostControllers.clear();

    // ✅ Add OCR line items + controllers
    if (data.lineItems != null && data.lineItems!.isNotEmpty) {
      for (var ocrLineItems in data.lineItems!) {
        final vatRate = ocrLineItems.vatRate ?? 0.0;

        final unitCost = ocrLineItems.lineTotal != null
            ? ocrLineItems.lineTotal! / (1 + (vatRate / 100))
            : ocrLineItems.unitPrice != null
                ? ocrLineItems.unitPrice! / (1 + (vatRate / 100))
                : 0.0;

        final description = ocrLineItems.description ?? "";
        final quantity = ocrLineItems.quantity ?? 1;

        _lineItems.add({
          "description": description,
          "quantity": quantity,
          "unitCost": unitCost,
          "vatRate": vatRate,
          "productId": null,
        });

        descriptionControllers.add(
          TextEditingController(text: description),
        );

        quantityControllers.add(
          TextEditingController(text: quantity.toString()),
        );

        unitCostControllers.add(
          TextEditingController(
            text: unitCost.toStringAsFixed(2),
          ),
        );
      }
    }

    grandTotal = calculateTotal();
    setState(() {});
  }
}
