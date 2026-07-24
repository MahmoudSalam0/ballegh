import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ballegh_app/models/report.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final databaseDirectory = await getDatabasesPath();
    final databasePath = join(databaseDirectory, 'ballegh.db');

    return openDatabase(databasePath, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        location TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        imagePath TEXT,
        createdAt TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertReport(Report report) async {
    final db = await database;

    final reportId = await db.insert('reports', report.toMap());

    return reportId;
  }

  Future<List<Report>> getAllReports() async {
    final db = await database;

    final reportMaps = await db.query('reports', orderBy: 'createdAt DESC');

    return reportMaps.map((map) {
      return Report.fromMap(map);
    }).toList();
  }
}
