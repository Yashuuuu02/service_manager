import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/inventory_item.dart';

class InventoryRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<InventoryItem>> getAllItems() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('inventory');
    return List.generate(maps.length, (i) => InventoryItem.fromMap(maps[i]));
  }

  Future<void> addItem(InventoryItem item) async {
    final db = await _dbHelper.database;
    await db.insert(
      'inventory',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateItem(InventoryItem item) async {
    final db = await _dbHelper.database;
    await db.update(
      'inventory',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> updateStock(String id, int quantityChange) async {
    final db = await _dbHelper.database;
    // Transaction to ensure atomicity
    await db.transaction((txn) async {
      final List<Map<String, dynamic>> maps = await txn.query(
        'inventory',
        columns: ['quantity', 'trackStock'],
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final currentQty = maps.first['quantity'] as int;
        final trackStock = (maps.first['trackStock'] as int? ?? 1) == 1;

        if (trackStock) {
           await txn.update(
            'inventory',
            {'quantity': currentQty + quantityChange},
            where: 'id = ?',
            whereArgs: [id],
          );
        }
      }
    });
  }

  Future<void> deleteItem(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'inventory',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
