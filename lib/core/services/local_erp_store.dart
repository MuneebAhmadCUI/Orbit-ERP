import 'package:sqflite/sqflite.dart';
import 'sqlite_service.dart';

/// Persistence layer utilizing SQLite database.
class LocalErpStore {
  static Future<Database> get _db async => await SqliteService.instance.database;

  static Future<List<Map<String, dynamic>>> load(String collection) async {
    final db = await _db;
    
    // Sort logic for specific tables
    String orderBy = 'id DESC'; // default
    if (collection == 'activities') {
      orderBy = 'timestamp DESC';
    } else if (collection == 'invoices') {
      orderBy = 'issuedAt DESC';
    } else if (collection == 'customers') {
      orderBy = 'createdAt DESC';
    }

    final results = await db.query(collection, orderBy: orderBy);

    // If fetching invoices, we also need to attach their line items to maintain UI compatibility
    if (collection == 'invoices') {
      final invoicesWithItems = <Map<String, dynamic>>[];
      for (final row in results) {
        final invoiceMap = Map<String, dynamic>.from(row);
        final items = await db.query(
          'invoice_items',
          where: 'invoiceId = ?',
          whereArgs: [row['id']],
        );
        invoiceMap['items'] = items;
        invoicesWithItems.add(invoiceMap);
      }
      return invoicesWithItems;
    }

    return results.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> add(String collection, Map<String, dynamic> entry) async {
    final db = await _db;

    if (collection == 'invoices') {
      // Handle nested invoice items by using a transaction
      await db.transaction((txn) async {
        final items = List<Map<String, dynamic>>.from(entry['items'] ?? []);
        
        // Remove items list before inserting into main invoices table
        final invoiceData = Map<String, dynamic>.from(entry)..remove('items');
        await txn.insert('invoices', invoiceData, conflictAlgorithm: ConflictAlgorithm.replace);

        for (final item in items) {
          item['invoiceId'] = entry['id'];
          await txn.insert('invoice_items', item, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      });
    } else {
      await db.insert(collection, entry, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  static Future<void> update(String collection, String id, Map<String, dynamic> updatedEntry) async {
    final db = await _db;
    await db.update(
      collection,
      updatedEntry,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> updateStatus(String collection, String id, String status) async {
    final db = await _db;
    await db.update(
      collection,
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> remove(String collection, String id) async {
    final db = await _db;
    await db.delete(
      collection,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> removeMultiple(String collection, Set<String> ids) async {
    final db = await _db;
    await db.transaction((txn) async {
      for (final id in ids) {
        await txn.delete(
          collection,
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    });
  }

  static Future<void> logActivity(String title, String subtitle, {String iconType = 'invoice'}) async {
    final db = await _db;
    final activity = {
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'title': title,
      'subtitle': subtitle,
      'timestamp': DateTime.now().toIso8601String(),
      'iconType': iconType,
    };
    await db.insert('activities', activity, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}