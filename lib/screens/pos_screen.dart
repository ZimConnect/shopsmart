import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // NEW
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
  bool _showScanner = false;

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

  void _scanBarcode() async {
    setState(() => _showScanner = true);
  }

  void _onBarcodeDetected(BarcodeCapture capture) async {
    final db = await DBService.instance.database;
    final barcode = capture.barcodes.first.rawValue;
    if (barcode == null) return;

    final res = await db.query('products', where: 'barcode =?', whereArgs: [barcode]);
    if (res.isNotEmpty) {
      _addToCart(res.first);
      setState(() => _showScanner = false);
    } else {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Product not found")));
    }
  }

  double get subtotal => cart.fold(0, (sum, item) => sum + (item['qty'] * item['selling_price']));
  double get vat => subtotal * 0.155;
  double get total => subtotal + vat;

  Future<void> _checkout() async {
    //... same checkout code as before...
    // Just make sure to pass tillNumber to receipt
    final db = await DBService.instance.database;
    final settings = await db.query('settings', limit: 1);
    String till = settings.isNotEmpty? settings.first['ecocash_till'] as String : "N/A";

    //... rest of checkout...
    await receiptService.printReceipt({
      //... other fields
      'ecocash_till': till,
    });
    _loadProducts();
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    if (_showScanner) {
      return Scaffold(
        appBar: AppBar(title: const Text("Scan Barcode"), leading: IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _showScanner = false))),
        body: MobileScanner(onDetect: _onBarcodeDetected),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('POS - SALE'),
        actions: [
          IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: _scanBarcode) // SCAN BUTTON
        ],
      ),
      body: Row(
        children: [
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
                    Text("\$${p['selling_price']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("Qty: ${p['quantity']}", style: const TextStyle(fontSize: 12, color: Colors.grey))
                  ])),
                ));
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(children: [
              const Text('CURRENT SALE', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Expanded(child: ListView(children: cart.map((item) => ListTile(
                title: Text(item['name']),
                subtitle: Text("${item['qty']} x \$${item['selling_price']}"),
                trailing: Text("\$${(item['qty'] * item['selling_price']).toStringAsFixed(2)}"),
              )).toList())),
              Text('TOTAL: \$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              TextField(controller: amountController, decoration: const InputDecoration(labelText: "Amount Tendered \$"), keyboardType: TextInputType.number),
              Row(children: [_payBtn("CASH"), _payBtn("ECOCASH"), _payBtn("CARD")]),
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
