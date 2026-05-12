import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/app_user.dart';

class AuthDatabaseService {
  static const String _table = 'users';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = p.join(directory.path, 'cinerate_auth.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE $_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT NOT NULL UNIQUE COLLATE NOCASE,
            password_hash TEXT NOT NULL,
            password_salt TEXT NOT NULL,
            real_name TEXT NOT NULL,
            profile_image_path TEXT
          )
        ''');
      },
    );
    return _database!;
  }

  Future<int> insertUser(AppUser user) async {
    final db = await database;
    return db.insert(
      _table,
      user.toRow(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<AppUser?> findByEmail(String email) async {
    final db = await database;
    final rows = await db.query(
      _table,
      where: 'email = ? COLLATE NOCASE',
      whereArgs: [email.trim()],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return AppUser.fromRow(rows.first);
  }

  Future<AppUser?> findById(int id) async {
    final db = await database;
    final rows = await db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return AppUser.fromRow(rows.first);
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
