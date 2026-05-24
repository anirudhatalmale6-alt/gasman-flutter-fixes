import 'package:flutter/material.dart';

import '../../../../services/cis_services.dart';
import '../../data_models/deduction.dart';
import '../../data_models/statement_model.dart';
import '../../data_models/sub_contractor.dart';


class StatementVM extends ChangeNotifier {
  final CISService _service = CISService();

  // ---------------- STATE ----------------

  bool isLoading = false;
  String? error;

  StatementModel? _statement;

  int? subcontractorId;

  String? fromDate;
  String? toDate;

  // ---------------- GETTERS ----------------

  Subcontractor? get subcontractor => _statement?.subcontractor;

  List<Deduction> get deductions => _statement?.deductions ?? [];

  double get totalGross => _statement?.totalGross ?? 0;
  double get totalDeductions => _statement?.totalDeductions ?? 0;
  double get totalNet => _statement?.totalNet ?? 0;

  // ---------------- LOAD ----------------

  Future<void> load(
      int id, {
        String? from,
        String? to,
      }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      subcontractorId = id;
      fromDate = from;
      toDate = to;

      _statement = await _service.getStatement(
        id,
        from: from,
        to: to,
      );
    } catch (e) {
      error = e.toString();
      debugPrint("Statement Load Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ---------------- FILTER ----------------

  Future<void> applyFilter({
    required String from,
    required String to,
  }) async {
    if (subcontractorId == null) return;

    await load(
      subcontractorId!,
      from: from,
      to: to,
    );
  }

  // ---------------- RESET FILTER ----------------

  Future<void> clearFilter() async {
    if (subcontractorId == null) return;

    await load(subcontractorId!);
  }

  // ---------------- REFRESH ----------------

  Future<void> refresh() async {
    if (subcontractorId == null) return;

    await load(
      subcontractorId!,
      from: fromDate,
      to: toDate,
    );
  }
}