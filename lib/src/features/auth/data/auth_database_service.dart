import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../models/app_user.dart';

class AuthDatabaseService {
  static const String _table = 'users';
  static bool _webFactoryConfigured = false;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final path = await _databasePath();
    _database = await openDatabase(
      path,
      version: 3,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE $_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT NOT NULL UNIQUE COLLATE NOCASE,
            password_hash TEXT NOT NULL,
            password_salt TEXT NOT NULL,
            real_name TEXT NOT NULL,
            profile_image_path TEXT,
            profile_banner_image_path TEXT,
            bio TEXT
          )
        ''');
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await database.execute('ALTER TABLE $_table ADD COLUMN bio TEXT');
        }
        if (oldVersion < 3) {
          await database.execute(
            'ALTER TABLE $_table ADD COLUMN profile_banner_image_path TEXT',
          );
        }
      },
    );
    return _database!;
  }

  Future<String> _databasePath() async {
    if (kIsWeb) {
      if (!_webFactoryConfigured) {
        databaseFactory = databaseFactoryFfiWeb;
        _webFactoryConfigured = true;
      }
      return 'cinerate_auth.db';
    }

    final databaseDirectory = await getDatabasesPath();
    return p.join(databaseDirectory, 'cinerate_auth.db');
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

  Future<void> updateUser(AppUser user) async {
    final id = user.id;
    if (id == null) {
      throw ArgumentError('User id is required to update a stored user.');
    }

    final db = await database;
    await db.update(_table, user.toRow(), where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
