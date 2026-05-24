import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StockChart extends StatelessWidget {
  final List data;

  const StockChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];

    for (int i = 0; i < data.length; i++) {
      final value = (data[i]["value"] ?? 0).toDouble();
      spots.add(FlSpot(i.toDouble(), value));
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
