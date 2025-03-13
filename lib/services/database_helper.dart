import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/field_lot.dart';
import '../models/farming_log_entry.dart';

class DatabaseHelper {
  static final _databaseName = "FarmingApp.db";
  static final _databaseVersion = 1;

  // Bảng lô
  static final lotTable = 'field_lot';
  // Bảng nhật ký
  static final logTable = 'farming_log';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    // Tạo bảng field_lot
    await db.execute('''
      CREATE TABLE $lotTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lotCode TEXT NOT NULL,
        area REAL NOT NULL,
        status TEXT NOT NULL,
        sowDate TEXT NOT NULL,
        harvestDate TEXT
      )
    ''');
    // Tạo bảng farming_log
    await db.execute('''
      CREATE TABLE $logTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lotId INTEGER NOT NULL,
        activityType TEXT NOT NULL,
        activityDate TEXT NOT NULL,
        description TEXT,
        cost REAL,
        images TEXT,
        notes TEXT,
        FOREIGN KEY(lotId) REFERENCES $lotTable(id)
      )
    ''');
  }

  // ==================== FieldLot ====================
  Future<int> insertLot(FieldLot lot) async {
    Database db = await instance.database;
    return await db.insert(lotTable, lot.toMap());
  }

  Future<List<FieldLot>> queryAllLots() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> rows = await db.query(lotTable);
    return rows.map((e) => FieldLot.fromMap(e)).toList();
  }

  Future<int> updateLot(FieldLot lot) async {
    Database db = await instance.database;
    return await db.update(
      lotTable,
      lot.toMap(),
      where: 'id = ?',
      whereArgs: [lot.id],
    );
  }

  Future<int> deleteLot(int id) async {
    Database db = await instance.database;
    return await db.delete(
      lotTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== FarmingLogEntry ====================
  Future<int> insertLog(FarmingLogEntry entry) async {
    Database db = await instance.database;
    return await db.insert(logTable, entry.toMap());
  }

  Future<List<FarmingLogEntry>> queryLogsByLot(int lotId) async {
    Database db = await instance.database;
    final rows = await db.query(
      logTable,
      where: 'lotId = ?',
      whereArgs: [lotId],
      orderBy: 'activityDate ASC',
    );
    return rows.map((e) => FarmingLogEntry.fromMap(e)).toList();
  }
}
