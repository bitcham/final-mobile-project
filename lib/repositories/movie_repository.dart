import 'dart:math' as math;

import '../data_services/movie_data_service.dart';
import '../models/movie.dart';

class MovieRepository {
  MovieRepository({
    MovieDataService? dataService,
    AssetStringLoader? loadAsset,
    String assetPath = defaultAssetPath,
  }) : _dataService =
           dataService ??
           MovieDataService(loadAsset: loadAsset, assetPath: assetPath);

  static const defaultAssetPath = MovieDataService.defaultAssetPath;

  final MovieDataService _dataService;

  String get assetPath => _dataService.assetPath;

  Future<List<Movie>> fetchMovies() async {
    final data = await _dataService.loadData();
    return List.unmodifiable(data.movies);
  }

  Future<List<Movie>> fetchMoviesPage({
    required int page,
    required int pageSize,
    String? category,
  }) async {
    if (page < 1) {
      throw ArgumentError.value(page, 'page', 'Page must be 1 or greater.');
    }

    if (pageSize < 1) {
      throw ArgumentError.value(
        pageSize,
        'pageSize',
        'Page size must be 1 or greater.',
      );
    }

    final movies = category == null
        ? await fetchMovies()
        : await fetchMoviesByCategory(category);
    final start = (page - 1) * pageSize;

    if (start >= movies.length) {
      return const [];
    }

    final end = math.min(start + pageSize, movies.length);
    return List.unmodifiable(movies.sublist(start, end));
  }

  Future<List<Movie>> fetchMoviesByCategory(String category) async {
    final normalizedCategory = category.trim().toLowerCase();

    if (normalizedCategory.isEmpty) {
      return const [];
    }

    final movies = await fetchMovies();
    return List.unmodifiable(
      movies.where(
        (movie) => movie.category.toLowerCase() == normalizedCategory,
      ),
    );
  }

  Future<Movie?> findById(String id) async {
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      return null;
    }

    final movies = await fetchMovies();

    for (final movie in movies) {
      if (movie.id == normalizedId) {
        return movie;
      }
    }

    return null;
  }

  Future<List<Movie>> searchMovies(String query) async {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return const [];
    }

    final movies = await fetchMovies();
    return List.unmodifiable(
      movies.where((movie) {
        final titleMatches = movie.title.toLowerCase().contains(
          normalizedQuery,
        );
        final genreMatches = movie.genres.any(
          (genre) => genre.toLowerCase().contains(normalizedQuery),
        );

        return titleMatches || genreMatches;
      }),
    );
  }

  void clearCache() {
    _dataService.clearCache();
  }
}
