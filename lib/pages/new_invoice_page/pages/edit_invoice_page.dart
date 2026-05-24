import 'dart:io';

import 'package:flutter/material.dart';
import 'package:the_gas_man_app/theme/app_theme.dart';

import '../../finance/expense_form_page.dart';
import '../account_storage_file.dart';
import '../data_model/all_models.dart';
import 'customers_page.dart';
import 'parts_page.dart';

class InvoiceEditorPage extends StatefulWidget {
  final AccountStorage storage;
  final Invoice? invoice;
  final bool isEstimate;

  const InvoiceEditorPage({
    super.key,
    required this.storage,
    this.invoice,
    required this.isEstimate,
  });

  @override
  State<InvoiceEditorPage> createState() => _InvoiceEditorPageState();
}

class _InvoiceEditorPageState extends State<InvoiceEditorPage> {
  final _formKey = GlobalKey<FormState>();

  final AccountStorage _storage = AccountStorage();

  late TextEditingController _customerController;
  late TextEditingController _invoiceIdController;
  late TextEditingController _dateController;
  late TextEditingController _dueDateController;
  late TextEditingController _discountController;

  // late TextEditingController _bankDetailsCotroller;

  late TextEditingController _notesCtrl;

  //double _vatRate = 20.0;
  InvoiceStatus _status = InvoiceStatus.draft;
  List<InvoiceItem> _items = [];
  String _customerId = '';
  Customer? selectedCustomer;

  DateTime? _date = DateTime.now();
  DateTime? _dueDate = DateTime.now().add(Duration(days: 1));

  double get _subTotal {
    return _items.fold(
      0.0,
      (sum, item) => sum + (item.qty! * item.price!),
    );
  }

  double get _getVat {
    return _items.fold(
      0.0,
      (sum, item) => sum + (item.qty! * item.price! * (item.vat! / 100)),
    );
  }

  double get _total {
    return _subTotal + _getVat;
  }

  @override
  void initState() {
    super.initState();
    final inv = widget.invoice;
    _customerController = TextEditingController(text: inv?.customerName ?? '');
    _invoiceIdController = TextEditingController(text: inv?.id ?? '');
    _customerId = inv?.customerId ?? '';
    _dateController = TextEditingController(
      text: _fmtDate(inv?.date ?? DateTime.now()),
    );
    _dueDateController = TextEditingController(
      text: inv?.dueDate != null ? _fmtDate(inv!.dueDate!) : '',
    );
    _discountController = TextEditingController(
      text: inv != null ? inv.discount.toStringAsFixed(2) : '0.00',
    );
    //   _bankDetailsCotroller = TextEditingController();
    _notesCtrl = TextEditingController();
    _notesCtrl.text = _storage.settings.paymentDetails;
    //  _vatRate = inv?.vatRate ?? 20.0;
    _status = inv?.status ?? InvoiceStatus.draft;
    _items = inv?.items ?? [];
    if (inv != null && inv.customerId != null) {
      selectedCustomer = Customer(
          id: inv.customerId,
          name: inv.customerName,
          address: inv.customerAddress,
          email: inv.customerEmail,
          phone: inv.customerPhone);
    }
  }

  @override
  void dispose() {
    _customerController.dispose();
    _dateController.dispose();
    _dueDateController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  DateTime _parseDate(String s) {
    final parts = s.split('/');
    if (parts.length == 3) {
      final d = int.tryParse(parts[0]) ?? 1;
      final m = int.tryParse(parts[1]) ?? 1;
      final y = int.tryParse(parts[2]) ?? DateTime.now().year;
      return DateTime(y, m, d);
    }
    return DateTime.now();
  }

  Future<void> _pickDate(bool isDueDate) async {
    // final initial = _parseDate(controller.text);
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(_date!.year - 5),
      lastDate: DateTime(_date!.year + 5),
    );
    if (picked != null) {
      isDueDate ? _dueDate : _date = picked;
    }
    setState(() {});
  }

  Future<void> _selectCustomer() async {
    final selected = await Navigator.push<Customer?>(
      context,
      MaterialPageRoute(
        builder: (_) => CustomersPage(storage: widget.storage,fromScreen: "invoice",),
      ),
    );
    if (selected != null) {
      setState(() {
        _customerId = selected.id;
        _customerController.text = selected.name;
        selectedCustomer = selected;
      });
    }
  }



  Future<void> _addFromParts() async {
    final part = await Navigator.push<Part?>(
      context,
      MaterialPageRoute(
        builder: (_) => PartsPage(storage: widget.storage),
      ),
    );
    if (part != null) {
      setState(() {
        _items.add(InvoiceItem(
            description: part.description, qty: 1, price: part.price, vat: 0));
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one line item')),
      );
      return;
    }

    final date = _parseDate(_dateController.text);
    final due = _dueDateController.text.isNotEmpty
        ? _parseDate(_dueDateController.text)
        : null;
    final discount = double.tryParse(_discountController.text) ?? 0.0;

    String number;
    if (widget.invoice != null) {
      number = widget.invoice!.number;
    } else {
      number = widget.isEstimate
          ? await widget.storage.nextEstimateNumber()
          : await widget.storage.nextInvoiceNumber();
    }

    final inv = Invoice(
        id: widget.invoice?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        number: number,
        isEstimate: widget.isEstimate,
        customerId: _customerId,
        customerName: _customerController.text.trim(),
        date: date,
        dueDate: due,
        items: _items,
        vatRate: 0,
        discount: discount,
        status: _status,
        notes: _notesCtrl.text,
        customerAddress: selectedCustomer!.address,
        customerEmail: selectedCustomer!.email,
        customerPhone: selectedCustomer!.phone);

    Navigator.pop(context, inv);
  }

  @override
  Widget build(BuildContext context) {
    final isEstimate = widget.isEstimate;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.kTeal,
        title: Text(isEstimate ? 'Estimate' : 'Invoice'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Container(
        color: AppColors.kLightBg,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(12),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _OutlinedGroup(
                      label: 'Customer',
                      child: TextFormField(
                        controller: _customerController,
                        readOnly: true,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: const InputDecoration(
                          labelText: 'Customer',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(bottom: 12.0),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          isDense: true,
                        ),
                        onTap: _selectCustomer,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: EdgeInsets.only(top: 15.0),
                    child: InkWell(
                      onTap: _selectCustomer,
                      child: const Icon(
                        Icons.person_search_outlined,
                        color: AppColors.kTeal,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _OutlinedGroup(
                label: 'Document #',
                child: TextFormField(
                  controller: _invoiceIdController,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _OutlinedGroup(
                      label: 'Date',
                      child: InkWell(
                        onTap: () {
                          _pickDate(false);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(formatDate(_date!)),
                              const Icon(Icons.edit_calendar_outlined,
                                  size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _OutlinedGroup(
                      label: 'Due date (optional)',
                      child: InkWell(
                        onTap: () {
                          _pickDate(true);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(formatDate(_dueDate!)),
                              const Icon(Icons.edit_calendar_outlined,
                                  size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _OutlinedGroup(
                  label: "Status",
                  child: DropdownButtonHideUnderline(
                      child: DropdownButton<InvoiceStatus>(
                    value: _status,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                          value: InvoiceStatus.draft, child: Text('Draft')),
                      DropdownMenuItem(
                          value: InvoiceStatus.sent, child: Text('Sent')),
                      DropdownMenuItem(
                          value: InvoiceStatus.paid, child: Text('Paid')),
                      DropdownMenuItem(
                          value: InvoiceStatus.overdue, child: Text('Overdue')),
                    ],
                    onChanged: (v) =>
                        setState(() => _status = v ?? InvoiceStatus.draft),
                  ))),
              const SizedBox(height: 8),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Line Items',
                    style: theme.textTheme.titleMedium,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _addFromParts,
                    icon: const Icon(Icons.build_circle_outlined),
                    label: const Text('From parts'),
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
              ..._items.asMap().entries.map(
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
                              initialValue: item.description,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                              ),
                              onChanged: (value) => item.description = value,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: item.qty.toString(),
                                    decoration:
                                        const InputDecoration(labelText: 'Qty'),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      item.qty =
                                          double.tryParse(value) ?? item.qty;
                                      setState(() {});
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    initialValue:
                                        item.price!.toStringAsFixed(2),
                                    decoration: const InputDecoration(
                                        labelText: 'Unit (£)'),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      item.price =
                                          double.tryParse(value) ?? item.price;
                                      setState(() {});
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButtonFormField<double>(
                                    initialValue: item.vat,
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
                                    onChanged: (v) =>
                                        setState(() => item.vat = v ?? 20),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '£${((item.qty! * item.price!) + (item.qty! * item.price! * (item.vat! / 100))).toStringAsFixed(2)}',
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
              // NOTES
              _OutlinedGroup(
                label: 'Notes (optional)',
                child: TextFormField(
                  controller: _notesCtrl,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Payment terms, bank details, etc.',
                  ),
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 16),

              // TOTALS
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _TotalRow(label: 'Sub Total', value: _subTotal),
                      const SizedBox(height: 8),
                      // TODO: add VAT selector & calculation like in your current app.
                      _TotalRow(label: 'VAT', value: _getVat),
                      const Divider(height: 24),
                      _TotalRow(label: 'Total', value: _total),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _addLineItem() {
    setState(() {
      _items.add(InvoiceItem(description: '', qty: 1, price: 0, vat: 0));
    });
  }

  void _removeLineItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }
}

class TextFieldCard extends StatelessWidget {
  final String label;
  final Widget child;

  const TextFieldCard({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(color: Colors.grey.shade400),
            color: Colors.grey.shade50,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: child,
        ),
      ],
    );
  }
}

class _OutlinedGroup extends StatelessWidget {
  final String label;
  final Widget child;

  const _OutlinedGroup({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(color: Colors.grey.shade400),
            color: Colors.grey.shade50,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: child,
        ),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final double value;

  const _TotalRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          '£${value.toStringAsFixed(2)}',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
