import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/movie.dart';
import '../models/user_movie_entry.dart';

typedef AssetStringLoader = Future<String> Function(String assetPath);

class MovieDataService {
  MovieDataService({
    AssetStringLoader? loadAsset,
    this.assetPath = defaultAssetPath,
  }) : _loadAsset = loadAsset ?? rootBundle.loadString;

  static const defaultAssetPath = 'assets/data/movies.json';

  final String assetPath;
  final AssetStringLoader _loadAsset;
  MovieData? _cachedData;

  Future<MovieData> loadData() async {
    final cachedData = _cachedData;
    if (cachedData != null) {
      return cachedData;
    }

    final jsonString = await _loadAsset(assetPath);
    final decoded = jsonDecode(jsonString);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Movie data must be a JSON object.');
    }

    final data = MovieData.fromJson(decoded);
    _cachedData = data;
    return data;
  }

  void clearCache() {
    _cachedData = null;
  }
}

class MovieData {
  const MovieData({required this.movies, required this.userMovieEntries});

  final List<Movie> movies;
  final List<UserMovieEntry> userMovieEntries;

  factory MovieData.fromJson(Map<String, dynamic> json) {
    return MovieData(
      movies: _objectList(json['movies'], Movie.fromJson),
      userMovieEntries: _objectList(
        json['userMovieEntries'],
        UserMovieEntry.fromJson,
      ),
    );
  }

  static List<T> _objectList<T>(
    Object? value,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    if (value is! List) {
      return const [];
    }

    return value.whereType<Map<String, dynamic>>().map(fromJson).toList();
  }
}
