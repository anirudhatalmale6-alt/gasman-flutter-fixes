class SummaryModel {
  final int subcontractorCount;
  final Summary currentMonth;
  final Summary yearToDate;
  final int pendingReturns;

  SummaryModel({
    required this.subcontractorCount,
    required this.currentMonth,
    required this.yearToDate,
    required this.pendingReturns,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      subcontractorCount: json['subcontractorCount'] ?? 0,
      currentMonth: Summary.fromJson(json['currentMonth'] ?? {}),
      yearToDate: Summary.fromJson(json['yearToDate'] ?? {}),
      pendingReturns: json['pendingReturns'] ?? 0,
    );
  }
}

class Summary {
  final double gross;
  final double deductions;
  final double net;

  Summary({
    required this.gross,
    required this.deductions,
    required this.net,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      gross: double.tryParse(json['total_gross'].toString()) ?? 0.0,
      deductions: double.tryParse(json['total_deductions'].toString()) ?? 0.0,
      net: double.tryParse(json['total_net'].toString()) ?? 0.0,
    );
  }
}