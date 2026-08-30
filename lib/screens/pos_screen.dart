import 'package:flutter/material.dart';
import 'package:shopsmart_zw/services/db_service.dart';
import 'package:shopsmart_zw/services/receipt_service.dart';
import 'package:intl/intl.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});
  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> cart = [];
  String paymentMethod = "CASH";
  final amountController = TextEditingController();
  final receiptService = ReceiptService();

  void _loadProducts() async {
    final db = await DBService.instance.database;
    final data = await db.query('products');
    setState(() => products = data);
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      var existing = cart.indexWhere((item) => item['id'] == product['id']);
      if (existing >= 0) {
        cart[existing]['qty'] += 1;
      } else {
        cart.add({...product, 'qty': 1});
      }
    });
  }

  double get subtotal => cart.fold(0, (sum, item) => sum + (item['qty'] * item['selling_price']));
  double get vat => subtotal * 0.155; // 15.5% Zim VAT
  double get total => subtotal + vat;

  Future<void> _checkout() async {
    if (cart.isEmpty) return;
    final db = await DBService.instance.database;
    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final receiptNum = "SS${DateFormat('yyMMddHHmmss').format(DateTime.now())}";
    double tendered = double.tryParse(amountController.text)?? total;
    double change = tendered - total;

    // 1. Save Sale
    int saleId = await db.insert('sales', {
      'receipt_number': receiptNum,
      'cashier': 'Admin',
      'subtotal': subtotal,
      'discount': 0,
      'vat': vat,
      'total': total,
      'payment_method': paymentMethod,
      'amount_tendered': tendered,
      'change': change,
      'date': now,
    });

    // 2. Save Sale Items + Deduct Stock
    for (var item in cart) {
      await db.insert('sale_items', {
        'sale_id': saleId,
        'product_id': item['id'],
        'quantity': item['qty'],
        'selling_price': item['selling_price'],
        'cost_price': item['cost_price'],
        'subtotal': item['qty'] * item['selling_price'],
      });

      // Deduct stock
      int newQty = item['quantity'] - item['qty'];
      await db.update('products', {'quantity': newQty}, where: 'id =?', whereArgs: [item['id']]);

      // Log stock movement
      await db.insert('stock_movements', {
        'product_id': item['id'], 'type': 'SALE', 'quantity': -item['qty'],
        'reason': 'Sale $receiptNum', 'user': 'Admin', 'date': now
      });
    }

    // 3. Print Receipt
    await receiptService.printReceipt({
      'receipt_number': receiptNum,
      'cashier': 'Admin',
      'items': cart,
      'subtotal': subtotal,
      'vat': vat,
      'total': total,
      'payment_method': paymentMethod,
      'amount_tendered': tendered,
      'change': change,
    });

    setState(() => cart.clear());
    amountController.clear();
    _loadProducts();
    if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sale $receiptNum Complete")));
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('POS - SALE')),
      body: Row(
        children: [
          // Left: Products
          Expanded(
            flex: 3,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
              itemCount: products.length,
              itemBuilder: (_, i) {
                final p = products[i];
                return Card(child: InkWell(
                  onTap: () => _addToCart(p),
                  child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(p['name'], textAlign: TextAlign.center),
                    Text("\$${p['selling_price']}", style: const TextStyle(fontWeight: FontWeight.bold))
                  ])),
                ));
              },
            ),
          ),
          // Right: Cart
          Expanded(
            flex: 2,
            child: Column(children: [
              const Text('CURRENT SALE', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Expanded(child: ListView(
                children: cart.map((item) => ListTile(
                  title: Text(item['name']),
                  subtitle: Text("${item['qty']} x \$${item['selling_price']}"),
                  trailing: Text("\$${(item['qty'] * item['selling_price']).toStringAsFixed(2)}"),
                )).toList(),
              )),
              Text('SUBTOTAL: \$${subtotal.toStringAsFixed(2)}'),
              Text('VAT 15.5%: \$${vat.toStringAsFixed(2)}'),
              Text('TOTAL: \$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              TextField(controller: amountController, decoration: const InputDecoration(labelText: "Amount Tendered \$"), keyboardType: TextInputType.number),
              Row(children: [
                _payBtn("CASH"),
                _payBtn("ECOCASH"),
                _payBtn("CARD"),
              ]),
              ElevatedButton(onPressed: _checkout, child: const Text("COMPLETE SALE & PRINT"))
            ]),
          )
        ],
      ),
    );
  }

  Widget _payBtn(String method) => Expanded(child: ElevatedButton(
    style: ElevatedButton.styleFrom(backgroundColor: paymentMethod == method? Colors.green : null),
    onPressed: () => setState(() => paymentMethod = method),
    child: Text(method)
  ));
}
