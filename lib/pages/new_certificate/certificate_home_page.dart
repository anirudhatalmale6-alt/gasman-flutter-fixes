import 'package:flutter/material.dart';
import 'package:the_gas_man_app/pages/new_certificate/certificate_list/gas_service_record_list.dart';
import 'package:the_gas_man_app/pages/new_certificate/certificate_list/home_owner_record_list.dart';
import 'package:the_gas_man_app/pages/new_certificate/cp_16_certificate/screens/cp16_list_screen.dart';
import 'package:the_gas_man_app/pages/new_certificate/cp_17_certificate/cp_17_list_screen.dart';
import 'breakdown_record/breakdown_record_page.dart';
import 'certificate_list/breakdown_record_list.dart';
import 'certificate_list/installation_and_commision_list.dart';
import 'home_owner_gst/home_owner_gst_new_page.dart';
import 'installation_and_commision/installation_and_comissioning_page.dart';
import 'gas_service_record/new_service_record_page.dart';
import '../new_certificate/warning_notice/warning_notice_page.dart';
import 'certificate_list/landloard_certificate_list.dart';
import 'certificate_list/warning_record_list.dart';
import 'landloard_gst_safety_page/landloard_gas_safety_page.dart';

class CertificatesHomePage extends StatelessWidget {
  const CertificatesHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Certificates')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          // _tile(context, 'Landlord Gas Safety Record (Can be deleted)', const LandlordGsrPage()),
          _tile(context, 'Landlord Gas Safety Record',
              const LandlordRecordsListScreen()),
          _tile(
              context, 'Homeowner Gas Safety Record', const HomeownerRecordsListScreen()),
          _tile(context, 'Warning Notice', const WarningRecordsListScreen()),
          _tile(context, 'Service Record', const GasServiceRecordsListScreen()),
          _tile(context, 'Breakdown / Repair Record',
              const BreakdownRecordsListScreen()),
          // _tile(context, 'Installation / Commissioning',
          //     const CommissioningChecklistPage()),
          _tile(context, 'Installation / Commissioning',
              const InstallationCommissionRecordListScreen()),
          _tile(context, 'CP16 Commercial certificate',
              const Cp16ListScreen()),
          _tile(context, 'CP17 Commercial certificate',
              const Cp17ListScreen()),
        ]));
  }

  Widget _tile(BuildContext ctx, String title, Widget page) => Card(
      child: ListTile(
          title: Text(title),
          trailing: const Icon(Icons.chevron_right),
          onTap: () =>
              Navigator.push(ctx, MaterialPageRoute(builder: (_) => page))));
}
