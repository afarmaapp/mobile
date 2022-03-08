import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class NotificationDB {
  static final _databaseName = "notifications.db";
  static final _databaseVersion = 1;
  static final table = 'notifications';
  static final columnId = 'id';
  static final columnTitle = 'title';
  static final columnContent = 'content';
  static final columnNotificationType = 'notification_type';
  static final columnClassId = 'class_id';
  static final columnRead = 'read';
  static final columnCreatedAt = 'created_at';

  NotificationDB._privateConstructor();
  static final NotificationDB instance = NotificationDB._privateConstructor();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // Código SQL para criar o banco de dados e a tabela
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notifications (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTitle VARCHAR(255),
        $columnContent TEXT,
        $columnClassId INTEGER,
        $columnNotificationType VARCHAR(255),
        $columnRead INTEGER DEFAULT 0,
        $columnCreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await (instance.database as FutureOr<Database>);

    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await (instance.database as FutureOr<Database>);
    return await db.query(table);
  }

  Future<int?> queryRowCount() async {
    Database db = await (instance.database as FutureOr<Database>);
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await (instance.database as FutureOr<Database>);
    int? id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    Database db = await (instance.database as FutureOr<Database>);
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}
