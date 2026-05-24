import 'package:flutter/material.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/vat_return/vat_obligation_list.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/vat_return/vat_return_screen.dart';
import 'package:the_gas_man_app/services/vat_return_service.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class HmrcConnectionScreen extends StatefulWidget {
  const HmrcConnectionScreen({super.key});

  @override
  State<HmrcConnectionScreen> createState() =>
      _HmrcConnectionScreenState();
}

class _HmrcConnectionScreenState extends State<HmrcConnectionScreen> {
  final _svc = VatReturnService();

  bool loading = true;
  bool connected = false;
  bool tokenExpired = false;

  @override
  void initState() {
    super.initState();
    checkStatus();
  }

  Future<void> checkStatus() async {
    try {
      setState(() => loading = true);

      final res = await _svc.checkHMRCConnection();

      connected = res!['connected'] ?? false;
      tokenExpired = res['tokenExpired'] ?? false;
    } catch (e) {
      print(e);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> connectHmrc() async {
    try {
      final url = await _svc.getAuthUrl();

      // 🔥 Open browser
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

      // Wait & re-check after returning
      await Future.delayed(const Duration(seconds: 5));
      await checkStatus();
    } catch (e) {
      print(e);
    }
  }

  Future<void> disconnectHmrc() async {
    await _svc.disconnect();
    await checkStatus();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("HMRC Connection")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            connected ? _connectedUI() : _disconnectedUI(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: (){
                push(ObligationListScreen());
              },
              child: const Text("My Obligations"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _disconnectedUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("HMRC not connected"),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: connectHmrc,
          child: const Text("Connect HMRC"),
        ),

      ],
    );
  }

  Widget _connectedUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("HMRC Connected ✅"),
        if (tokenExpired)
          const Text(
            "Token Expired ⚠️",
            style: TextStyle(color: Colors.red),
          ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: disconnectHmrc,
          child: const Text("Disconnect"),
        ),
      ],
    );
  }
}