import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/customer/customer_list_screen.dart';
import 'package:the_gas_man_app/services/estimate_service.dart';

import '../../../../theme/app_theme.dart';
import '../../../finance/expense_form_page.dart';
import '../../../new_invoice_page/account_storage_file.dart';
import '../../../new_invoice_page/data_model/all_models.dart';
import '../parts_list/product_pick_screen.dart';

class EstimateFormScreen extends StatefulWidget {
  final dynamic invoice;

  const EstimateFormScreen({super.key, this.invoice});

  @override
  State<EstimateFormScreen> createState() => _EstimateFormScreenState();
}

class _EstimateFormScreenState extends State<EstimateFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final AccountStorage _storage = AccountStorage();

  final TextEditingController _customerController = TextEditingController();

  final TextEditingController _estimateIdController = TextEditingController();

  final TextEditingController _notesCtrl = TextEditingController();

  InvoiceStatus _status = InvoiceStatus.draft;

  bool? isLoading  = true;

  List<InvoiceItem> _items = [];

  String _customerId = '';

  dynamic selectedCustomer;

  DateTime? _date = DateTime.now();

  DateTime? _expiryDate = DateTime.now().add(const Duration(days: 30));

  var _estimateService = EstimateService();

  bool saving = false;

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
    if (widget.invoice != null) {
      getEstimateDetails();
    } else {
      getNextEstimateNumber();
    }
  }

  void setEstimateData(dynamic data) {

    final estimate = data['estimate'];

    _estimateIdController.text = estimate["estimate_number"]?.toString() ?? "";

    _customerId = estimate["customer_id"]?.toString() ?? "";

    _customerController.text = estimate["customer_name"]?.toString() ?? "";

    _notesCtrl.text = estimate["notes"]?.toString() ?? "";

    selectedCustomer = {
      "id": estimate["customer_id"],
      "name": estimate["customer_name"],
      "email": estimate["customer_email"],
    };

    if (estimate["estimate_date"] != null) {
      _date = DateTime.tryParse(
        estimate["estimate_date"].toString(),
      );
    }

    if (estimate["expiry_date"] != null) {
      _expiryDate = DateTime.tryParse(
        estimate["expiry_date"].toString(),
      );
    }

    switch (estimate["status"]?.toString().toLowerCase()) {
      case "sent":
        _status = InvoiceStatus.sent;
        break;

      case "paid":
        _status = InvoiceStatus.paid;
        break;

      case "overdue":
        _status = InvoiceStatus.overdue;
        break;

      default:
        _status = InvoiceStatus.draft;
    }



    List<dynamic>  lines = data["lines"] as List;
    if(lines.isNotEmpty){
       lines.forEach((line){
         final invoiceItem = InvoiceItem(
           description: line["description"]?.toString() ?? "",
           qty: double.tryParse(
             line["quantity"].toString(),
           ) ??
               1,
           price: double.tryParse(
             line["unit_price"].toString(),
           ) ??
               0,
           vat: double.tryParse(
             line["vat_rate"].toString(),
           ) ??
               20,
         );
         _items.add(invoiceItem);
       });
    }else{
      _addLineItem();
    }

    // _items = List<Map<String, dynamic>>.from(
    //   estimate["lines"] ?? [],
    // ).map((line) {
    //   return InvoiceItem(
    //     description: line["description"]?.toString() ?? "",
    //     qty: double.tryParse(
    //           line["quantity"].toString(),
    //         ) ??
    //         1,
    //     price: double.tryParse(
    //           line["unit_price"].toString(),
    //         ) ??
    //         0,
    //     vat: double.tryParse(
    //           line["vat_rate"].toString(),
    //         ) ??
    //         20,
    //   );
    // }).toList();

    // if (_items.isEmpty) {
    //   _addLineItem();
    // }

    setState(() {});
  }

  void getEstimateDetails() async {
    isLoading = true;
    setState(() {

    });

    final data = await _estimateService.getEstimate(widget.invoice['id']);
    if (data != null) {
      setEstimateData(data);
    }
    if(mounted){
      isLoading = false;
      setState(() {

      });
    }

  }

  @override
  void dispose() {
    _customerController.dispose();
    _estimateIdController.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isExpiryDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isExpiryDate ? _expiryDate! : _date!,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked == null) return;

    setState(() {
      if (isExpiryDate) {
        _expiryDate = picked;
      } else {
        _date = picked;
      }
    });
  }

  Future<void> _selectCustomer() async {
    final selected = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerListScreen(
          fromScreen: "invoice",
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _customerId = selected['id'].toString();
        _customerController.text = selected['name'];
        selectedCustomer = selected;
      });
    }
  }

  Future<void> _addFromParts() async {
    final part = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => PartListScreen(),
      ),
    );

    if (part != null) {
      setState(() {
        _items.add(
          InvoiceItem(
            description: part['description'],
            qty: 1,
            price: double.parse(part['price'].toString()),
            vat: 20,
          ),
        );
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one line item'),
        ),
      );
      return;
    }

    if (_customerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select customer'),
        ),
      );
      return;
    }

    try {
      setState(() {
        saving = true;
      });

      final lines = _items.map((e) {
        return {
          "description": e.description,
          "quantity": e.qty,
          "unitPrice": e.price,
          "vatRate": e.vat,
        };
      }).toList();

      if (widget.invoice != null) {
        await _estimateService.updateEstimate(
          id: int.parse(widget.invoice['id'].toString()),
          estimateNumber: _estimateIdController.text.trim(),
          estimateDate: DateFormat("yyyy-MM-dd").format(_date!),
          expiryDate: DateFormat("yyyy-MM-dd").format(_expiryDate!),
          customerId: int.parse(_customerId),
          notes: _notesCtrl.text.trim(),
          terms: _notesCtrl.text.trim(),
          lines: lines,
        );
      } else {
        await _estimateService.createEstimate(
          estimateNumber: _estimateIdController.text.trim(),
          estimateDate: DateFormat("yyyy-MM-dd").format(_date!),
          expiryDate: DateFormat("yyyy-MM-dd").format(_expiryDate!),
          customerId: int.parse(_customerId),
          notes: _notesCtrl.text.trim(),
          terms: _notesCtrl.text.trim(),
          lines: lines,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.invoice != null ? "Estimate updated" : "Estimate created",
            ),
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.kTeal,
        title: const Text('Estimate'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: saving
                ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
                : TextButton(
              onPressed: _save,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body:  isLoading!? Center(child: CircularProgressIndicator(),) : Container(
        color: AppColors.kLightBg,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    16,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(
                    16,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                        ),
                        child: Image.file(
                          File(
                            _storage.settings.logoPath!,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Company Name: ${_storage.settings.businessName}\n'
                          'Address: ${_storage.settings.businessAddress}\n'
                          'Phone: ${_storage.settings.businessPhone}\n'
                          'VAT: ${_storage.settings.vatNumber}',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _OutlinedGroup(
                      label: 'Customer',
                      child: TextFormField(
                        controller: _customerController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        onTap: _selectCustomer,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "Required";
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: _selectCustomer,
                    child: const Icon(
                      Icons.person_search_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _OutlinedGroup(
                label: 'Estimate #',
                child: TextFormField(
                  controller: _estimateIdController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _OutlinedGroup(
                      label: 'Estimate Date',
                      child: InkWell(
                        onTap: () {
                          _pickDate(false);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          child: Text(
                            formatDate(_date!),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _OutlinedGroup(
                      label: 'Expiry Date',
                      child: InkWell(
                        onTap: () {
                          _pickDate(true);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          child: Text(
                            formatDate(
                              _expiryDate!,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Estimate Lines',
                    style: theme.textTheme.titleMedium,
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: _addFromParts,
                        icon: const Icon(
                          Icons.build_circle_outlined,
                        ),
                        label: const Text(
                          'From parts',
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _addLineItem,
                        icon: const Icon(
                          Icons.add,
                        ),
                        label: const Text(
                          'Add Line',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._items.asMap().entries.map(
                (entry) {
                  final index = entry.key;

                  final item = entry.value;

                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: 12,
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
                            onChanged: (v) {
                              item.description = v;
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: item.qty.toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Qty',
                                  ),
                                  onChanged: (v) {
                                    item.qty = double.tryParse(
                                          v,
                                        ) ??
                                        1;

                                    setState(() {});
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  initialValue: item.price!.toStringAsFixed(
                                    2,
                                  ),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Price',
                                  ),
                                  onChanged: (v) {
                                    item.price = double.tryParse(
                                          v,
                                        ) ??
                                        0;

                                    setState(() {});
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField<double>(
                                  value: item.vat,
                                  decoration: const InputDecoration(
                                    labelText: "VAT",
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 0,
                                      child: Text(
                                        "0%",
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 10,
                                      child: Text(
                                        "10%",
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 20,
                                      child: Text(
                                        "20%",
                                      ),
                                    ),
                                  ],
                                  onChanged: (
                                    v,
                                  ) {
                                    item.vat = v ?? 20;

                                    setState(() {});
                                  },
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
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  _removeLineItem(index);
                                },
                                icon: const Icon(
                                  Icons.delete_outline,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              _OutlinedGroup(
                label: 'Notes',
                child: TextFormField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(
                    16,
                  ),
                  child: Column(
                    children: [
                      _TotalRow(
                        label: 'Subtotal',
                        value: _subTotal,
                      ),
                      const SizedBox(height: 8),
                      _TotalRow(
                        label: 'VAT',
                        value: _getVat,
                      ),
                      const Divider(),
                      _TotalRow(
                        label: 'Total',
                        value: _total,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addLineItem() {
    setState(() {
      _items.add(
        InvoiceItem(
          description: '',
          qty: 1,
          price: 0,
          vat: 20,
        ),
      );
    });
  }

  void _removeLineItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void getNextEstimateNumber() async {
    isLoading = true;
    setState(() {

    });
    final res = await _estimateService.getNextEstimateNumber();

    _estimateIdController.text = res;
    isLoading = false;
    setState(() {

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
