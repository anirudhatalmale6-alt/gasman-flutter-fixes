class BillDetails {
  Bill? bill;

  Supplier? supplier;
  List<BillLines>? lines;

  BillDetails({this.bill, this.supplier,this.lines});

  BillDetails.fromJson(Map<String, dynamic> json) {
    bill = json['bill'] != null ? new Bill.fromJson(json['bill']) : null;
    supplier = json['supplier'] != null
        ? new Supplier.fromJson(json['supplier'])
        : null;
    if (json['lines'] != null) {
      lines = <BillLines>[];
      json['lines'].forEach((v) {
        lines!.add(new BillLines.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.bill != null) {
      data['bill'] = this.bill!.toJson();
    }
    if (this.supplier != null) {
      data['supplier'] = this.supplier!.toJson();
    }
    if (this.lines != null) {
      data['lines'] = this.lines!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Bill {
  int? id;
  int? companyId;
  int? supplierId;
  String? billNumber;
  String? billDate;
  String? dueDate;
  String? status;
  String? total;
  String? createdAt;
  String? updatedAt;
  int? journalEntryId;
  String? balance;

  Bill(
      {this.id,
      this.companyId,
      this.supplierId,
      this.billNumber,
      this.billDate,
      this.dueDate,
      this.status,
      this.total,
      this.createdAt,
      this.updatedAt,
      this.journalEntryId,
      this.balance});

  Bill.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    companyId = json['company_id'];
    supplierId = json['supplier_id'];
    billNumber = json['bill_number'];
    billDate = json['bill_date'];
    dueDate = json['due_date'];
    status = json['status'];
    total = json['total'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    journalEntryId = json['journal_entry_id'];
    balance = json['balance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['company_id'] = this.companyId;
    data['supplier_id'] = this.supplierId;
    data['bill_number'] = this.billNumber;
    data['bill_date'] = this.billDate;
    data['due_date'] = this.dueDate;
    data['status'] = this.status;
    data['total'] = this.total;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['journal_entry_id'] = this.journalEntryId;
    data['balance'] = this.balance;
    return data;
  }
}

class Supplier {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? address;
  String? vatNumber;
  String? contactPerson;

  Supplier(
      {this.id,
      this.name,
      this.email,
      this.phone,
      this.address,
      this.vatNumber,
      this.contactPerson});

  Supplier.fromJson(Map<String, dynamic> json) {
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

class BillLines {
  int? id;
  int? billId;
  String? description;
  int? quantity;
  String? unitCost;
  String? lineTotal;
  String? vatRate;

  BillLines(
      {this.id,
      this.billId,
      this.description,
      this.quantity,
      this.unitCost,
      this.lineTotal,
      this.vatRate});

  BillLines.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    billId = json['bill_id'];
    description = json['description'];
    quantity = json['quantity'];
    unitCost = json['unit_cost'];
    lineTotal = json['line_total'];
    vatRate = json['vat_rate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['bill_id'] = this.billId;
    data['description'] = this.description;
    data['quantity'] = this.quantity;
    data['unit_cost'] = this.unitCost;
    data['line_total'] = this.lineTotal;
    data['vat_rate'] = this.vatRate;
    return data;
  }
}
