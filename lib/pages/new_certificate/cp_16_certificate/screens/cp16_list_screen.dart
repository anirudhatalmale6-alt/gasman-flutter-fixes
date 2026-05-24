import 'package:flutter/material.dart';

import '../db_services/cp16_db_service.dart';
import '../models/cp_16_certificate.dart';
import 'cp16_form_screen.dart';

class Cp16ListScreen extends StatefulWidget {
  const Cp16ListScreen({super.key});

  @override
  State<Cp16ListScreen> createState() => _Cp16ListScreenState();
}

class _Cp16ListScreenState extends State<Cp16ListScreen> {
  List<Cp16Certificate> certificates = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadCertificates();
  }

  Future<void> loadCertificates() async {
    setState(() => loading = true);

    certificates = await Cp16DbService.getCertificates();

    if (!mounted) return;
    setState(() => loading = false);
  }

  Future<void> openCertificate([
    Cp16Certificate? certificate,
  ]) async {
    String nextCertNumber = await getNextCertificateNumber();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Cp16FormScreen(
          existingCertificate: certificate,
          nextCertNumber: nextCertNumber,
        ),
      ),
    );

    loadCertificates();
  }

  Future<String> getNextCertificateNumber() async {
    if (certificates == null || certificates.isEmpty) {
      return "CP16-000001"; // first record
    }
    final last = certificates.last;
    final lastNumberStr = last.certificateNumber ?? "CP16-00000";
    final numberPart = lastNumberStr.toString().replaceAll("CP16-", "");
    int number = int.tryParse(numberPart) ?? 0;
    number++; // increment
    final newNumber = number.toString().padLeft(5, '0');
    return "CP16-$newNumber";
  }

  Future<void> deleteCertificate(
    Cp16Certificate certificate,
  ) async {
    if (certificate.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete CP16?'),
        content: Text(
          'Are you sure you want to delete ${certificate.certificateRef}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await Cp16DbService.deleteCertificate(certificate.id!);

    loadCertificates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CP16 Certificates'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openCertificate(),
        icon: const Icon(Icons.add),
        label: const Text('New CP16'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : certificates.isEmpty
              ? const Center(
                  child: Text('No CP16 certificates yet.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: certificates.length,
                  itemBuilder: (context, index) {
                    final certificate = certificates[index];

                    return Card(
                      child: ListTile(
                        leading: Icon(
                          certificate.locked ? Icons.lock : Icons.science,
                        ),
                        title: Text(
                          certificate.siteName.isEmpty
                              ? 'Unnamed CP16'
                              : certificate.siteName,
                        ),
                        subtitle: Text(
                          '${certificate.certificateNumber}\n${certificate.siteAddress}',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => deleteCertificate(certificate),
                        ),
                        onTap: () => openCertificate(certificate),
                      ),
                    );
                  },
                ),
    );
  }
}
