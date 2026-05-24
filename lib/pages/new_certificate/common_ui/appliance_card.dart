import 'package:flutter/material.dart';
import 'package:the_gas_man_app/pages/new_certificate/common_ui/switch_row.dart';
import 'package:the_gas_man_app/pages/new_certificate/common_ui/text_field_row.dart';

import '../common_models/gas_appliance_entry.dart';

class ApplianceCard extends StatelessWidget {
  final int index;
  final GasApplianceEntry appliance;
  final VoidCallback onDelete;

  const ApplianceCard({
    required this.index,
    required this.appliance,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Appliance ${index + 1}'),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            TextFieldRow(
              label: 'Type (boiler, hob, fire...)',
              initialValue: appliance.applianceType,
              onChanged: (v) => appliance.applianceType = v,
            ),
            TextFieldRow(
              label: 'Make',
              initialValue: appliance.make,
              onChanged: (v) => appliance.make = v,
            ),
            TextFieldRow(
              label: 'Model',
              initialValue: appliance.model,
              onChanged: (v) => appliance.model = v,
            ),
            TextFieldRow(
              label: 'Location',
              initialValue: appliance.location,
              onChanged: (v) => appliance.location = v,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFieldRow(
                    label: 'Operating / standing pressure',
                    initialValue: appliance.operatingPressure,
                    onChanged: (v) => appliance.operatingPressure = v,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFieldRow(
                    label: 'Heat input',
                    initialValue: appliance.heatInput,
                    onChanged: (v) => appliance.heatInput = v,
                  ),
                ),
              ],
            ),
            SwitchRow(
              label: 'Ventilation adequate',
              value: appliance.ventilationOk,
              onChanged: (v) => appliance.ventilationOk = v,
            ),
            SwitchRow(
              label: 'Flue / chimney satisfactory',
              value: appliance.flueChimneyOk,
              onChanged: (v) => appliance.flueChimneyOk = v,
            ),
            SwitchRow(
              label: 'Safety devices operating correctly',
              value: appliance.safetyDevicesOk,
              onChanged: (v) => appliance.safetyDevicesOk = v,
            ),
            SwitchRow(
              label: 'Combustion readings satisfactory',
              value: appliance.combustionOk,
              onChanged: (v) => appliance.combustionOk = v,
            ),
            SwitchRow(
              label: 'Appliance safe to use',
              value: appliance.applianceSafeToUse,
              onChanged: (v) => appliance.applianceSafeToUse = v,
            ),
          ],
        ),
      ),
    );
  }
}
