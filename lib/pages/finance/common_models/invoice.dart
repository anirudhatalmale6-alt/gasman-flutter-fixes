/*class Invoice {
  final String id;
  final String documentNumber;
  final String customerName;
  final double total;
  final DateTime date;
  final InvoiceStatus status;

  Invoice({
    required this.id,
    required this.documentNumber,
    required this.customerName,
    required this.total,
    required this.date,
    required this.status,
  });
}

enum InvoiceStatus { draft, sent, paid }*/


import 'dart:convert';

enum InvoiceStatus { draft, sent, paid }

class Invoice {
  String id;
  String documentNumber;
  String customerName;
  DateTime date;
  List<InvoiceItem> items;
  double total;
  InvoiceStatus status;

  Invoice({
    required this.id,
    required this.documentNumber,
    required this.customerName,
    required this.date,
    required this.items,
    required this.total,
    this.status = InvoiceStatus.draft,
  });

  /// Convert enum -> String
  String get statusString => status.name;

  /// Convert object -> Map
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "documentNumber": documentNumber,
      "customerName": customerName,
      "date": date.toIso8601String(),
      "items": items.map((e) => e.toMap()).toList(),
      "total": total,
      "status": status.name,
    };
  }

  /// Map -> Object
  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map["id"],
      documentNumber: map["documentNumber"],
      customerName: map["customerName"],
      date: DateTime.parse(map["date"]),
      items: List<InvoiceItem>.from(
        map["items"].map((x) => InvoiceItem.fromMap(x)),
      ),
      total: (map["total"] ?? 0).toDouble(),
      status: InvoiceStatus.values.firstWhere(
            (e) => e.name == map["status"],
        orElse: () => InvoiceStatus.draft,
      ),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Invoice.fromJson(String source) =>
      Invoice.fromMap(jsonDecode(source));
}

class InvoiceItem {
  String description;
  double qty;
  double unitPrice;

  InvoiceItem({
    required this.description,
    required this.qty,
    required this.unitPrice,
  });

  double get total => qty * unitPrice;

  Map<String, dynamic> toMap() {
    return {
      "description": description,
      "qty": qty,
      "unitPrice": unitPrice,
    };
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      description: map["description"],
      qty: (map["qty"] ?? 0).toDouble(),
      unitPrice: (map["unitPrice"] ?? 0).toDouble(),
    );
  }
}


