import 'package:flutter/material.dart';
import 'pos_screen.dart';
import 'inventory_screen.dart';
import 'stocktake_screen.dart';
import 'reports_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ShopSmart ZW 🇿🇼')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // 2 columns for phone/tablet
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _menuButton(context, Icons.point_of_sale, 'SALE', const POSScreen()),
            _menuButton(context, Icons.inventory, 'INVENTORY', const InventoryScreen()),
            _menuButton(context, Icons.fact_check, 'STOCK TAKE', const StockTakeScreen()),
            _menuButton(context, Icons.bar_chart, 'REPORTS', const ReportsScreen()),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext context, IconData icon, String label, Widget screen) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 40), const SizedBox(height: 10), Text(label, style: const TextStyle(fontSize: 18))
      ]),
    );
  }
}
