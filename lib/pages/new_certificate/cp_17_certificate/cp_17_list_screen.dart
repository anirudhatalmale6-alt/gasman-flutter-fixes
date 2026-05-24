import 'package:flutter/material.dart';
import 'cp_17_certificate_model.dart';
import 'cp_17_db_services.dart';
import 'cp_17_form_screen.dart';

class Cp17ListScreen extends StatefulWidget {
  const Cp17ListScreen({super.key});

  @override
  State<Cp17ListScreen> createState() => _Cp17ListScreenState();
}

class _Cp17ListScreenState extends State<Cp17ListScreen> {
  List<Cp17Certificate> certificates = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadCertificates();
  }

  Future<void> loadCertificates() async {
    setState(() => loading = true);

    certificates = await Cp17DbService.getCertificates();

    if (!mounted) return;
    setState(() => loading = false);
  }

  Future<void> openCertificate([
    Cp17Certificate? certificate,
  ]) async {
    String nextCertNumber = await getNextCertificateNumber();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Cp17FormScreen(
          existingCertificate: certificate,
          nextCertNumber: nextCertNumber,
        ),
      ),
    );

    loadCertificates();
  }

  Future<String> getNextCertificateNumber() async {
    if (certificates == null || certificates.isEmpty) {
      return "CP17-00001"; // first record
    }
    final last = certificates.last;
    final lastNumberStr = last.certificateNumber ?? "CP17-00000";
    final numberPart = lastNumberStr.toString().replaceAll("CP17-", "");
    int number = int.tryParse(numberPart) ?? 0;
    number++; // increment
    final newNumber = number.toString().padLeft(5, '0');
    return "CP17-$newNumber";
  }

  Future<void> deleteCertificate(
      Cp17Certificate certificate,
      ) async {
    if (certificate.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete CP17?'),
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

    await Cp17DbService.deleteCertificate(certificate.id!);

    loadCertificates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CP17 Certificates'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openCertificate(),
        icon: const Icon(Icons.add),
        label: const Text('New CP17'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : certificates.isEmpty
          ? const Center(
        child: Text('No CP17 certificates yet.'),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: certificates.length,
        itemBuilder: (context, index) {
          final certificate = certificates[index];

          return Card(
            child: ListTile(
              leading: Icon(
                certificate.locked
                    ? Icons.lock
                    : Icons.health_and_safety,
              ),
              title: Text(
                certificate.siteName.isEmpty
                    ? 'Unnamed CP17'
                    : certificate.siteName,
              ),
              subtitle: Text(
                '${certificate.certificateNumber}\n${certificate.siteAddress}',
              ),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () =>
                    deleteCertificate(certificate),
              ),
              onTap: () => openCertificate(certificate),
            ),
          );
        },
      ),
    );
  }
}

