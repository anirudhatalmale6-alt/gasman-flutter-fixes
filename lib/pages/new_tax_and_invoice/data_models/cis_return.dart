import 'deduction.dart';

class CISReturn {
  final String month;
  final String status;
  final String periodStart;
  final String periodEnd;

  final double totalGross;
  final double totalDeductions;
  final double totalNet;

  final List<Deduction> deductions;

  CISReturn({
    required this.month,
    required this.status,
    required this.periodStart,
    required this.periodEnd,
    required this.totalGross,
    required this.totalDeductions,
    required this.totalNet,
    required this.deductions,
  });

  factory CISReturn.fromJson(Map<String, dynamic> json) {
    return CISReturn(
      month: json['month'] ?? '',
      status: json['status'] ?? '',
      periodStart: json['period_start'] ?? '',
      periodEnd: json['period_end'] ?? '',
      totalGross: (json['total_gross'] ?? 0).toDouble(),
      totalDeductions: (json['total_deductions'] ?? 0).toDouble(),
      totalNet: (json['total_net'] ?? 0).toDouble(),
      deductions: (json['deductions'] as List? ?? [])
          .map((e) => Deduction.fromJson(e))
          .toList(),
    );
  }
}