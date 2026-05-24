
class ReceiptGuess {
  final String? supplierName;
  final String? date; // YYYY-MM-DD
  final double? totalAmount;
  final double? vatAmount;
  final String? description;
  final String? rawText;

  ReceiptGuess({
    this.supplierName,
    this.date,
    this.totalAmount,
    this.vatAmount,
    this.description,
    this.rawText,
  });
}
