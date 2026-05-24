import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/storage_service.dart';

class ReportChartsPage extends StatefulWidget {
  const ReportChartsPage({super.key});
  @override
  State<ReportChartsPage> createState() => _ReportChartsPageState();
}

class _ReportChartsPageState extends State<ReportChartsPage> {
  Map<int, double> incomeByMonth = {};
  Map<int, double> expenseByMonth = {};

  @override
  void initState(){
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final inc = await StorageService.read('income');
    final inList = (inc['list']??[]) as List;
    final exp = await StorageService.read('expenses');
    final exList = (exp['list']??[]) as List;
    incomeByMonth = { for (var m=1;m<=12;m++) m: 0.0 };
    expenseByMonth = { for (var m=1;m<=12;m++) m: 0.0 };
    for (final e in inList) {
      try { final d = DateTime.tryParse(e['date']??''); if (d!=null) incomeByMonth[d.month] = (incomeByMonth[d.month]??0) + ((e['total']??0) as num).toDouble(); } catch(_){}
    }
    for (final e in exList) {
      try { final d = DateTime.tryParse(e['date']??''); if (d!=null) expenseByMonth[d.month] = (expenseByMonth[d.month]??0) + (((e['net']??0) as num).toDouble() + ((e['vat']??0) as num).toDouble()); } catch(_){}
    }
    setState((){});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Income & Expenses — Monthly')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _card('Income (Gross)', incomeByMonth, Theme.of(context).colorScheme.primary),
        const SizedBox(height: 12),
        _card('Expenses (Gross)', expenseByMonth, Colors.amber),
      ]),
    );
  }

  Widget _card(String title, Map<int,double> data, Color c){
    final bars = data.entries.map((e)=> BarChartRodData(toY: e.value, width: 10)).toList();
    return Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      SizedBox(height: 220, child: BarChart(BarChartData(
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 42)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta){
            final m = v.toInt();
            const labels = ['','J','F','M','A','M','J','J','A','S','O','N','D'];
            return Text(m>=1 && m<=12 ? labels[m] : '');
          })),
        ),
        barGroups: List.generate(12, (i)=> BarChartGroupData(x: i+1, barRods: [BarChartRodData(toY: data[i+1]??0)])),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ))),
    ])));
  }
}
