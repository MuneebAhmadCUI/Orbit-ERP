import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqliteService {
  static final SqliteService instance = SqliteService._init();
  static Database? _database;

  SqliteService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('orbit_erp.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE customers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        company TEXT,
        email TEXT,
        phone TEXT,
        address TEXT,
        createdAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE vendors (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        contact TEXT,
        email TEXT,
        phone TEXT,
        address TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE invoices (
        id TEXT PRIMARY KEY,
        number TEXT NOT NULL,
        customerId TEXT NOT NULL,
        customerName TEXT,
        issuedAt TEXT,
        dueDate TEXT,
        status TEXT,
        subtotal REAL,
        taxRate REAL,
        total REAL,
        notes TEXT,
        FOREIGN KEY (customerId) REFERENCES customers (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE invoice_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoiceId TEXT NOT NULL,
        description TEXT NOT NULL,
        quantity REAL NOT NULL,
        unitPrice REAL NOT NULL,
        amount REAL NOT NULL,
        FOREIGN KEY (invoiceId) REFERENCES invoices (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE activities (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        subtitle TEXT,
        timestamp TEXT,
        iconType TEXT
      )
    ''');

    await _seedDatabase(db);
  }

  Future<void> _seedDatabase(Database db) async {
    final customers = [
      {'id': 'cust-1', 'name': 'Acme Corp', 'company': 'Acme Inc.', 'email': 'contact@acme.com', 'phone': '+1 555-0101', 'createdAt': '2025-01-15T10:00:00.000Z'},
      {'id': 'cust-2', 'name': 'Global Tech', 'company': 'Global Tech Ltd', 'email': 'sales@globaltech.com', 'phone': '+1 555-0102', 'createdAt': '2025-03-20T10:00:00.000Z'},
      {'id': 'cust-3', 'name': 'Apex Solutions', 'company': 'Apex Inc', 'email': 'info@apex.com', 'phone': '+1 555-0103', 'createdAt': '2026-01-10T10:00:00.000Z'},
      {'id': 'cust-4', 'name': 'Stellar Logistics', 'company': 'Stellar LLC', 'email': 'admin@stellar.com', 'phone': '+1 555-0104', 'createdAt': '2026-02-05T10:00:00.000Z'},
      {'id': 'cust-5', 'name': 'Nexus Innovations', 'company': 'Nexus Group', 'email': 'contact@nexus.com', 'phone': '+1 555-0105', 'createdAt': '2026-03-12T10:00:00.000Z'},
      {'id': 'cust-6', 'name': 'Horizon Retail', 'company': 'Horizon Corp', 'email': 'hello@horizon.com', 'phone': '+1 555-0106', 'createdAt': '2026-04-01T10:00:00.000Z'},
      {'id': 'cust-7', 'name': 'Quantum Systems', 'company': 'Quantum Ltd', 'email': 'support@quantum.com', 'phone': '+1 555-0107', 'createdAt': '2026-05-18T10:00:00.000Z'},
      {'id': 'cust-8', 'name': 'BlueSky Media', 'company': 'BlueSky Inc', 'email': 'info@bluesky.com', 'phone': '+1 555-0108', 'createdAt': '2026-06-22T10:00:00.000Z'},
    ];

    for (final c in customers) {
      await db.insert('customers', c);
    }

    final invoices = [
        {'id': 'inv-101', 'number': 'INV-1001', 'customerId': 'cust-1', 'customerName': 'Acme Corp', 'issuedAt': '2026-01-15T10:00:00.000Z', 'dueDate': '2026-01-29T10:00:00.000Z', 'status': 'Paid', 'total': 8000.0},
        {'id': 'inv-102', 'number': 'INV-1002', 'customerId': 'cust-3', 'customerName': 'Apex Solutions', 'issuedAt': '2026-01-20T10:00:00.000Z', 'dueDate': '2026-02-03T10:00:00.000Z', 'status': 'Unpaid', 'total': 22000.0},
        {'id': 'inv-103', 'number': 'INV-1003', 'customerId': 'cust-2', 'customerName': 'Global Tech', 'issuedAt': '2026-02-10T10:00:00.000Z', 'dueDate': '2026-02-24T10:00:00.000Z', 'status': 'Paid', 'total': 28000.0},
        {'id': 'inv-104', 'number': 'INV-1004', 'customerId': 'cust-4', 'customerName': 'Stellar Logistics', 'issuedAt': '2026-02-18T10:00:00.000Z', 'dueDate': '2026-03-04T10:00:00.000Z', 'status': 'Unpaid', 'total': 9000.0},
        {'id': 'inv-105', 'number': 'INV-1005', 'customerId': 'cust-5', 'customerName': 'Nexus Innovations', 'issuedAt': '2026-03-15T10:00:00.000Z', 'dueDate': '2026-03-29T10:00:00.000Z', 'status': 'Unpaid', 'total': 17000.0},
        {'id': 'inv-106', 'number': 'INV-1006', 'customerId': 'cust-1', 'customerName': 'Acme Corp', 'issuedAt': '2026-04-05T10:00:00.000Z', 'dueDate': '2026-04-19T10:00:00.000Z', 'status': 'Paid', 'total': 9000.0},
        {'id': 'inv-107', 'number': 'INV-1007', 'customerId': 'cust-6', 'customerName': 'Horizon Retail', 'issuedAt': '2026-04-20T10:00:00.000Z', 'dueDate': '2026-05-04T10:00:00.000Z', 'status': 'Unpaid', 'total': 22000.0},
        {'id': 'inv-108', 'number': 'INV-1008', 'customerId': 'cust-2', 'customerName': 'Global Tech', 'issuedAt': '2026-05-10T10:00:00.000Z', 'dueDate': '2026-05-24T10:00:00.000Z', 'status': 'Paid', 'total': 16000.0},
        {'id': 'inv-109', 'number': 'INV-1009', 'customerId': 'cust-7', 'customerName': 'Quantum Systems', 'issuedAt': '2026-05-25T10:00:00.000Z', 'dueDate': '2026-06-08T10:00:00.000Z', 'status': 'Unpaid', 'total': 10000.0},
        {'id': 'inv-110', 'number': 'INV-1010', 'customerId': 'cust-1', 'customerName': 'Acme Corp', 'issuedAt': '2026-06-02T10:00:00.000Z', 'dueDate': '2026-06-16T10:00:00.000Z', 'status': 'Paid', 'total': 28000.0},
        {'id': 'inv-111', 'number': 'INV-1011', 'customerId': 'cust-8', 'customerName': 'BlueSky Media', 'issuedAt': '2026-06-25T10:00:00.000Z', 'dueDate': '2026-07-09T10:00:00.000Z', 'status': 'Unpaid', 'total': 9000.0},
        {'id': 'inv-112', 'number': 'INV-1012', 'customerId': 'cust-8', 'customerName': 'BlueSky Media', 'issuedAt': '2026-07-12T10:00:00.000Z', 'dueDate': '2026-07-26T10:00:00.000Z', 'status': 'Unpaid', 'total': 32000.0},
        {'id': 'inv-113', 'number': 'INV-1013', 'customerId': 'cust-2', 'customerName': 'Global Tech', 'issuedAt': '2026-08-08T10:00:00.000Z', 'dueDate': '2026-08-22T10:00:00.000Z', 'status': 'Paid', 'total': 7000.0},
        {'id': 'inv-114', 'number': 'INV-1014', 'customerId': 'cust-7', 'customerName': 'Quantum Systems', 'issuedAt': '2026-08-18T10:00:00.000Z', 'dueDate': '2026-09-01T10:00:00.000Z', 'status': 'Unpaid', 'total': 22000.0},
        {'id': 'inv-115', 'number': 'INV-1015', 'customerId': 'cust-1', 'customerName': 'Acme Corp', 'issuedAt': '2026-09-05T10:00:00.000Z', 'dueDate': '2026-09-19T10:00:00.000Z', 'status': 'Paid', 'total': 10000.0},
        {'id': 'inv-116', 'number': 'INV-1016', 'customerId': 'cust-6', 'customerName': 'Horizon Retail', 'issuedAt': '2026-09-20T10:00:00.000Z', 'dueDate': '2026-10-04T10:00:00.000Z', 'status': 'Unpaid', 'total': 26000.0},
    ];

    for (final inv in invoices) {
      await db.insert('invoices', inv);
    }
  }
}
