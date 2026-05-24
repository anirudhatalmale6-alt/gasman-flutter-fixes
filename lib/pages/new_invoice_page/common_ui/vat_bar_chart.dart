import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:the_gas_man_app/theme/app_theme.dart';

class VatBarChart extends StatelessWidget {
  final double vatSales;
  final double vatPurchases;

  const VatBarChart({
    super.key,
    required this.vatSales,
    required this.vatPurchases,
  });

  @override
  Widget build(BuildContext context) {
    final maxY =
        (vatSales.abs() > vatPurchases.abs() ? vatSales.abs() : vatPurchases.abs()) * 1.2;

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: maxY <= 0 ? 100 : maxY,
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: vatSales,
                  color: AppColors.kChartVatSales,
                  width: 20,
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: vatPurchases,
                  color: AppColors.kChartVatPurchases,
                  width: 20,
                ),
              ],
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  if (v == 0) return const Text('Sales VAT');
                  if (v == 1) return const Text('Purchases VAT');
                  return const SizedBox();
                },
              ),
            ),
          ),
          gridData: FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
