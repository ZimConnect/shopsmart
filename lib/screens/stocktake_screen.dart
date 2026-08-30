import 'package:flutter/material.dart';
import 'package:shopsmart_zw/services/db_service.dart';
import 'package:intl/intl.dart';

class StockTakeScreen extends StatefulWidget {
  const StockTakeScreen({super.key});
  @override
  State<StockTakeScreen> createState() => _StockTakeScreenState();
}

class _StockTakeScreenState extends State<StockTakeScreen> {
  List<Map> products = [];
  Map<int, int> counted = {};

  void _loadProducts() async {
    final db = await DBService.instance.database;
    final data = await db.query('products');
    setState(() => products = data);
  }

  void _approveAdjustments() async {
    final db = await DBService.instance.database;
    final now = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    for (var p in products) {
      int countedQty = counted[p['id']]?? p['quantity'];
      int diff = countedQty - p['quantity'];
      if (diff!= 0) {
        await db.update('products', {'quantity': countedQty}, where: 'id =?', whereArgs: [p['id']]);
        await db.insert('stock_movements', {
          'product_id': p['id'], 'type': 'ADJUSTMENT', 'quantity': diff,
          'reason': 'Stock Take', 'user': 'Admin', 'date': now
        });
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Stock Adjusted")));
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("STOCK TAKE")),
      floatingActionButton: FloatingActionButton(onPressed: _approveAdjustments, child: const Icon(Icons.check)),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(columns: const [
          DataColumn(label: Text("PRODUCT")),
          DataColumn(label: Text("EXPECTED")),
          DataColumn(label: Text("COUNTED")),
          DataColumn(label: Text("DIFFERENCE")),
        ], rows: products.map((p) => DataRow(cells: [
          DataCell(Text(p['name'])),
          DataCell(Text(p['quantity'].toString())),
          DataCell(SizedBox(width: 80, child: TextField(
            keyboardType: TextInputType.number,
            onChanged: (v) => counted[p['id']] = int.tryParse(v)?? 0,
            decoration: InputDecoration(hintText: p['quantity'].toString())
          ))),
          DataCell(Text(((counted[p['id']]?? p['quantity']) - p['quantity']).toString())),
        ])).toList()),
      ),
    );
  }
}
