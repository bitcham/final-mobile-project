import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:movie_rating/src/core/models/movie_view.dart';

typedef RatedMovie = ({MovieView movie, double rating});

class MovieLibraryDatabaseService {
  static const String _ratingsTable = 'ratings';
  static const String _watchlistTable = 'watchlist';
  static bool _webFactoryConfigured = false;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final path = await _databasePath();
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE $_ratingsTable (
            user_id INTEGER NOT NULL,
            movie_title TEXT NOT NULL,
            rating REAL NOT NULL,
            synopsis TEXT NOT NULL,
            year INTEGER NOT NULL,
            poster_url TEXT,
            genres TEXT NOT NULL,
            rated_at INTEGER NOT NULL,
            PRIMARY KEY (user_id, movie_title)
          )
        ''');
        await database.execute('''
          CREATE TABLE $_watchlistTable (
            user_id INTEGER NOT NULL,
            movie_title TEXT NOT NULL,
            rating REAL NOT NULL,
            synopsis TEXT NOT NULL,
            year INTEGER NOT NULL,
            poster_url TEXT,
            genres TEXT NOT NULL,
            added_at INTEGER NOT NULL,
            PRIMARY KEY (user_id, movie_title)
          )
        ''');
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
      return 'cinerate_library.db';
    }

    final databaseDirectory = await getDatabasesPath();
    return p.join(databaseDirectory, 'cinerate_library.db');
  }

  Future<void> upsertRating(int userId, MovieView movie, double rating) async {
    final db = await database;
    await db.insert(_ratingsTable, {
      'user_id': userId,
      'rating': rating,
      'rated_at': DateTime.now().millisecondsSinceEpoch,
      ..._movieColumns(movie),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<RatedMovie>> fetchRatings(int userId) async {
    final db = await database;
    final rows = await db.query(
      _ratingsTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'rated_at DESC',
    );
    return rows
        .map(
          (row) => (
            movie: _movieFromRow(row),
            rating: (row['rating'] as num).toDouble(),
          ),
        )
        .toList(growable: false);
  }

  Future<void> addToWatchlist(int userId, MovieView movie) async {
    final db = await database;
    await db.insert(_watchlistTable, {
      'user_id': userId,
      'added_at': DateTime.now().millisecondsSinceEpoch,
      ..._movieColumns(movie),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeFromWatchlist(int userId, String movieTitle) async {
    final db = await database;
    await db.delete(
      _watchlistTable,
      where: 'user_id = ? AND movie_title = ?',
      whereArgs: [userId, movieTitle],
    );
  }

  Future<List<MovieView>> fetchWatchlist(int userId) async {
    final db = await database;
    final rows = await db.query(
      _watchlistTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'added_at DESC',
    );
    return rows.map(_movieFromRow).toList(growable: false);
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Map<String, Object?> _movieColumns(MovieView movie) {
    return {
      'movie_title': movie.title,
      'synopsis': movie.synopsis,
      'year': movie.year,
      'poster_url': movie.posterUrl,
      'genres': jsonEncode(movie.genres),
    };
  }

  MovieView _movieFromRow(Map<String, Object?> row) {
    final genres = (jsonDecode(row['genres'] as String? ?? '[]') as List)
        .cast<String>();
    return MovieView(
      title: row['movie_title'] as String? ?? '',
      synopsis: row['synopsis'] as String? ?? '',
      rating: (row['rating'] as num?)?.toDouble() ?? 0.0,
      genres: genres,
      year: (row['year'] as num?)?.toInt() ?? 0,
      posterUrl: row['poster_url'] as String?,
    );
  }
}
