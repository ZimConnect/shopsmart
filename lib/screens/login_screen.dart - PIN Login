import 'package:flutter/material.dart';
import 'package:shopsmart_zw/services/db_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String pin = "";
  String error = "";

  void _checkPin() async {
    final db = await DBService.instance.database;
    final res = await db.query('users', where: 'pin =?', whereArgs: [pin]);
    if (res.isNotEmpty) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      setState(() => error = "Invalid PIN");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text("ShopSmart ZW", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Text(error, style: const TextStyle(color: Colors.red)),
          SizedBox(
            width: 300,
            child: TextField(
              obscureText: true,
              keyboardType: TextInputType.number,
              onChanged: (val) => pin = val,
              decoration: const InputDecoration(labelText: "Enter PIN", border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: _checkPin, child: const Text("LOGIN"))
        ]),
      ),
    );
  }
}
