
import 'line_item.dart';

enum DocType { invoice, quote, estimate }


class InvoiceDoc {
  final String id;
  final DocType type;
  final String customerName;
  final String jobAddress;
  final DateTime issueDate;
  final String refNumber;
  final List<LineItem> items;
  final double vatRate; // 0 for No VAT; e.g. 0.2 for 20%

  const InvoiceDoc({
    required this.id,
    required this.type,
    required this.customerName,
    required this.jobAddress,
    required this.issueDate,
    this.refNumber = '',
    required this.items,
    required this.vatRate,
  });

  double get subTotal => items.fold(0, (p, e) => p + e.unitPrice);
  double get vatAmount => subTotal * vatRate;
  double get total => subTotal + vatAmount;

  InvoiceDoc copyWith({
    DocType? type,
    String? customerName,
    String? jobAddress,
    DateTime? issueDate,
    String? refNumber,
    List<LineItem>? items,
    double? vatRate,
  }) => InvoiceDoc(
    id: id,
    type: type ?? this.type,
    customerName: customerName ?? this.customerName,
    jobAddress: jobAddress ?? this.jobAddress,
    issueDate: issueDate ?? this.issueDate,
    refNumber: refNumber ?? this.refNumber,
    items: items ?? this.items,
    vatRate: vatRate ?? this.vatRate,
  );
}
