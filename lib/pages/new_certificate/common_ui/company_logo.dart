import 'dart:io';
import 'package:flutter/material.dart';
import 'package:the_gas_man_app/pages/new_invoice_page/account_storage_file.dart';
import 'package:the_gas_man_app/pages/new_invoice_page/data_model/all_models.dart';

class CompanyLogo extends StatelessWidget {
  const CompanyLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final AccountingSettings settings = AccountStorage().settings;

    final String? logoPath = settings.logoPath;
    final File? logoFile =
    (logoPath != null && logoPath.isNotEmpty) ? File(logoPath) : null;

    final bool hasLogo =
        logoFile != null && logoFile.existsSync();

    return CircleAvatar(
      radius: 40,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: hasLogo ? FileImage(logoFile) : null,
      child: hasLogo
          ? null
          : const Icon(
        Icons.photo,
        size: 30,
        color: Colors.grey,
      ),
    );
  }
}