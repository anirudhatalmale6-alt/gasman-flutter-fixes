import 'package:flutter/material.dart';

import '../../../../services/cis_services.dart';
import '../../data_models/cis_return.dart';
import '../../data_models/tax_month.dart';


class ReturnsVM extends ChangeNotifier {
  final CISService _service = CISService();

  // ---------------- STATE ----------------

  bool isLoading = false;
  bool isSubmitting = false;

  String? error;

  List<TaxMonth> months = [];

  CISReturn? selectedReturn;

  String selectedMonth = "";

  // ---------------- LOAD MONTHS ----------------

  Future<void> load() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      months = await _service.getTaxMonths();
    } catch (e) {
      error = e.toString();
      debugPrint("Returns Load Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ---------------- OPEN RETURN ----------------

  Future<void> open(String month) async {
    try {
      isLoading = true;
      error = null;
      selectedMonth = month;
      notifyListeners();

      selectedReturn = await _service.getReturn(month);
    } catch (e) {
      error = e.toString();
      debugPrint("Open Return Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ---------------- SUBMIT RETURN ----------------

  Future<bool> submit(String contractorUtr) async {
    if (selectedMonth.isEmpty) return false;

    try {
      isSubmitting = true;
      notifyListeners();

      await _service.submitReturn(selectedMonth, contractorUtr);

      // Refresh data after submit
      await open(selectedMonth);
      await load();

      return true;
    } catch (e) {
      error = e.toString();
      debugPrint("Submit Return Error: $e");
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  // ---------------- HELPERS ----------------

  bool get isSubmitted => selectedReturn?.status == "submitted";

  double get totalGross => selectedReturn?.totalGross ?? 0;
  double get totalDeductions => selectedReturn?.totalDeductions ?? 0;
  double get totalNet => selectedReturn?.totalNet ?? 0;

  List get deductions => selectedReturn?.deductions ?? [];

  // ---------------- REFRESH ----------------

  Future<void> refresh() async {
    if (selectedMonth.isNotEmpty) {
      await open(selectedMonth);
    } else {
      await load();
    }
  }
}