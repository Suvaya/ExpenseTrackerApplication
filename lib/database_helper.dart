import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'transaction_descriptions.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE descriptions ('
              'id INTEGER PRIMARY KEY, '
              'description TEXT)',
        );
      },
    );
  }

  Future<void> saveDescription(int id, String description) async {
    final db = await database;
    await db.insert(
      'descriptions',
      {'id': id, 'description': description},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getDescription(int id) async {
    final db = await database;
    final maps = await db.query(
      'descriptions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first['description'] as String;
    }
    return null;
  }
}
