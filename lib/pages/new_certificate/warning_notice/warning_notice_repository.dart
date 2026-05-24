import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common_models/warning_notice_record.dart';

class WarningNoticeRepository extends ChangeNotifier {
  WarningNoticeRepository._();
  static final WarningNoticeRepository instance =
  WarningNoticeRepository._();

  final List<WarningNoticeRecord> _records = [];

  List<WarningNoticeRecord> get records => List.unmodifiable(_records);

  String nextNoticeNumber() {
    if (_records.isEmpty) return 'WN-00001';
    final last = _records.last.noticeNumber;
    final parts = last.split('-');
    int num = int.tryParse(parts[1]) ?? 0;
    num++;
    return 'WN-${num.toString().padLeft(5, '0')}';
  }

  void upsert(WarningNoticeRecord r) {
    final index = _records.indexWhere((e) => e.id == r.id);
    if (index == -1) {
      _records.add(r);
    } else {
      _records[index] = r;
    }
    _saveRecords();

    // TODO: Save to local storage
  }

  Future<void> _saveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('warning_records', jsonEncode(_records));
  }

  Future<WarningNoticeRecord?> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();

    final data = await prefs.getString('warning_records');

    if (data != null) {
      final WarningNoticeRecord decoded = WarningNoticeRecord.fromJson(jsonDecode(data));

      return decoded;
    }
    return null;
  }
}