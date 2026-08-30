import 'package:flutter/material.dart';
import 'pos_screen.dart';
import 'inventory_screen.dart';
import 'reports_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShopSmart ZW 🇿🇼'),
        actions: const [
          Padding(padding: EdgeInsets.all(16), child: Text('Cashier: Admin 14:32'))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _dashboardCard(),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _menuButton(context, Icons.point_of_sale, 'SALE', () => 
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const POSScreen()))),
                  _menuButton(context, Icons.inventory, 'INVENTORY', () => 
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen()))),
                  _menuButton(context, Icons.fact_check, 'STOCK TAKE', () {}),
                  _menuButton(context, Icons.shopping_cart, 'PURCHASES', () {}),
                  _menuButton(context, Icons.bar_chart, 'REPORTS', () => 
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()))),
                  _menuButton(context, Icons.people, 'STAFF', () {}),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _dashboardCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          const Text("TODAY'S OVERVIEW", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
            Text("SALES: \$1,248.50"),
            Text("GROSS PROFIT: \$436.30"),
            Text("MARGIN: 34.9%"),
          ]),
        ]),
      ),
    );
  }

  Widget _menuButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
      ),
      onPressed: onTap,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 40),
        const SizedBox(height: 10),
        Text(label)
      ]),
    );
  }
}
