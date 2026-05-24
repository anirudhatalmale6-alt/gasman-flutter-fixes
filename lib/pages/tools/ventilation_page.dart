import 'package:flutter/material.dart';

class VentilationPage extends StatefulWidget { const VentilationPage({super.key}); @override State<VentilationPage> createState()=>_VentilationPageState(); }

class _VentilationPageState extends State<VentilationPage> {
  String applianceType = 'Room sealed boiler';
  final kw = TextEditingController();
  double? reqArea;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Ventilation Calculator')), body: ListView(padding: const EdgeInsets.all(16), children: [
      DropdownButtonFormField<String>(value: applianceType, items: const [
        DropdownMenuItem(value:'Room sealed boiler', child: Text('Room sealed boiler')),
        DropdownMenuItem(value:'Open flue boiler', child: Text('Open flue boiler')),
        DropdownMenuItem(value:'Cooker (no cooling fan)', child: Text('Cooker (no cooling fan)')),
      ], onChanged: (v)=>setState(()=>applianceType=v??applianceType)),
      const SizedBox(height: 8),
      TextField(controller: kw, decoration: const InputDecoration(labelText:'Net heat input (kW)', filled:true), keyboardType: TextInputType.number),
      const SizedBox(height: 12),
      ElevatedButton(onPressed: _calc, child: const Text('Calculate')),
      if (reqArea!=null) Padding(padding: const EdgeInsets.only(top:12), child: Card(child: Padding(padding: const EdgeInsets.all(12), child: Text('Required free area: ${reqArea!.toStringAsFixed(0)} cm²')))),
    ]));
  }

  void _calc() {
    final k = double.tryParse(kw.text)??0;
    if (k<=0) return;
    double factor = 0;
    switch (applianceType) {
      case 'Room sealed boiler': factor = 0; break;
      case 'Open flue boiler': factor = 5; break;
      case 'Cooker (no cooling fan)': factor = 10; break;
      default: factor = 5;
    }
    setState(()=>reqArea = factor*k);
  }
}
