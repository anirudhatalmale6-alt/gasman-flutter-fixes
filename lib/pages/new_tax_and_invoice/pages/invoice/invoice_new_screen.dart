import 'dart:io';
import 'package:flutter/material.dart';
import 'package:the_gas_man_app/pages/new_invoice_page/data_model/all_models.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/data_models/invoice_detail.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/customer/customer_list_screen.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';

import '../../../../services/attachment_service.dart';
import '../../../../services/invoice_service.dart';
import '../../../../utils_class/image_pick.dart';
import '../../../../utils_class/money.dart';
import '../../../new_invoice_page/account_storage_file.dart';
import '../parts_list/product_pick_screen.dart';
import 'invoice_view_screen.dart';

class InvoiceNewScreen extends StatefulWidget {
  final InvoiceDetailMaster? invoiceDetail;

  const InvoiceNewScreen({super.key, this.invoiceDetail});

  @override
  State<InvoiceNewScreen> createState() => _InvoiceNewScreenState();
}

class _InvoiceNewScreenState extends State<InvoiceNewScreen> {
  final InvoiceService _invoiceService = InvoiceService();
  final AccountStorage _storage = AccountStorage();

  final AttachmentService _attachmentService = AttachmentService();

  bool saving = false;

  String? _customerId;

  // Minimal form fields (expand to your full model)
  final _invoiceNumber = TextEditingController();
  final _customerIdTE = TextEditingController(); // replace with picker
  final _lineDesc = TextEditingController();
  final _lineQty = TextEditingController();
  final _lineRate = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _status = "SENT";

  final List<String> _statusList = ["SENT", "PAID", "UNPAID"];

  // Attachments queued BEFORE saving
  final List<File> queuedAttachments = [];
  List<Map<String, dynamic>> _lineItems = [];

  double calculateTotal(List<Map<String, dynamic>> items) {
    double total = 0;

    for (var item in items) {
      final qty = (item["quantity"] ?? 0).toDouble();
      final rate = double.tryParse(item["unitPrice"].toString()) ?? 0;
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

  void _removeQueued(int index) {
    setState(() => queuedAttachments.removeAt(index));
  }

  Future<void> _saveInvoice() async {
    if (_storage.settings.businessName == null ||
        _storage.settings.businessName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Please save business details before saving invoice")),
      );
      return;
    } else if (_lineItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please add items to invoice")),
      );
      return;
    } else if (_customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select customer")),
      );
      return;
    }
    setState(() => saving = true);
    try {
      final body = {
        "customerId": int.tryParse(_customerId!),
        "invoiceNumber": _invoiceNumber.text.trim(),
        "invoiceDate": DateTime.now().toIso8601String().substring(0, 10),
        "status": _status,
        "note": _notesCtrl.text.trim(),
        "dueDate": DateTime.now()
            .add(const Duration(days: 30))
            .toIso8601String()
            .substring(0, 10),
        "lines": _lineItems,
      };

      final created = await _invoiceService.create(body,
          id: widget.invoiceDetail != null
              ? widget.invoiceDetail!.invoice!.id!
              : null);
      final invoiceId = created["id"] as int;

      // Upload queued attachments after invoice exists
      for (final f in queuedAttachments) {
        await _attachmentService.upload(
            parentType: "invoice", parentId: invoiceId, file: f);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Invoice created. Uploaded ${queuedAttachments.length} attachments.")),
      );

      // Go to view screen
      Navigator.pop(context);
      push(InvoiceViewScreen(invoiceId: invoiceId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create invoice: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void _resetForm() async {
    // Clear basic fields
    _customerId = null;
    _customerIdTE.clear();
    _notesCtrl.clear();
    _status = "SENT";

    // Reset invoice number
    _invoiceNumber.text = await _storage.nextApiInvoiceNumber();

    // Clear line items
    _lineItems.clear();

    // Add one empty row (important UX)
    _lineItems.add({
      "description": "",
      "quantity": 1,
      "unitPrice": 0,
      "vatRate": 0,
      "productId": null,
    });

    // Clear attachments
    queuedAttachments.clear();

    setState(() {});
  }

  @override
  void dispose() {
    _invoiceNumber.dispose();
    _customerIdTE.dispose();
    _lineDesc.dispose();
    _lineQty.dispose();
    _lineRate.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setInvoiceData();
  }

  @override
  Widget build(BuildContext context) {
    final total = calculateTotal(_lineItems);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Invoice"),
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
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.file(File(_storage.settings.logoPath!)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Company Name: ${_storage.settings.businessName} \n Address : ${_storage.settings.businessAddress} \n Phone : ${_storage.settings.businessPhone} \n Vat Number : ${_storage.settings.vatNumber}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _invoiceNumber,
            enabled: true,
            decoration: const InputDecoration(labelText: "Invoice Number"),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _customerIdTE,
            decoration: InputDecoration(
                labelText: "Customer",
                suffixIcon: InkWell(
                  onTap: () async {
                    dynamic cDetails = await push(CustomerListScreen(fromScreen: "invoice",));
                    if (cDetails != null) {
                      _customerId = cDetails['id'].toString();
                      _customerIdTE.text = cDetails['name'];
                      _customerIdTE.text =
                          "${cDetails['name'] ?? ""} | ${cDetails['phone'] ?? ""}  | ${cDetails['email'] ?? ""}";

                      setState(() {});
                    }
                  },
                  child: const Icon(Icons.person),
                )),
          ),
          const SizedBox(height: 16),
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
                  TextButton.icon(
                    onPressed: () async {
                      // final product = await showModalBottomSheet(
                      //   context: context,
                      //   isScrollControlled: false,
                      //   builder: (_) => const ,
                      // );
                      final product = await push(PartListScreen());
                      if (product != null) {
                        _lineItems.add({
                          "description": product['description'],
                          "quantity": 1,
                          "unitPrice": product['price'],
                          "vatRate": product['vat_rate'],
                          "productId": product['id'],
                          // set when using product picker
                        });
                        setState(() {});
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('From Parts'),
                  ),
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
                              initialValue: item["description"] ?? "",
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
                                    initialValue: item["quantity"].toString(),
                                    decoration:
                                        const InputDecoration(labelText: 'Qty'),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      item['quantity'] = int.tryParse(value) ??
                                          item['quantity'];
                                      setState(() {});
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: double.tryParse(
                                            item['unitPrice'].toString())!
                                        .toStringAsFixed(2),
                                    decoration: const InputDecoration(
                                        labelText: 'Unit (£)'),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      item['unitPrice'] =
                                          double.tryParse(value) ??
                                              item['unitPrice'];
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
                                          value: 10, child: Text('10%')),
                                      DropdownMenuItem(
                                          value: 20, child: Text('20%')),
                                    ],
                                    onChanged: (v) => setState(
                                        () => item['vatRate'] = v ?? 0),
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
                                      '${calculateItemTotal(item)}',
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
          DropdownButtonFormField<String>(
            initialValue: _status,
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
          TextFormField(
            controller: _notesCtrl,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Payment terms, bank details, etc.',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: const Text("Total (incl VAT)"),
              trailing: Text(formatMoney(total),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          const Text("Attachments (queued)",
              style: TextStyle(fontWeight: FontWeight.bold)),
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
          const SizedBox(height: 16),
          FilledButton(
            onPressed: saving ? null : _saveInvoice,
            child: saving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text("Save Invoice"),
          ),
        ],
      ),
    );
  }

  void setInvoiceData() async {
    if (widget.invoiceDetail != null) {
      _invoiceNumber.text = widget.invoiceDetail!.invoice!.invoiceNumber!;
      _customerId = widget.invoiceDetail!.invoice!.customerId.toString();
      _customerIdTE.text = widget.invoiceDetail!.customer!.name!;
      _lineItems = widget.invoiceDetail!.lines!
          .map((lineElement) => {
                "description": lineElement.description,
                "quantity": lineElement.quantity,
                "unitPrice": lineElement.unitPrice,
                "vatRate": lineElement.vatRate,
                "productId": null, // set when using product picker
              })
          .toList();
      _status = widget.invoiceDetail!.invoice!.status!;
      _notesCtrl.text = widget.invoiceDetail!.invoice!.note!;
    } else {
      _invoiceNumber.text = await _storage.nextApiInvoiceNumber();
    }
    _notesCtrl.text = _storage.settings.paymentDetails;
    await _storage.load();
    setState(() {});
  }

  String calculateItemTotal(Map<String, dynamic> item) {
    final quantity = int.tryParse(item['quantity'].toString()) ?? 1;
    final unitPrice = double.tryParse(item['unitPrice'].toString()) ?? 0.0;
    final vatRate = double.tryParse(item['vatRate'].toString()) ?? 0.0;
    final total = quantity * unitPrice * (1 + vatRate / 100);

    return "£${total.toStringAsFixed(2)}";
  }

  void _addLineItem() {
    setState(() {
      _lineItems.add({
        "description": "",
        "quantity": 1,
        "unitPrice": 0,
        "vatRate": 0,
        "productId": null, // set when using product picker
      });
    });
  }

  void _removeLineItem(int index) {
    setState(() {
      _lineItems.removeAt(index);
    });
  }
}
