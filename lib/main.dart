import 'package:flutter/material.dart';
import 'package:shopsmart_zw/screens/home_screen.dart';
import 'package:shopsmart_zw/services/db_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBService.instance.database; // init DB
  runApp(const ShopSmartApp());
}

class ShopSmartApp extends StatelessWidget {
  const ShopSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopSmart ZW',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF006400), // Zim green
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF006400)),
        useMaterial3: true,
        textTheme: const TextTheme(bodyLarge: TextStyle(fontSize: 16)),
      ),
      home: const HomeScreen(),
    );
  }
}
