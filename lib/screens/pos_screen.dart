import 'package:flutter/material.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  List<Map> cart = [
    {'name': 'Coca-Cola', 'qty': 1, 'price': 1.00},
    {'name': 'Bread', 'qty': 1, 'price': 1.50},
  ];

  double get total => cart.fold(0, (sum, item) => sum + (item['qty'] * item['price']));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('POS - SALE')),
      body: Row(
        children: [
          // Left: Products
          Expanded(
            flex: 2,
            child: GridView.count(
              crossAxisCount: 4,
              children: ['Coca-Cola', 'Pepsi', 'Water', 'Bread', 'Milk', 'Sugar']
                  .map((e) => Card(child: Center(child: Text(e)))).toList(),
            ),
          ),
          // Right: Cart
          Expanded(
            flex: 1,
            child: Column(
              children: [
                const Text('CURRENT SALE', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Expanded(
                  child: ListView(
                    children: cart.map((item) => 
                      ListTile(
                        title: Text(item['name']),
                        trailing: Text('\$${(item['qty'] * item['price']).toStringAsFixed(2)}'),
                      )
                    ).toList(),
                  ),
                ),
                Text('TOTAL: \$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24)),
                Row(children: [
                  Expanded(child: ElevatedButton(onPressed: (){}, child: const Text('CASH'))),
                  Expanded(child: ElevatedButton(onPressed: (){}, child: const Text('ECOCASH'))),
                ])
              ],
            ),
          )
        ],
      ),
    );
  }
}
