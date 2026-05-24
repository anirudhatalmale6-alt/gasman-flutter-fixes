class InvoiceDetailMaster {
  Invoice? invoice;

  Customer? customer;
  List<Lines>? lines;

  InvoiceDetailMaster({this.invoice,this.customer, this.lines});

  InvoiceDetailMaster.fromJson(Map<String, dynamic> json) {
    invoice =
    json['invoice'] != null ? new Invoice.fromJson(json['invoice']) : null;
    customer = json['customer'] != null
        ? new Customer.fromJson(json['customer'])
        : null;
    if (json['lines'] != null) {
      lines = <Lines>[];
      json['lines'].forEach((v) {
        lines!.add(new Lines.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.invoice != null) {
      data['invoice'] = this.invoice!.toJson();
    }
    if (this.customer != null) {
      data['customer'] = this.customer!.toJson();
    }
    if (this.lines != null) {
      data['lines'] = this.lines!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Invoice {
  int? id;
  int? companyId;
  int? customerId;
  String? invoiceNumber;
  String? invoiceDate;
  String? dueDate;
  String? status;
  String? netTotal;
  String? vatTotal;
  String? total;
  String? createdAt;
  String? updatedAt;
  int? journalEntryId;
  String? balance;
  String? note;

  Invoice(
      {this.id,
        this.companyId,
        this.customerId,
        this.invoiceNumber,
        this.invoiceDate,
        this.dueDate,
        this.status,
        this.netTotal,
        this.vatTotal,
        this.total,
        this.createdAt,
        this.updatedAt,
        this.journalEntryId,
        this.balance,this.note = ""});

  Invoice.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    companyId = json['company_id'];
    customerId = json['customer_id'];
    invoiceNumber = json['invoice_number'];
    invoiceDate = json['invoice_date'];
    dueDate = json['due_date'];
    status = json['status'];
    netTotal = json['net_total'];
    vatTotal = json['vat_total'];
    total = json['total'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    journalEntryId = json['journal_entry_id'];
    balance = json['balance'];
    note = json['note'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['company_id'] = this.companyId;
    data['customer_id'] = this.customerId;
    data['invoice_number'] = this.invoiceNumber;
    data['invoice_date'] = this.invoiceDate;
    data['due_date'] = this.dueDate;
    data['status'] = this.status;
    data['net_total'] = this.netTotal;
    data['vat_total'] = this.vatTotal;
    data['total'] = this.total;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['journal_entry_id'] = this.journalEntryId;
    data['balance'] = this.balance;
    data['note'] = this.note;
    return data;
  }
}

class Lines {
  int? id;
  int? invoiceId;
  int? productId;
  String? description;
  int? quantity;
  String? unitPrice;
  String? lineTotal;
  String? vatRate;

  Lines(
      {this.id,
        this.invoiceId,
        this.productId,
        this.description,
        this.quantity,
        this.unitPrice,
        this.lineTotal,
        this.vatRate});

  Lines.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    invoiceId = json['invoice_id'];
    productId = json['product_id'];
    description = json['description'];
    quantity = json['quantity'];
    unitPrice = json['unit_price'];
    lineTotal = json['line_total'];
    vatRate = json['vat_rate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['invoice_id'] = this.invoiceId;
    data['product_id'] = this.productId;
    data['description'] = this.description;
    data['quantity'] = this.quantity;
    data['unit_price'] = this.unitPrice;
    data['line_total'] = this.lineTotal;
    data['vat_rate'] = this.vatRate;
    return data;
  }
}

class Customer {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? address;
  String? vatNumber;
  String? contactPerson;

  Customer(
      {this.id,
        this.name,
        this.email,
        this.phone,
        this.address,
        this.vatNumber,
        this.contactPerson});

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    address = json['address'];
    vatNumber = json['vatNumber'];
    contactPerson = json['contactPerson'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['address'] = this.address;
    data['vatNumber'] = this.vatNumber;
    data['contactPerson'] = this.contactPerson;
    return data;
  }
}