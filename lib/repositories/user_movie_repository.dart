import '../data_services/movie_data_service.dart';
import '../models/movie.dart';
import '../models/user_movie_entry.dart';

class UserMovieRepository {
  UserMovieRepository({
    MovieDataService? dataService,
    AssetStringLoader? loadAsset,
    String assetPath = defaultAssetPath,
  }) : _dataService =
           dataService ??
           MovieDataService(loadAsset: loadAsset, assetPath: assetPath);

  static const defaultAssetPath = MovieDataService.defaultAssetPath;

  final MovieDataService _dataService;

  String get assetPath => _dataService.assetPath;

  Future<List<UserMovieEntry>> fetchUserMovieEntries() async {
    final data = await _dataService.loadData();
    return List.unmodifiable(data.userMovieEntries);
  }

  Future<UserMovieEntry?> findByMovieId(String movieId) async {
    final normalizedMovieId = movieId.trim();

    if (normalizedMovieId.isEmpty) {
      return null;
    }

    final entries = await fetchUserMovieEntries();

    for (final entry in entries) {
      if (entry.movieId == normalizedMovieId) {
        return entry;
      }
    }

    return null;
  }

  Future<UserMovieEntry?> findUserMovieEntry(String movieId) {
    return findByMovieId(movieId);
  }

  Future<List<UserMovieEntry>> fetchWatchlistEntries() async {
    final entries = await fetchUserMovieEntries();
    return List.unmodifiable(entries.where((entry) => entry.inWatchlist));
  }

  Future<List<UserMovieEntry>> fetchRatedEntries() async {
    final entries = await fetchUserMovieEntries();
    return List.unmodifiable(entries.where((entry) => entry.userRating > 0));
  }

  Future<List<Movie>> fetchWatchlistMovies() async {
    final data = await _dataService.loadData();
    final watchlistIds = data.userMovieEntries
        .where((entry) => entry.inWatchlist)
        .map((entry) => entry.movieId)
        .toSet();

    return List.unmodifiable(
      data.movies.where((movie) => watchlistIds.contains(movie.id)),
    );
  }

  Future<List<Movie>> fetchRatedMovies() async {
    final data = await _dataService.loadData();
    final ratedIds = data.userMovieEntries
        .where((entry) => entry.userRating > 0)
        .map((entry) => entry.movieId)
        .toSet();

    return List.unmodifiable(
      data.movies.where((movie) => ratedIds.contains(movie.id)),
    );
  }

  void clearCache() {
    _dataService.clearCache();
  }
}
