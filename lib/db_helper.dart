import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  static Database? _database;

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'balances.db');
    return openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE balances (id INTEGER PRIMARY KEY, account TEXT, balance REAL)',
        );
        await db.insert('balances', {'account': 'Bank1', 'balance': 0.0});
        await db.insert('balances', {'account': 'Bank2', 'balance': 0.0});
      },
      version: 1,
    );
  }

  Future<double> getBalance(String account) async {
    final db = await database;
    final result = await db.query(
      'balances',
      where: 'account = ?',
      whereArgs: [account],
    );
    return result.isNotEmpty ? result.first['balance'] as double : 0.0;
  }

  Future<void> updateBalance(String account, double newBalance) async {
    final db = await database;
    await db.update(
      'balances',
      {'balance': newBalance},
      where: 'account = ?',
      whereArgs: [account],
    );
  }
}