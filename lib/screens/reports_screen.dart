import 'package:flutter/material.dart';
import 'package:shopsmart_zw/services/db_service.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  double sales = 1248.50;
  double cogs = 812.20;
  double profit = 436.30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("REPORTS")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Card(child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [
              const Text("TODAY'S SALES", style: TextStyle(fontSize: 18)),
              Text("\$${sales.toStringAsFixed(2)}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text("COGS: \$${cogs.toStringAsFixed(2)}"),
                Text("PROFIT: \$${profit.toStringAsFixed(2)}"),
                Text("MARGIN: ${(profit/sales*100).toStringAsFixed(1)}%"),
              ])
            ]),
          )),
          const SizedBox(height: 20),
          Expanded(child: BarChart(
            BarChartData(
              titlesData: FlTitlesData(show: true),
              borderData: FlBorderData(show: false),
              barGroups: [
                BarChartGroupData(x: 0, barRods: [BarRodData(toY: sales, color: Colors.green)]),
                BarChartGroupData(x: 1, barRods: [BarRodData(toY: cogs, color: Colors.red)]),
                BarChartGroupData(x: 2, barRods: [BarRodData(toY: profit, color: Colors.blue)]),
              ]
            )
          ))
        ]),
      ),
    );
  }
}
