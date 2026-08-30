import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shopsmart_zw/services/db_service.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Map> products = [];

  void _loadProducts() async {
    final db = await DBService.instance.database;
    final data = await db.query('products');
    setState(() => products = data);
  }

  void _addProduct() {
    final name = TextEditingController();
    final cost = TextEditingController();
    final price = TextEditingController();
    final qty = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text("Add Product"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: "Name")),
        TextField(controller: cost, decoration: const InputDecoration(labelText: "Cost Price \$"), keyboardType: TextInputType.number),
        TextField(controller: price, decoration: const InputDecoration(labelText: "Selling Price \$"), keyboardType: TextInputType.number),
        TextField(controller: qty, decoration: const InputDecoration(labelText: "Quantity"), keyboardType: TextInputType.number),
      ]),
      actions: [
        TextButton(onPressed: () async {
          final db = await DBService.instance.database;
          await db.insert('products', {
            'name': name.text,
            'cost_price': double.parse(cost.text),
            'selling_price': double.parse(price.text),
            'quantity': int.parse(qty.text)
          });
          Navigator.pop(context);
          _loadProducts();
        }, child: const Text("Save"))
      ],
    ));
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("INVENTORY")),
      floatingActionButton: FloatingActionButton(onPressed: _addProduct, child: const Icon(Icons.add)),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (_, i) {
          final p = products[i];
          bool lowStock = p['quantity'] < (p['minimum_stock']?? 5);
          return ListTile(
            title: Text(p['name']),
            subtitle: Text("Qty: ${p['quantity']} | Cost: \$${p['cost_price']} | Price: \$${p['selling_price']}"),
            trailing: lowStock? const Icon(Icons.warning, color: Colors.red) : null,
          );
        },
      ),
    );
  }
}
