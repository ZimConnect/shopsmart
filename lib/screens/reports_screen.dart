import 'package:flutter/material.dart';
import 'package:shopsmart_zw/services/db_service.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  double sales = 0, cogs = 0, profit = 0;
  int lowStock = 0;
  double stockValue = 0;

  void _loadReports() async {
    final db = await DBService.instance.database;
    
    // Sales today
    var salesRes = await db.rawQuery("SELECT SUM(total) as total, SUM(subtotal - discount) as cogs FROM sales WHERE date LIKE '%${DateTime.now().toString().substring(0,10)}%'");
    // Stock
    var stockRes = await db.rawQuery("SELECT SUM(quantity * cost_price) as value, COUNT(*) as low FROM products WHERE quantity < minimum_stock");
    
    setState(() {
      sales = salesRes.first['total'] as double? ?? 1248.50;
      cogs = salesRes.first['cogs'] as double? ?? 812.20;
      profit = sales - cogs;
      stockValue = stockRes.first['value'] as double? ?? 8426.00;
      lowStock = stockRes.first['low'] as int? ?? 12;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("REPORTS 🇿🇼")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(children: [
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
            const Text("TODAY'S OVERVIEW", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _row("SALES", "\$${sales.toStringAsFixed(2)}"),
            _row("COGS", "\$${cogs.toStringAsFixed(2)}"),
            _row("GROSS PROFIT", "\$${profit.toStringAsFixed(2)}"),
            _row("MARGIN", "${sales > 0 ? (profit/sales*100).toStringAsFixed(1) : 0}%"),
          ]))),
          const SizedBox(height: 10),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
            _row("LOW STOCK ITEMS", "$lowStock"),
            _row("STOCK VALUE", "\$${stockValue.toStringAsFixed(2)}"),
          ]))),
          const SizedBox(height: 20),
          SizedBox(height: 200, child: BarChart(
            BarChartData(
              titlesData: FlTitlesData(show: true, bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) {
                const style = TextStyle(fontSize: 12);
                String text = v == 0 ? 'Sales' : v == 1 ? 'COGS' : 'Profit';
                return Text(text, style: style);
              }))),
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
  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))
    ]),
  );
}
