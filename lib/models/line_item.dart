class LineItem {
  final String description;
  final int qty;
  final double unitPrice;
  const LineItem({required this.description, required this.qty, required this.unitPrice});

  double get lineTotal => qty * unitPrice;
}
