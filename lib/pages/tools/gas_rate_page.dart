import 'dart:async';
import 'package:flutter/material.dart';
import '../../utils_class/gas_rate.dart';

class GasRatePage extends StatefulWidget {
  static const route = '/gas-rate';

  const GasRatePage({super.key});

  @override
  State<GasRatePage> createState() => _GasRatePageState();
}

class _GasRatePageState extends State<GasRatePage> {
  MeterType meter = MeterType.imperial;
  FuelType fuel = FuelType.naturalGas;

  // Metric inputs
  final mStart = TextEditingController();
  final mEnd = TextEditingController();
  int metricSeconds = 120;

  // Imperial inputs
  double dialFt3 = 1;
  final dialSecondsCtrl = TextEditingController();

  // Timer
  Timer? _timer;
  double elapsed = 0;

  GasRateResult? result;

  void start() {
    _timer?.cancel();
    setState(() => elapsed = 0);
    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      setState(() => elapsed += .1);
    });
  }

  void stop() => _timer?.cancel();

  void reset() {
    _timer?.cancel();
    setState(() => elapsed = 0);
  }

  void calculate() {
    try {
      if (meter == MeterType.metric) {
        final r = GasRate.fromMetric(
          startM3: double.parse(mStart.text),
          endM3: double.parse(mEnd.text),
          seconds: elapsed > 0 ? elapsed : metricSeconds.toDouble(),
          fuel: fuel,
        );
        setState(() => result = r);
      } else {
        final seconds = double.parse(dialSecondsCtrl.text);
        final r = GasRate.fromImperial(
          testDialFt3: dialFt3,
          secondsPerRev: seconds,
          fuel: fuel,
        );
        setState(() => result = r);
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please complete valid inputs')));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    mStart.dispose();
    mEnd.dispose();
    dialSecondsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget timer() => Column(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(elapsed.toStringAsFixed(1).padLeft(5, '0'),
                style:
                    const TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            FilledButton(onPressed: start, child: const Text('Start')),
            const SizedBox(width: 8),
            FilledButton.tonal(onPressed: stop, child: const Text('Stop')),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: reset, child: const Text('Reset')),
          ])
        ]);

    return Scaffold(
      appBar: AppBar(title: const Text('Gas Rate Calculator')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<MeterType>(
            segments: const [
              ButtonSegment(value: MeterType.imperial, label: Text('Imperial')),
              ButtonSegment(value: MeterType.metric, label: Text('Metric')),
            ],
            selected: {meter},
            onSelectionChanged: (s) => setState(() => meter = s.first),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<FuelType>(
            value: fuel,
            items: const [
              DropdownMenuItem(
                  value: FuelType.naturalGas, child: Text('Natural Gas')),
              DropdownMenuItem(value: FuelType.lpg, child: Text('LPG')),
            ],
            onChanged: (v) => setState(() => fuel = v ?? FuelType.naturalGas),
            decoration: const InputDecoration(labelText: 'Fuel Type'),
          ),
          const SizedBox(height: 12),
          timer(),
          const SizedBox(height: 16),
          if (meter == MeterType.metric) ...[
            TextFormField(
                controller: mStart,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Meter reading at Start (m³)')),
            const SizedBox(height: 10),
            TextFormField(
                controller: mEnd,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Meter reading at End (m³)')),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: '$metricSeconds',
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Timer value if not using stopwatch (s)'),
              onChanged: (v) {
                final s = int.tryParse(v);
                if (s != null) metricSeconds = s;
              },
            ),
          ] else ...[
            DropdownButtonFormField<double>(
              value: dialFt3,
              items: const [1, 2, 5, 10]
                  .map((e) => DropdownMenuItem(
                      value: e.toDouble(), child: Text('$e ft³')))
                  .toList(),
              onChanged: (v) => setState(() => dialFt3 = v ?? 1),
              decoration: const InputDecoration(labelText: 'Test Dial Size'),
            ),
            const SizedBox(height: 10),
            TextFormField(
                controller: dialSecondsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Time for one revolution of test dial (s)')),
          ],
          const SizedBox(height: 16),
          Row(children: [
            ElevatedButton(
                onPressed: calculate, child: const Text('Calculate')),
            const SizedBox(width: 8),
            OutlinedButton(
                onPressed: () => setState(() => result = null),
                child: const Text('Reset')),
          ]),
          const SizedBox(height: 20),
          if (result != null)
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Appliance Heat Input',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _kv('Gross (kW)', result!.grossKw),
                      _kv('Gross (m³/hr)', result!.grossM3h),
                      const Divider(height: 24),
                      _kv('Net (kW)', result!.netKw),
                      _kv('Net (m³/hr)', result!.netM3h),
                    ]),
              ),
            ),
          const SizedBox(height: 14),
          _instructions(context),
        ],
      ),
    );
  }

  Widget _kv(String k, double v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(k),
          Text(v.toStringAsFixed(2)),
        ]),
      );

  Widget _instructions(BuildContext c) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(c).colorScheme.secondary.withOpacity(.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          meter == MeterType.metric
              ? 'Instructions:\n'
                  '1) Turn off other gas appliances.\n'
                  '2) Warm appliance ~10 minutes.\n'
                  '3) Record meter start value; run timer.\n'
                  '4) After 2 minutes stop and record end value.\n'
                  '5) The calculated heat input is shown above.'
              : 'Instructions:\n'
                  '1) Turn off other gas appliances.\n'
                  '2) Warm appliance ~10 minutes.\n'
                  '3) Record start position of dial.\n'
                  '4) Record time for one full resolution.\n'
                  '5) The calculated heat input is shown above.',
        ),
      );
}
