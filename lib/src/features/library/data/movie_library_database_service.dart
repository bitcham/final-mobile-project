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
      version: 2,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE $_ratingsTable (
            user_id INTEGER NOT NULL,
            movie_title TEXT NOT NULL,
            rating REAL NOT NULL,
            synopsis TEXT NOT NULL,
            year INTEGER NOT NULL,
            runtime_minutes INTEGER NOT NULL,
            age_rating TEXT NOT NULL,
            poster_url TEXT,
            trailer_url TEXT,
            tmdb_id INTEGER,
            genres TEXT NOT NULL,
            streaming_platforms TEXT NOT NULL,
            cast_members TEXT NOT NULL,
            reviews TEXT NOT NULL,
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
            runtime_minutes INTEGER NOT NULL,
            age_rating TEXT NOT NULL,
            poster_url TEXT,
            trailer_url TEXT,
            tmdb_id INTEGER,
            genres TEXT NOT NULL,
            streaming_platforms TEXT NOT NULL,
            cast_members TEXT NOT NULL,
            reviews TEXT NOT NULL,
            added_at INTEGER NOT NULL,
            PRIMARY KEY (user_id, movie_title)
          )
        ''');
      },
      onUpgrade: (database, oldVersion, version) async {
        if (oldVersion < 2) {
          await _addMovieDetailColumns(database, _ratingsTable);
          await _addMovieDetailColumns(database, _watchlistTable);
        }
      },
    );
    return _database!;
  }

  Future<void> _addMovieDetailColumns(Database database, String table) async {
    await database.execute(
      'ALTER TABLE $table ADD COLUMN runtime_minutes INTEGER NOT NULL DEFAULT 124',
    );
    await database.execute(
      "ALTER TABLE $table ADD COLUMN age_rating TEXT NOT NULL DEFAULT 'PG-13'",
    );
    await database.execute('ALTER TABLE $table ADD COLUMN trailer_url TEXT');
    await database.execute('ALTER TABLE $table ADD COLUMN tmdb_id INTEGER');
    await database.execute(
      "ALTER TABLE $table ADD COLUMN streaming_platforms TEXT NOT NULL DEFAULT '[\"Disney+\",\"Prime Video\",\"Apple TV\"]'",
    );
    await database.execute(
      "ALTER TABLE $table ADD COLUMN cast_members TEXT NOT NULL DEFAULT '[]'",
    );
    await database.execute(
      "ALTER TABLE $table ADD COLUMN reviews TEXT NOT NULL DEFAULT '[]'",
    );
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
      'rating': movie.rating,
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
      'runtime_minutes': movie.runtimeMinutes,
      'age_rating': movie.ageRating,
      'poster_url': movie.posterUrl,
      'trailer_url': movie.trailerUrl,
      'tmdb_id': movie.tmdbId,
      'genres': jsonEncode(movie.genres),
      'streaming_platforms': jsonEncode(movie.streamingPlatforms),
      'cast_members': jsonEncode(
        movie.cast.map((member) => member.toJson()).toList(),
      ),
      'reviews': jsonEncode(
        movie.reviews.map((review) => review.toJson()).toList(),
      ),
    };
  }

  MovieView _movieFromRow(Map<String, Object?> row) {
    final genres = (jsonDecode(row['genres'] as String? ?? '[]') as List)
        .cast<String>();
    final streamingPlatforms =
        (jsonDecode(row['streaming_platforms'] as String? ?? '[]') as List)
            .cast<String>();
    final cast = (jsonDecode(row['cast_members'] as String? ?? '[]') as List)
        .cast<Map<String, Object?>>()
        .map(MovieCastCredit.fromJson)
        .toList(growable: false);
    final reviews = (jsonDecode(row['reviews'] as String? ?? '[]') as List)
        .cast<Map<String, Object?>>()
        .map(MovieReviewSnippet.fromJson)
        .toList(growable: false);
    return MovieView(
      title: row['movie_title'] as String? ?? '',
      synopsis: row['synopsis'] as String? ?? '',
      rating: (row['rating'] as num?)?.toDouble() ?? 0.0,
      genres: genres,
      year: (row['year'] as num?)?.toInt() ?? 0,
      runtimeMinutes: (row['runtime_minutes'] as num?)?.toInt() ?? 124,
      ageRating: row['age_rating'] as String? ?? 'PG-13',
      streamingPlatforms: streamingPlatforms.isEmpty
          ? kDefaultStreamingPlatforms
          : streamingPlatforms,
      cast: cast.isEmpty ? kDefaultMovieCast : cast,
      reviews: reviews.isEmpty ? kDefaultMovieReviews : reviews,
      posterUrl: row['poster_url'] as String?,
      trailerUrl: row['trailer_url'] as String?,
      tmdbId: (row['tmdb_id'] as num?)?.toInt(),
    );
  }
}
