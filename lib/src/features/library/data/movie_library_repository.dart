import 'package:movie_rating/src/core/models/movie_view.dart';
import 'movie_library_database_service.dart';

class MovieLibrary {
  const MovieLibrary({
    required this.ratings,
    required this.ratedMovies,
    required this.watchlistTitles,
    required this.watchlistMovies,
  });

  const MovieLibrary.empty()
    : ratings = const {},
      ratedMovies = const [],
      watchlistTitles = const {},
      watchlistMovies = const [];

  final Map<String, double> ratings;

  final List<MovieView> ratedMovies;

  final Set<String> watchlistTitles;

  final List<MovieView> watchlistMovies;
}

class MovieLibraryRepository {
  MovieLibraryRepository({MovieLibraryDatabaseService? databaseService})
    : _databaseService = databaseService ?? MovieLibraryDatabaseService();

  final MovieLibraryDatabaseService _databaseService;

  Future<MovieLibrary> load(int userId) async {
    final ratings = await _databaseService.fetchRatings(userId);
    final watchlist = await _databaseService.fetchWatchlist(userId);
    return MovieLibrary(
      ratings: {for (final entry in ratings) entry.movie.title: entry.rating},
      ratedMovies: ratings.map((entry) => entry.movie).toList(growable: false),
      watchlistTitles: {for (final movie in watchlist) movie.title},
      watchlistMovies: watchlist,
    );
  }

  Future<void> rate(int userId, MovieView movie, double rating) {
    return _databaseService.upsertRating(userId, movie, rating);
  }

  Future<bool> toggleWatchlist({
    required int userId,
    required MovieView movie,
    required bool isInWatchlist,
  }) async {
    if (isInWatchlist) {
      await _databaseService.removeFromWatchlist(userId, movie.title);
      return false;
    }
    await _databaseService.addToWatchlist(userId, movie);
    return true;
  }
}
