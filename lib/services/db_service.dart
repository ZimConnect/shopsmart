import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBService {
  static final DBService instance = DBService._init();
  static Database? _database;
  DBService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('shopsmart_zw.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      barcode TEXT UNIQUE,
      name TEXT NOT NULL,
      category TEXT,
      cost_price REAL NOT NULL,
      selling_price REAL NOT NULL,
      quantity INTEGER NOT NULL,
      minimum_stock INTEGER,
      supplier TEXT,
      expiry_date TEXT
      barcode TEXT UNIQUE,
    )''');

    await db.execute('''
    CREATE TABLE sales (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      receipt_number TEXT UNIQUE,
      cashier TEXT,
      subtotal REAL,
      discount REAL,
      vat REAL,
      total REAL,
      payment_method TEXT,
      amount_tendered REAL,
      change REAL,
      date TEXT,
      is_fiscalized INTEGER DEFAULT 0
    )''');

    await db.execute('''
    CREATE TABLE sale_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      sale_id INTEGER,
      product_id INTEGER,
      quantity INTEGER,
      selling_price REAL,
      cost_price REAL,
      subtotal REAL,
      FOREIGN KEY (sale_id) REFERENCES sales (id),
      FOREIGN KEY (product_id) REFERENCES products (id)
    )''');

    await db.execute('''
    CREATE TABLE stock_movements (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      product_id INTEGER,
      type TEXT,
      quantity INTEGER,
      reason TEXT,
      user TEXT,
      date TEXT,
      FOREIGN KEY (product_id) REFERENCES products (id)
    )''');

    await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      pin TEXT,
      role TEXT
    )''');

    await db.execute('''
CREATE TABLE settings (
  id INTEGER PRIMARY KEY,
  business_name TEXT,
  address TEXT,
  phone TEXT,
  vat_rate REAL DEFAULT 15.5,
  ecocash_till TEXT
)''');

// Insert default Zim business
await db.insert('settings', {
  'business_name': 'ShopSmart Tuckshop',
  'address': 'Harare, Zimbabwe',
  'phone': '0772 123 456',
  'ecocash_till': '123456'
});
    
    // Seed admin user: PIN 1234
    await db.insert('users', {'name': 'Admin', 'pin': '1234', 'role': 'Owner'});
  }
}
