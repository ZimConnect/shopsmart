import 'package:flutter/material.dart';
import 'package:shopsmart_zw/services/db_service.dart';
import 'package:intl/intl.dart';

class StockTakeScreen extends StatefulWidget {
  const StockTakeScreen({super.key});
  @override
  State<StockTakeScreen> createState() => _StockTakeScreenState();
}

class _StockTakeScreenState extends State<StockTakeScreen> {
  List<Map<String, dynamic>> products = [];
  Map<int, TextEditingController> controllers = {};

  void _loadProducts() async {
    final db = await DBService.instance.database;
    final data = await db.query('products');
    setState(() {
      products = data;
      for(var p in products){
        controllers[p['id']] = TextEditingController(text: p['quantity'].toString());
      }
    });
  }

  void _approveAdjustments() async {
    final db = await DBService.instance.database;
    final now = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    for (var p in products) {
      int countedQty = int.tryParse(controllers[p['id']]!.text) ?? p['quantity'];
      int diff = countedQty - p['quantity'];
      if (diff != 0) {
        await db.update('products', {'quantity': countedQty}, where: 'id =?', whereArgs: [p['id']]);
        await db.insert('stock_movements', {
          'product_id': p['id'], 'type': 'ADJUSTMENT', 'quantity': diff,
          'reason': 'Stock Take', 'user': 'Admin', 'date': now
        });
      }
    }
    if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Stock Adjusted & Saved")));
    _loadProducts();
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _approveAdjustments, 
        label: const Text("APPROVE"),
        icon: const Icon(Icons.check)
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(columns: const [
          DataColumn(label: Text("PRODUCT")),
          DataColumn(label: Text("EXPECTED")),
          DataColumn(label: Text("COUNTED")),
          DataColumn(label: Text("DIFF")),
        ], rows: products.map((p) {
          int counted = int.tryParse(controllers[p['id']]!.text) ?? p['quantity'];
          int diff = counted - p['quantity'];
          return DataRow(cells: [
            DataCell(Text(p['name'])),
            DataCell(Text(p['quantity'].toString())),
            DataCell(SizedBox(width: 80, child: TextField(controller: controllers[p['id']], keyboardType: TextInputType.number))),
            DataCell(Text(diff.toString(), style: TextStyle(color: diff != 0 ? Colors.red : Colors.green))),
          ]);
        }).toList()),
      ),
    );
  }
}
