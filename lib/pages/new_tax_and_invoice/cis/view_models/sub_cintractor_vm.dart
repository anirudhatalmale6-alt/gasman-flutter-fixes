import 'package:flutter/material.dart';

import '../../../../services/api_client.dart';
import '../../../../services/cis_services.dart';
import '../../data_models/sub_contractor.dart';

class SubcontractorVM extends ChangeNotifier {
  final service = CISService();

  Subcontractor? selected;

  List<Subcontractor> list = [];

  bool isLoading = false;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();

    list = await service.getSubcontractors();

    isLoading = false;
    notifyListeners();
  }

  Future<void> add(Map<String, dynamic> body) async {
    await service.addSubcontractor(body);
    await load();
  }

  Future<void> loadSingle(int id) async {
    isLoading = true;
    notifyListeners();

    selected = await getById(id);

    isLoading = false;
    notifyListeners();
  }

  Future<Subcontractor?> getById(int id) async {
    try {
      final api = await ApiClient.create();
      final res = await api.dio.get("/cis/subcontractors/$id");
      return Subcontractor.fromJson(res.data);
    } catch (e) {
      debugPrint("Get Subcontractor Error: $e");
      return null;
    }
  }

  Future<void> verify(int id) async {
    await service.verifySubcontractor(id);
    await load(); // refresh list
  }

  Future<bool> delete(int id) async {
    try {
      await service.deleteSubcontractor(id);

      // remove from list if present
      list.removeWhere((e) => e.id == id);

      // clear selected if it's the same one
      if (selected?.id == id) {
        selected = null;
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Delete Subcontractor Error: $e");
      return false;
    }
  }
}
