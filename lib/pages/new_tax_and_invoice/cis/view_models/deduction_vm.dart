import 'package:flutter/material.dart';

import '../../../../services/cis_services.dart';
import '../../data_models/deduction.dart';

class DeductionVM extends ChangeNotifier {
  final CISService _service = CISService();

  List<Deduction> list = [];

  bool isLoading = false;
  bool isSaving = false;

  String? error;

  /// Format: "2026-04"
  String selectedMonth = "";

  // ---------------- LOAD ----------------

  Future<void> load({String? month}) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      selectedMonth = month ?? selectedMonth;

      list = await _service.getDeductions(
        month: selectedMonth.isEmpty ? null : selectedMonth,
      );
    } catch (e) {
      error = e.toString();
      debugPrint("Deduction Load Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ---------------- ADD ----------------

  Future<bool> add({
    required int subcontractorId,
    required String date,
    required String description,
    required double grossAmount,
    required double materialsAmount,
  }) async {
    try {
      isSaving = true;
      notifyListeners();

      await _service.addDeduction({
        "subcontractor_id": subcontractorId,
        "date": date,
        "description": description,
        "gross_amount": grossAmount,
        "materials_amount": materialsAmount,
      });

      await load(); // refresh list
      return true;
    } catch (e) {
      error = e.toString();
      debugPrint("Add Deduction Error: $e");
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  // ---------------- UPDATE ----------------

  Future<bool> update(
      int id, {
        required String description,
        required double grossAmount,
        required double materialsAmount,
      }) async {
    try {
      isSaving = true;
      notifyListeners();

      await _service.updateDeduction(id, {
        "description": description,
        "gross_amount": grossAmount,
        "materials_amount": materialsAmount,
      });

      await load();
      return true;
    } catch (e) {
      error = e.toString();
      debugPrint("Update Deduction Error: $e");
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  // ---------------- DELETE ----------------

  Future<bool> delete(int id) async {
    try {
      await _service.deleteDeduction(id);

      list.removeWhere((e) => e.id == id);
      notifyListeners();

      return true;
    } catch (e) {
      error = e.toString();
      debugPrint("Delete Deduction Error: $e");
      return false;
    }
  }

  // ---------------- FILTER ----------------

  Future<void> changeMonth(String month) async {
    selectedMonth = month;
    await load(month: month);
  }

  // ---------------- REFRESH ----------------

  Future<void> refresh() async {
    await load(month: selectedMonth);
  }
}