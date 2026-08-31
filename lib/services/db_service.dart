import 'package:sqflite/sqflite.dart'; import 'package:path/path.dart'; import 'package:path_provider/path_provider.dart';
class DBService { static final DBService instance = DBService._init(); static Database? _database; DBService._init(); Future<Database> get database async { if (_database!= null) return _database!; _database = await _initDB('shopsmart_zw.db'); return _database!; }
Future<Database> _initDB(String filePath) async { final dbPath = await getDatabasesPath(); final path = join(dbPath, filePath); return await openDatabase(path, version: 1, onCreate: _createDB); }
Future _createDB(Database db, int version) async {
  await db.execute('CREATE TABLE settings (id INTEGER PRIMARY KEY, business_name TEXT, address TEXT, phone TEXT, vat_rate REAL DEFAULT 15.5, ecocash_till TEXT, shop_id TEXT)');
  await db.execute('CREATE TABLE products (id INTEGER PRIMARY KEY AUTOINCREMENT, shop_id TEXT, barcode TEXT UNIQUE, name TEXT NOT NULL, category TEXT, cost_price REAL NOT NULL, selling_price REAL NOT NULL, quantity INTEGER NOT NULL, minimum_stock INTEGER DEFAULT 5, supplier TEXT, expiry_date TEXT)');
  await db.execute('CREATE TABLE sales (id INTEGER PRIMARY KEY AUTOINCREMENT, shop_id TEXT, receipt_number TEXT UNIQUE, cashier TEXT, customer_id INTEGER, subtotal REAL, discount REAL, vat REAL, total REAL, payment_method TEXT, payment_ref TEXT, amount_tendered REAL, change REAL, date TEXT)');
  await db.execute('CREATE TABLE sale_items (id INTEGER PRIMARY KEY AUTOINCREMENT, sale_id INTEGER, product_id INTEGER, quantity INTEGER, selling_price REAL, cost_price REAL, subtotal REAL)');
  await db.execute('CREATE TABLE stock_movements (id INTEGER PRIMARY KEY AUTOINCREMENT, shop_id TEXT, product_id INTEGER, type TEXT, quantity INTEGER, reason TEXT, user TEXT, date TEXT)');
  await db.execute('CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, shop_id TEXT, name TEXT, pin TEXT, role TEXT)');
  await db.execute('CREATE TABLE customers (id INTEGER PRIMARY KEY AUTOINCREMENT, shop_id TEXT, name TEXT, phone TEXT UNIQUE, loyalty_points REAL DEFAULT 0, total_spent REAL DEFAULT 0)');
  await db.insert('settings', {'business_name': 'ShopSmart Tuckshop', 'address': '123 Samora Machel Ave, Harare', 'phone': '0772 123 456', 'ecocash_till': '123456', 'shop_id': 'DEMO-SHOP-001'});
  await db.insert('users', {'shop_id': 'DEMO-SHOP-001', 'name': 'Admin', 'pin': '1234', 'role': 'Owner'});
  await db.insert('users', {'shop_id': 'DEMO-SHOP-001', 'name': 'Cashier1', 'pin': '1111', 'role': 'Cashier'});
  await db.insert('users', {'shop_id': 'ALL', 'name': 'SuperAdmin', 'pin': '9999', 'role': 'SuperAdmin'});
}}
