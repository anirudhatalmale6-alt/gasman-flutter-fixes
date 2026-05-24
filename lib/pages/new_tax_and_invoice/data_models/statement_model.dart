import 'deduction.dart';
import 'sub_contractor.dart';

class StatementModel {
  final Subcontractor subcontractor;
  final List<Deduction> deductions;

  final double totalGross;
  final double totalDeductions;
  final double totalNet;

  StatementModel({
    required this.subcontractor,
    required this.deductions,
    required this.totalGross,
    required this.totalDeductions,
    required this.totalNet,
  });

  factory StatementModel.fromJson(Map<String, dynamic> json) {
    return StatementModel(
      subcontractor:
      Subcontractor.fromJson(json['subcontractor'] ?? {}),
      deductions: (json['deductions'] as List? ?? [])
          .map((e) => Deduction.fromJson(e))
          .toList(),
      totalGross: (json['total_gross'] ?? 0).toDouble(),
      totalDeductions: (json['total_deductions'] ?? 0).toDouble(),
      totalNet: (json['total_net'] ?? 0).toDouble(),
    );
  }
}