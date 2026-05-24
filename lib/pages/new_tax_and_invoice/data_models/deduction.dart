class Deduction {
  final int id;
  final int subcontractorId;
  final String description;
  final String date;

  final double grossAmount;
  final double materialsAmount;
  final double labourAmount;
  final double deductionAmount;
  final double netPayment;

  Deduction({
    required this.id,
    required this.subcontractorId,
    required this.description,
    required this.date,
    required this.grossAmount,
    required this.materialsAmount,
    required this.labourAmount,
    required this.deductionAmount,
    required this.netPayment,
  });

  factory Deduction.fromJson(Map<String, dynamic> json) {
    return Deduction(
      id: json['id'],
      subcontractorId: json['subcontractor_id'],
      description: json['description'] ?? '',
      date: json['date'] ?? '',
      grossAmount: (json['gross_amount'] ?? 0).toDouble(),
      materialsAmount: (json['materials_amount'] ?? 0).toDouble(),
      labourAmount: (json['labour_amount'] ?? 0).toDouble(),
      deductionAmount: (json['deduction_amount'] ?? 0).toDouble(),
      netPayment: (json['net_payment'] ?? 0).toDouble(),
    );
  }
}