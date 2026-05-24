import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FindMerchantsPage extends StatefulWidget { const FindMerchantsPage({super.key}); @override State<FindMerchantsPage> createState()=>_FindMerchantsPageState(); }

class _FindMerchantsPageState extends State<FindMerchantsPage> {
  final pc = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find Local Merchants')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Enter a UK postcode, then open in Google Maps:'),
        const SizedBox(height: 8),
        TextField(controller: pc, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(labelText: 'Postcode (e.g. LS1 2AB)', filled: true)),
        const SizedBox(height: 12),
        ElevatedButton.icon(onPressed: _openMaps, icon: const Icon(Icons.map_outlined), label: const Text('Open in Google Maps')),
        const SizedBox(height: 12),
        const Text('Recommended plumbing merchants below',style: TextStyle(
          fontSize: 18.0
        ),),
      ]),
    );
  }
  Future<void> _openMaps() async {
    final query = Uri.encodeComponent('plumbing merchants near ${pc.text}');
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
