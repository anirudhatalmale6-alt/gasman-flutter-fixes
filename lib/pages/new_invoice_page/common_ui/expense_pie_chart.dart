import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:the_gas_man_app/theme/app_theme.dart';

class ExpensePieChart extends StatelessWidget {
  final Map<String, double> data;

  const ExpensePieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Text('No expenses for this period');
    }

    final total = data.values.fold(0.0, (s, v) => s + v);
    final colors = [
      AppColors.kTeal,
      AppColors.kAmber,
      AppColors.kDark,
      Colors.blueGrey,
      Colors.indigo,
      Colors.pink,
    ];

    final entries = data.entries.toList();

    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sections: List.generate(entries.length, (i) {
            final e = entries[i];
            final value = e.value;
            return PieChartSectionData(
              color: colors[i % colors.length],
              value: value,
              radius: 70,
              title:
              '${e.key}\n${(value / total * 100).toStringAsFixed(0)}%',
              titleStyle: const TextStyle(
                  fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            );
          }),
        ),
      ),
    );
  }
}
