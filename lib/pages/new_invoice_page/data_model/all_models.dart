enum InvoiceStatus { draft, sent, paid, overdue }

class Customer {
  final String id;
  final String name;
  final String address;
  final String email;
  final String phone;
  final String notes;

  Customer({
    required this.id,
    required this.name,
    this.address = '',
    this.email = '',
    this.phone = '',
    this.notes = '',
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'],
        name: json['name'],
        address: json['address'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        notes: json['notes'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'email': email,
        'phone': phone,
        'notes': notes,
      };
}

class Part {
  final String id;
  final String description;
  final String sku;
  final double cost;
  final double price;

  Part({
    required this.id,
    required this.description,
    this.sku = '',
    required this.cost,
    required this.price,
  });

  factory Part.fromJson(Map<String, dynamic> json) => Part(
        id: json['id'],
        description: json['description'],
        sku: json['sku'] ?? '',
        cost: (json['cost'] as num).toDouble(),
        price: (json['price'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'sku': sku,
        'cost': cost,
        'price': price,
      };
}

class InvoiceItem {
  String? description;
  double? qty;
  double? price;
  double? vat;

  InvoiceItem({
    this.description,
    this.qty,
    this.price,
    this.vat = 0,
  });

  double get total => qty! * price! + (qty! * price! * (vat! / 100));

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
        description: json['description'],
        qty: (json['qty'] as num).toDouble(),
        price: (json['price'] as num).toDouble(),
        vat: json['vat'] != null ? (json['vat'] as num).toDouble() : 0,
      );

  Map<String, dynamic> toJson() => {
        'description': description,
        'qty': qty,
        'price': price,
        'vat': vat,
      };
}

class Invoice {
  final String id;
  final String number;
  final bool isEstimate;
  final String customerId;
  final String customerName;
  final String customerAddress;
  final String customerEmail;
  final String customerPhone;
  final DateTime date;
  final DateTime? dueDate;
  final List<InvoiceItem> items;
  final double vatRate;
  final double discount;
  final InvoiceStatus status;
  final String notes;

  Invoice({
    required this.id,
    required this.number,
    required this.isEstimate,
    required this.customerId,
    required this.customerName,
    required this.date,
    required this.dueDate,
    required this.items,
    required this.vatRate,
    required this.discount,
    required this.status,
    required this.notes,
    required this.customerAddress,
    required this.customerEmail,
    required this.customerPhone,
  });

  double get subTotal => items.fold(0.0, (s, i) => s + i.price!) - discount;

  double get vat => items.fold(0.0, (s, i) => s + i.price! * (i.vat! / 100));

  double get total => subTotal + vat;

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        id: json['id'],
        number: json['number'],
        isEstimate: json['isEstimate'],
        customerId: json['customerId'] ?? '',
        customerName: json['customerName'],
        date: DateTime.parse(json['date']),
        dueDate:
            json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
        items: (json['items'] as List)
            .map((i) => InvoiceItem.fromJson(i))
            .toList(),
        vatRate: json['vatRate'],
        discount: (json['discount'] as num).toDouble(),
        status: InvoiceStatus.values[json['status']],
        notes: json['note'],
        customerEmail: json['customerEmail'],
        customerPhone: json['customerPhone'],
        customerAddress: json['customerAddress'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'number': number,
        'isEstimate': isEstimate,
        'customerId': customerId,
        'customerName': customerName,
        'date': date.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'items': items.map((i) => i.toJson()).toList(),
        'vatRate': vatRate,
        'discount': discount,
        'status': status.index,
        'note': notes,
        'customerEmail': customerEmail,
        'customerPhone': customerPhone,
        'customerAddress': customerAddress,
      };
}

class Expense {
  final String id;
  final DateTime date;
  final String category;
  final String supplier;
  final double amount;
  final double vatRate;
  final String notes;

  Expense({
    required this.id,
    required this.date,
    required this.category,
    required this.supplier,
    required this.amount,
    required this.vatRate,
    required this.notes,
  });

  double get vat {
    return (amount * vatRate) / 100;
  }

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'],
        date: DateTime.parse(json['date']),
        category: json['category'],
        supplier: json['supplier'] ?? '',
        amount: (json['amount'] as num).toDouble(),
        vatRate: json['vatRate'],
        notes: json['notes'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'category': category,
        'supplier': supplier,
        'amount': amount,
        'vatRate': vatRate,
        'notes': notes,
      };
}

class AccountingSettings {
  final String businessName;
  final String engineerName;
  final String businessAddress;
  final String businessEmail;
  final String businessPhone;
  final bool vatRegistered;
  final String vatNumber;
  final String invoicePrefix;
  final int nextInvoiceNumber;
  final int nextApiInvoiceNumber;
  final int nextApiBillNumber;
  final int nextEstimateNumber;

  final String gasSafeNumber;

  final String? logoPath;
  final String postalCode;
  final String paymentDetails;

  AccountingSettings({
    required this.businessName,
    required this.engineerName,
    required this.businessAddress,
    required this.businessEmail,
    required this.businessPhone,
    required this.vatRegistered,
    required this.vatNumber,
    required this.invoicePrefix,
    required this.nextInvoiceNumber,
    required this.nextApiInvoiceNumber,
    required this.nextApiBillNumber,
    required this.nextEstimateNumber,
    required this.logoPath,
    required this.gasSafeNumber,
    required this.postalCode,
    required this.paymentDetails,
  });

  factory AccountingSettings.defaultSettings() => AccountingSettings(
      businessName: "",
      businessAddress: "",
      engineerName: "",
      businessEmail: "",
      businessPhone: "",
      vatRegistered: true,
      vatNumber: "",
      invoicePrefix: "INV",
      nextInvoiceNumber: 1,
      nextApiInvoiceNumber: 1,
      nextApiBillNumber: 1,
      nextEstimateNumber: 1,
      logoPath: "",
      gasSafeNumber: "",
      postalCode: "",
      paymentDetails: "");

  factory AccountingSettings.fromJson(Map<String, dynamic> json) =>
      AccountingSettings(
        businessName: json['businessName'],
        engineerName: json['engineerName'],
        businessAddress: json['businessAddress'],
        businessEmail: json['businessEmail'],
        businessPhone: json['businessPhone'],
        vatRegistered: json['vatRegistered'],
        vatNumber: json['vatNumber'],
        invoicePrefix: json['invoicePrefix'],
        nextInvoiceNumber: json['nextInvoiceNumber'],
        nextApiInvoiceNumber: json['nextApiInvoiceNumber'],
        nextApiBillNumber: json['nextApiBillNumber'],
        nextEstimateNumber: json['nextEstimateNumber'],
        logoPath: json['logoPath'],
        gasSafeNumber: json['gasSafeNumber'],
        postalCode: json['postalCode'],
        paymentDetails: json['paymentDetails'],
      );

  Map<String, dynamic> toJson() => {
        'businessName': businessName,
        'businessAddress': businessAddress,
        'engineerName': engineerName,
        'businessEmail': businessEmail,
        'businessPhone': businessPhone,
        'vatRegistered': vatRegistered,
        'vatNumber': vatNumber,
        'invoicePrefix': invoicePrefix,
        'nextInvoiceNumber': nextInvoiceNumber,
        'nextApiInvoiceNumber': nextApiInvoiceNumber,
        'nextApiBillNumber': nextApiBillNumber,
        'nextEstimateNumber': nextEstimateNumber,
        'logoPath': logoPath,
        'gasSafeNumber': gasSafeNumber,
        'postalCode': postalCode,
        'paymentDetails': paymentDetails,
      };
}

class OcrResponse {
  bool? success;
  OcrData? data;

  OcrResponse({this.success, this.data});

  OcrResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new OcrData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class OcrData {
  String? supplierName;
  String? invoiceNumber;
  String? date;
  String? currency;
  List<OcrLineItems>? lineItems;
  double? netTotal;
  double? vatAmount;
  double? grossTotal;
  String? supplierAddress;
  String? supplierPhone;
  String? supplierVatNumber;
  String? paymentMethod;
  String? notes;

  OcrData(
      {this.supplierName,
      this.invoiceNumber,
      this.date,
      this.currency,
      this.lineItems,
      this.netTotal,
      this.vatAmount,
      this.grossTotal,
      this.supplierAddress,
      this.supplierPhone,
      this.supplierVatNumber,
      this.paymentMethod,
      this.notes});

  OcrData.fromJson(Map<String, dynamic> json) {
    supplierName = json['supplierName'];
    invoiceNumber = json['invoiceNumber'];
    date = json['date'];
    currency = json['currency'];
    if (json['lineItems'] != null) {
      lineItems = <OcrLineItems>[];
      json['lineItems'].forEach((v) {
        lineItems!.add(new OcrLineItems.fromJson(v));
      });
    }
    netTotal = double.tryParse(json['netTotal'].toString()) ?? 0.0;
    vatAmount = double.tryParse(json['vatAmount'].toString()) ?? 0.0;
    grossTotal = double.tryParse(json['grossTotal'].toString()) ?? 0.0;
    supplierAddress = json['supplierAddress'];
    supplierPhone = json['supplierPhone'];
    supplierVatNumber = json['supplierVatNumber'];
    paymentMethod = json['paymentMethod'];
    notes = json['notes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['supplierName'] = this.supplierName;
    data['invoiceNumber'] = this.invoiceNumber;
    data['date'] = this.date;
    data['currency'] = this.currency;
    if (this.lineItems != null) {
      data['lineItems'] = this.lineItems!.map((v) => v.toJson()).toList();
    }
    data['netTotal'] = this.netTotal;
    data['vatAmount'] = this.vatAmount;
    data['grossTotal'] = this.grossTotal;
    data['supplierAddress'] = this.supplierAddress;
    data['supplierPhone'] = this.supplierPhone;
    data['supplierVatNumber'] = this.supplierVatNumber;
    data['paymentMethod'] = this.paymentMethod;
    data['notes'] = this.notes;
    return data;
  }
}

class OcrLineItems {
  String? description;
  String? productCode;
  int? quantity;
  double? unitPrice;
  double? vatRate;
  double? lineTotal;

  OcrLineItems(
      {this.description,
      this.productCode,
      this.quantity,
      this.unitPrice,
      this.vatRate,
      this.lineTotal});

  OcrLineItems.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    productCode = json['productCode'];
    quantity = json['quantity'];
    unitPrice = double.tryParse(json['unitPrice'].toString()) ?? 0.0;
    vatRate = double.tryParse(json['vatRate'].toString()) ?? 0.0;
    lineTotal = double.tryParse(json['lineTotal'].toString()) ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['productCode'] = this.productCode;
    data['quantity'] = this.quantity;
    data['unitPrice'] = this.unitPrice;
    data['vatRate'] = this.vatRate;
    data['lineTotal'] = this.lineTotal;
    return data;
  }
}
