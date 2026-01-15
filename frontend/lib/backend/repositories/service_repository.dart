import 'package:sqflite/sqflite.dart';
import 'base_repository.dart';
import '../models/service_record.dart';

class ServiceRepository extends BaseRepository {
  Future<List<ServiceRecord>> getAllServices() async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query('service_records', orderBy: "date DESC");
    return List.generate(maps.length, (i) => ServiceRecord.fromMap(maps[i]));
  }

  Future<List<ServiceRecord>> getTodaysServices() async {
    final database = await db;
    final now = DateTime.now();
    final todayStr = now.toIso8601String().substring(0, 10); // YYYY-MM-DD
    
    // SQLite string comparison
    final List<Map<String, dynamic>> maps = await database.query(
      'service_records',
      where: 'date LIKE ?',
      whereArgs: ['$todayStr%'],
    );
    return List.generate(maps.length, (i) => ServiceRecord.fromMap(maps[i]));
  }

  Future<void> saveServiceRecord(ServiceRecord record) async {
    final database = await db;
    await database.insert(
      'service_records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
