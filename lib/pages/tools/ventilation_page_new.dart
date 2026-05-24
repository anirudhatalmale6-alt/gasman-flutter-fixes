import 'package:flutter/material.dart';

/// GAS MAN brand colours
const Color kTeal = Color(0xFF008080);
const Color kAmber = Color(0xFFFFB000);
const Color kDark = Color(0xFF0B2E2E);
const Color kLightBg = Color(0xFFF9F9F9);

class VentilationCalculatorPage extends StatefulWidget {
  const VentilationCalculatorPage({super.key});

  @override
  State<VentilationCalculatorPage> createState() =>
      _VentilationCalculatorPageState();
}

class _VentilationCalculatorPageState
    extends State<VentilationCalculatorPage> {
  ApplianceType _applianceType = ApplianceType.openFluedBoiler;
  bool _inCompartment = false;
  bool _roomDirectToOutside = true;

  final TextEditingController _heatInputController =
  TextEditingController(); // kW (net)
  final TextEditingController _roomVolumeController =
  TextEditingController(); // m³ (only for info / flueless notes)

  VentilationResult? _result;

  @override
  void dispose() {
    _heatInputController.dispose();
    _roomVolumeController.dispose();
    super.dispose();
  }

  double _toDouble(String text) {
    return double.tryParse(text.replaceAll(',', '.')) ?? 0.0;
  }

  void _calculate() {
    final kW = _toDouble(_heatInputController.text);
    final volume = _toDouble(_roomVolumeController.text);

    if (kW <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid heat input in kW')),
      );
      return;
    }

    final calc = VentCalculator(
      applianceType: _applianceType,
      inCompartment: _inCompartment,
      roomDirectToOutside: _roomDirectToOutside,
      heatInputkW: kW,
      roomVolumeM3: volume,
    );

    setState(() {
      _result = calc.calculate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightBg,
      appBar: AppBar(
        backgroundColor: kTeal,
        title: const Text('Ventilation Calculator'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _infoCard(),

          const SizedBox(height: 12),

          _card(
            'Appliance details',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<ApplianceType>(
                  value: _applianceType,
                  decoration: const InputDecoration(
                    labelText: 'Appliance type',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: ApplianceType.values
                      .map(
                        (t) => DropdownMenuItem(
                      value: t,
                      child: Text(t.label),
                    ),
                  )
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _applianceType = v ?? _applianceType;
                    });
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _heatInputController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Heat input (kW net)',
                    hintText: 'e.g. 24',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _roomVolumeController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Room volume (m³) – optional',
                    hintText: 'Used mainly for flueless info',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          _card(
            'Location & installation',
            Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Appliance in a compartment/cupboard'),
                  value: _inCompartment,
                  onChanged: (v) {
                    setState(() {
                      _inCompartment = v;
                    });
                  },
                ),
                if (!_inCompartment)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Room has permanent opening direct to outside',
                    ),
                    subtitle: const Text(
                      'For open-flued in a room, calculator assumes vent direct to outside air.',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: _roomDirectToOutside,
                    onChanged: (v) {
                      setState(() {
                        _roomDirectToOutside = v;
                      });
                    },
                  ),
                if (_inCompartment)
                  const Text(
                    'For compartments, calculations here are for vents from compartment to outside, '
                        'based on typical guidance for domestic open-flued appliances.\n\n'
                        'Always confirm with BS 5440-2 and manufacturer’s instructions.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: kTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const Icon(Icons.calculate_outlined),
              label: const Text(
                'Calculate ventilation',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onPressed: _calculate,
            ),
          ),

          const SizedBox(height: 12),

          if (_result != null) _buildResultCard(_result!),
        ],
      ),
    );
  }

  Widget _infoCard() {
    return _card(
      'Important',
      const Text(
        'This tool is for qualified gas engineers as a quick aid only.\n\n'
            'It uses simplified guidance based on open-flued domestic appliances and '
            'typical ventilation rules from BS 5440-2 / Gas Safe pocket guides.\n\n'
            'Always:\n'
            '• Follow current BS 5440-2 and Approved Document J\n'
            '• Follow manufacturer’s installation instructions\n'
            '• Use Gas Safe technical bulletins / calculators where required\n'
            '• Treat this tool as an approximate guide, not a final design.',
        style: TextStyle(fontSize: 12, color: Colors.black87),
      ),
    );
  }

  Widget _card(String title, Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildResultCard(VentilationResult result) {
    return _card(
      'Ventilation result (guide)',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (result.roomVentCm2 != null)
            _resultRow(
              'Permanent vent to outside (room)',
              '${result.roomVentCm2!.toStringAsFixed(0)} cm² free area',
            ),
          if (result.compartmentHighCm2 != null)
            _resultRow(
              'Compartment HIGH-level vent to outside',
              '${result.compartmentHighCm2!.toStringAsFixed(0)} cm² free area',
            ),
          if (result.compartmentLowCm2 != null)
            _resultRow(
              'Compartment LOW-level vent to outside',
              '${result.compartmentLowCm2!.toStringAsFixed(0)} cm² free area',
            ),
          if (result.roomVentCm2 == null &&
              result.compartmentHighCm2 == null &&
              result.compartmentLowCm2 == null)
            const Text(
              'No specific vent area calculated for this appliance type.\n'
                  'Refer directly to BS 5440-2 and manufacturer’s instructions.',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          const SizedBox(height: 8),
          Text(
            result.notes,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: kTeal,
            ),
          ),
        ],
      ),
    );
  }
}

/// TYPES & CALC LOGIC

enum ApplianceType {
  openFluedBoiler,
  openFluedOther,
  decorativeFuelEffect,
  insetLiveFuelEffect,
  roomSealedBoiler,
  fluelessHeater,
  cooker,
  other,
}

extension ApplianceTypeExt on ApplianceType {
  String get label {
    switch (this) {
      case ApplianceType.openFluedBoiler:
        return 'Open-flued boiler (domestic, <70kW net)';
      case ApplianceType.openFluedOther:
        return 'Open-flued appliance (general)';
      case ApplianceType.decorativeFuelEffect:
        return 'Decorative fuel effect (DFE) gas fire';
      case ApplianceType.insetLiveFuelEffect:
        return 'Inset live fuel effect (ILFE) gas fire';
      case ApplianceType.roomSealedBoiler:
        return 'Room-sealed boiler';
      case ApplianceType.fluelessHeater:
        return 'Flueless space / water heater';
      case ApplianceType.cooker:
        return 'Cooker (domestic)';
      case ApplianceType.other:
        return 'Other / not listed';
    }
  }
}

class VentilationResult {
  final double? roomVentCm2;
  final double? compartmentHighCm2;
  final double? compartmentLowCm2;
  final String notes;

  VentilationResult({
    this.roomVentCm2,
    this.compartmentHighCm2,
    this.compartmentLowCm2,
    required this.notes,
  });
}

/// Calculator based on simplified open-flued and gas fire rules.
/// This DOES NOT fully implement BS 5440-2 or all Gas Safe bulletins.
/// It is an approximate guide only.
class VentCalculator {
  final ApplianceType applianceType;
  final bool inCompartment;
  final bool roomDirectToOutside;
  final double heatInputkW; // net
  final double roomVolumeM3;

  VentCalculator({
    required this.applianceType,
    required this.inCompartment,
    required this.roomDirectToOutside,
    required this.heatInputkW,
    required this.roomVolumeM3,
  });

  VentilationResult calculate() {
    switch (applianceType) {
      case ApplianceType.openFluedBoiler:
      case ApplianceType.openFluedOther:
        return _calcOpenFlued();
      case ApplianceType.decorativeFuelEffect:
        return _calcDfe();
      case ApplianceType.insetLiveFuelEffect:
        return _calcIlfe();
      case ApplianceType.roomSealedBoiler:
        return _roomSealed();
      case ApplianceType.fluelessHeater:
        return _flueless();
      case ApplianceType.cooker:
        return _cooker();
      case ApplianceType.other:
        return VentilationResult(
          notes:
          'Appliance not specifically covered by this tool.\n'
              'Refer to BS 5440-2, Approved Document J and manufacturer’s instructions.',
        );
    }
  }

  /// Open-flued appliance (general domestic, <70kW net)
  /// Room direct to outside:
  ///  - Adventitious allowance = 35 cm² (≈ first 7kW)
  ///  - Vent = 5 cm² for every kW in excess of 7 kW
  ///
  /// Compartment (to outside):
  ///  - Typical guidance: high-level 500 mm²/kW, low-level 1000 mm²/kW
  ///    => 5 cm²/kW high, 10 cm²/kW low
  VentilationResult _calcOpenFlued() {
    if (inCompartment) {
      final high = heatInputkW * 5.0;
      final low = heatInputkW * 10.0;
      return VentilationResult(
        roomVentCm2: null,
        compartmentHighCm2: high,
        compartmentLowCm2: low,
        notes:
        'Open-flued appliance in compartment.\n'
            'Approx. guide: HIGH-level vent ≈ 5 cm² per kW, '
            'LOW-level ≈ 10 cm² per kW direct to outside.\n'
            'Confirm against BS 5440-2 and appliance MI, '
            'and consider airtightness / adventitious ventilation.',
      );
    }

    if (!roomDirectToOutside) {
      return VentilationResult(
        notes:
        'Open-flued appliance in room without direct vent to outside.\n'
            'This calculator assumes vents direct to outside – '
            'refer to BS 5440-2 / Gas Safe guidance for internal rooms.',
      );
    }

    // Room directly ventilated to outside – single appliance
    final excessKw = heatInputkW - 7.0;
    final vent =
    excessKw > 0 ? excessKw * 5.0 : 0.0; // 5 cm² for every kW > 7kW

    return VentilationResult(
      roomVentCm2: vent > 0 ? vent : 0,
      notes:
      'Open-flued appliance in a room.\n'
          'Allowance for adventitious air ≈ 35 cm² (≈ first 7kW).\n'
          'Ventilation guide: 5 cm² per kW in excess of 7kW of net heat input.\n'
          'For multi-appliance rooms, very airtight dwellings or '
          'where adventitious air is doubtful, additional ventilation may be required.\n'
          'Always confirm with BS 5440-2, Technical Bulletins and MI.',
    );
  }

  /// DFE gas fire:
  /// Pocket guide: up to 20kW – min 100 cm² or as MI
  VentilationResult _calcDfe() {
    if (inCompartment) {
      return VentilationResult(
        notes:
        'Decorative fuel effect (DFE) appliances in compartments are not '
            'calculated by this tool.\n'
            'Refer to BS 5871-3, BS 5440-2 and manufacturer’s instructions.',
      );
    }

    return VentilationResult(
      roomVentCm2: 100.0,
      notes:
      'Decorative fuel effect (DFE) gas fire.\n'
          'Typical guidance: minimum 100 cm² of permanent ventilation to outside '
          'for up to 20kW net, or as specified by manufacturer.\n'
          'Always follow the specific appliance instructions.',
    );
  }

  /// ILFE gas fire:
  /// Up to 15kW, often 5 cm² per kW in excess of 7kW (similar to open-flued).
  VentilationResult _calcIlfe() {
    if (inCompartment) {
      return VentilationResult(
        notes:
        'Inset live fuel effect (ILFE) gas fires in compartments are not '
            'specifically calculated here.\n'
            'Refer to BS 5871-2/3, BS 5440-2 and MI.',
      );
    }

    final excessKw = heatInputkW - 7.0;
    final vent = excessKw > 0 ? excessKw * 5.0 : 0.0;

    return VentilationResult(
      roomVentCm2: vent > 0 ? vent : 0,
      notes:
      'Inset live fuel effect (ILFE) gas fire.\n'
          'Guide: approx. 5 cm² per kW above 7kW (net), '
          'subject to manufacturer’s instructions.\n'
          'Confirm against BS 5871 / BS 5440-2.',
    );
  }

  /// Room-sealed boiler:
  /// Generally no additional combustion air ventilation to room,
  /// but compartments may need vents for cooling as per MI.
  VentilationResult _roomSealed() {
    if (inCompartment) {
      return VentilationResult(
        notes:
        'Room-sealed boiler in a compartment.\n'
            'Combustion air is ducted, so vent requirements are usually '
            'for heat dissipation / case cooling.\n'
            'These are manufacturer-specific – check boiler instructions and BS 5440-2.\n'
            'This tool does not provide a numeric value for room-sealed compartments.',
      );
    }

    return VentilationResult(
      roomVentCm2: 0,
      notes:
      'Room-sealed boiler in a room.\n'
          'Normally no permanent ventilation is required for combustion air, '
          'unless specified by the manufacturer.\n'
          'Check appliance instructions and building regulations.',
    );
  }

  /// Flueless appliances – requirements depend heavily on room volume
  /// and specific appliance type. This tool gives guidance text only.
  VentilationResult _flueless() {
    return VentilationResult(
      notes:
      'Flueless appliance (space heater, water heater, cooker etc.).\n'
          'Ventilation depends on room volume, appliance type and kW input.\n'
          'For example, some flueless heaters may require 100 cm² for '
          'certain room sizes, and additional rapid ventilation.\n\n'
          'This tool does NOT attempt to calculate flueless ventilation.\n'
          'Refer directly to BS 5440-2, the relevant BS for the appliance '
          'and manufacturer’s instructions.\n'
          'Room volume entered: ${roomVolumeM3.toStringAsFixed(1)} m³ (for your reference).',
    );
  }

  /// Domestic cooker – generally no additional permanent vent
  /// in normal-sized rooms with openable window, but check ADJ & MI.
  VentilationResult _cooker() {
    return VentilationResult(
      notes:
      'Domestic cooker.\n'
          'In many situations no additional permanent ventilation is required '
          'if the room has sufficient volume and an openable window, but this '
          'depends on appliance type and current guidance.\n'
          'For flueless cookers or small rooms, permanent ventilation may be required.\n'
          'Refer to BS 5440-2, Approved Document J and manufacturer’s instructions.',
    );
  }
}
