import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/main_customer.dart';

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
    final path = join(await getDatabasesPath(), 'hourtracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // lib/database_helper.dart
Future<void> _onCreate(Database db, int version) async {
  // Existing main_customers table
  await db.execute('''
    CREATE TABLE main_customers(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT
    )
  ''');

  // New tables
  await db.execute('''
    CREATE TABLE projects(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      main_customer_id INTEGER,
      setup_start_date TEXT,
      setup_end_date TEXT,
      dismantle_start_date TEXT,
      dismantle_end_date TEXT,
      FOREIGN KEY(main_customer_id) REFERENCES main_customers(id)
    )
  ''');

  await db.execute('''
    CREATE TABLE expo_customers(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      project_id INTEGER,
      FOREIGN KEY(project_id) REFERENCES projects(id)
    )
  ''');

  await db.execute('''
    CREATE TABLE work_days(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT,
      hours_worked REAL,
      expo_customer_id INTEGER,
      project_id INTEGER,
      FOREIGN KEY(expo_customer_id) REFERENCES expo_customers(id),
      FOREIGN KEY(project_id) REFERENCES projects(id)
    )
  ''');
}
}