import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_gas_man_app/main.dart';
import 'package:the_gas_man_app/pages/market_place/market_place_service.dart';
import 'package:the_gas_man_app/pages/new_certificate/common_models/landloard_gas_safety_record.dart';
import 'package:the_gas_man_app/pages/new_certificate/gas_service_record/new_service_record_page.dart';
import 'package:the_gas_man_app/pages/new_certificate/home_owner_gst/home_owner_gst_new_page.dart';
import 'package:the_gas_man_app/pages/new_invoice_page/data_model/all_models.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/api_service/auth_token_store.dart';
import 'package:uuid/uuid.dart';

import '../models/company_settings.dart';
import '../models/invoice_doc.dart';
import '../models/job.dart';
import '../pages/new_certificate/landloard_gst_safety_page/landloard_gas_safety_page.dart';
import '../pages/new_invoice_page/account_storage_file.dart';

final keyJobs = "jobs";

class AppModel extends ChangeNotifier {
  final _uuid = const Uuid();

  bool? isLoggedIn = false;
  bool? isMarketPlaceUserLoggedIn = false;

  final AccountStorage storage = AccountStorage();

  List<HomeownerGasSafetyRecord> homeRecords = [];
  List<ServiceRecord> serviceRecords = [];
  List<LandlordGasSafetyRecord> landloardRecrds = [];

  List<HomeownerGasSafetyRecord> allHomeRecords = [];
  List<ServiceRecord> allServiceRecords = [];
  List<LandlordGasSafetyRecord> allLandloardRecrds = [];

  // Simple memory load/save placeholders (swap for persistence as needed)
  Future<void> load() async {
    // Defaults for demo
    checkIsLogged();
    checkMarketPlaceIsLogged();
    await storage.load();
    Future.wait([
      getLandloardCertificates(DateTime.now()),
      getHomeOwnerCertificateList(DateTime.now()),
      getServiceRecordList(DateTime.now()),
    ]);
  }

  void checkIsLogged() async {
    String? secureAuthToken = await AuthTokenStore.read();
    if (secureAuthToken != null && secureAuthToken.isNotEmpty) {
      isLoggedIn = true;
    } else {
      isLoggedIn = false;
    }
  }

  void checkMarketPlaceIsLogged() async {
    MarketplaceService marketplaceService = MarketplaceService.instance;
    if (marketplaceService.authUser != null) {
      isMarketPlaceUserLoggedIn = true;
    } else {
      isMarketPlaceUserLoggedIn = false;
    }
  }

  Future<void> getLandloardCertificates(DateTime selectedDate) async {
    landloardRecrds.clear();

    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('latest_lgs_record');

    if (data != null) {
      final List decoded = jsonDecode(data);

      final allRecords =
          decoded.map((e) => LandlordGasSafetyRecord.fromJson(e)).toList();
      allLandloardRecrds = List.from(allRecords);
      // ✅ Filter by reminderDate
      landloardRecrds = allRecords.where((record) {
        final date = parseDate(record.reminderDate);

        if (date == null) return false;

        return date.year == selectedDate.year &&
            date.month == selectedDate.month &&
            date.day == selectedDate.day;
      }).toList();
    } else {
      landloardRecrds = [];
    }
  }

  Future<void> getHomeOwnerCertificateList(DateTime selectedDate) async {
    homeRecords.clear();

    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('latest_homeowner_gs_record');

    if (data != null) {
      final decoded = jsonDecode(data);

      List<HomeownerGasSafetyRecord> allRecords;

      if (decoded is List) {
        allRecords =
            decoded.map((e) => HomeownerGasSafetyRecord.fromJson(e)).toList();
      } else {
        allRecords = [HomeownerGasSafetyRecord.fromJson(decoded)];
      }
      allHomeRecords = List.from(allRecords);
      // ✅ Filter by reminderDate
      homeRecords = allRecords.where((record) {
        final date = parseDate(record.reminderDate);
        if (date == null) return false;

        return date.year == selectedDate.year &&
            date.month == selectedDate.month &&
            date.day == selectedDate.day;
      }).toList();
    } else {
      homeRecords = [];
    }
  }

  Future<void> getServiceRecordList(DateTime selectedDate) async {
    serviceRecords.clear();

    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('latest_service_record');

    if (data != null) {
      final decoded = jsonDecode(data);

      List<ServiceRecord> allRecords;

      if (decoded is List) {
        allRecords = decoded.map((e) => ServiceRecord.fromJson(e)).toList();
      } else {
        allRecords = [ServiceRecord.fromJson(decoded)];
      }
      allServiceRecords = List.from(allRecords);
      // ✅ Filter by reminderDate
      serviceRecords = allRecords.where((record) {
        final date = parseDate(record.reminderDate);
        if (date == null) return false;

        return date.year == selectedDate.year &&
            date.month == selectedDate.month &&
            date.day == selectedDate.day;
      }).toList();
    } else {
      serviceRecords = [];
    }
  }

  Future<void> deleteHomeRecord(int originalIndex) async {
    final confirm = await showDialog(
      context: mainKey!.currentContext!,
      builder: (_) => AlertDialog(
        title: const Text("Delete Record"),
        content: const Text("Are you sure you want to delete this record?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(mainKey!.currentContext!, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(mainKey!.currentContext!, true),
              child: const Text("Delete")),
        ],
      ),
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('latest_homeowner_gs_record');

    if (data == null) return;

    final decoded = jsonDecode(data);
    List list = decoded is List ? decoded : [decoded];

    list.removeAt(originalIndex);

    await prefs.setString('latest_homeowner_gs_record', jsonEncode(list));

    homeRecords.removeAt(originalIndex);
    notifyListeners();
  }

  Future<void> deleteLandloardGasRecord(int index) async {
    final confirm = await showDialog(
      context: mainKey!.currentContext!,
      builder: (_) => AlertDialog(
        title: const Text("Delete Record"),
        content: const Text("Are you sure you want to delete this record?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(mainKey!.currentContext!, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(mainKey!.currentContext!, true),
              child: const Text("Delete")),
        ],
      ),
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('latest_lgs_record');

    if (data == null) return;

    List list = jsonDecode(data);
    list.removeAt(index);

    await prefs.setString('latest_lgs_record', jsonEncode(list));

    serviceRecords.removeAt(index);
    notifyListeners();
  }

  Future<void> deleteServiceRecord(int originalIndex) async {
    final confirm = await showDialog(
      context: mainKey!.currentContext!,
      builder: (_) => AlertDialog(
        title: const Text("Delete Record"),
        content: const Text("Are you sure you want to delete this record?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(mainKey!.currentContext!, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(mainKey!.currentContext!, true),
              child: const Text("Delete")),
        ],
      ),
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('latest_service_record');

    if (data == null) return;

    List list = jsonDecode(data);
    list.removeAt(originalIndex);

    await prefs.setString('latest_service_record', jsonEncode(list));

    serviceRecords.removeAt(originalIndex);
    notifyListeners();
  }

  DateTime? parseDate(String date) {
    try {
      final parts = date.split('/'); // dd-MM-yyyy
      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    } catch (e) {
      return null;
    }
  }
}
