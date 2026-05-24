class TaxMonth {
  final String month;
  final String status;

  TaxMonth({
    required this.month,
    required this.status,
  });

  factory TaxMonth.fromJson(Map<String, dynamic> json) {
    return TaxMonth(
      month: json['month'] ?? '',
      status: json['status'] ?? '',
    );
  }
}