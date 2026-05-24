import 'package:flutter/material.dart';
import '../../../../services/cis_services.dart';
import '../../data_models/summary_data.dart';

class DashboardVM extends ChangeNotifier {
  final CISService _service = CISService();

  bool isLoading = false;

  int count = 0;
  int pendingReturns = 0;

  Summary currentMonth = Summary(gross: 0, deductions: 0, net: 0);
  Summary ytd = Summary(gross: 0, deductions: 0, net: 0);

  Future<void> load() async {
    try {
      isLoading = true;
      notifyListeners();

      final res = await _service.getSummary();

      count = res.subcontractorCount;
      pendingReturns = res.pendingReturns;
      currentMonth = res.currentMonth;
      ytd = res.yearToDate;
    } catch (e) {
      debugPrint("Dashboard Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}