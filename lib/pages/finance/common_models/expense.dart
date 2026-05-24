class Expense {
  final String id;
  final String category;
  final String supplier;
  final double net;
  final double vat;
  final DateTime date;
  final String? notes;

  Expense({
    required this.id,
    required this.category,
    required this.supplier,
    required this.net,
    required this.vat,
    required this.date,
    this.notes,
  });

}