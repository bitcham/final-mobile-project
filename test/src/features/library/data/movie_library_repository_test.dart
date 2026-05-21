import 'package:flutter_test/flutter_test.dart';
import 'package:movie_rating/src/core/models/movie_view.dart';
import 'package:movie_rating/src/features/library/data/movie_library_database_service.dart';
import 'package:movie_rating/src/features/library/data/movie_library_repository.dart';

const _ironMan = MovieView(
  title: 'Iron Man',
  synopsis: 'Tony Stark builds a suit.',
  rating: 4.0,
  genres: ['ACTION'],
  year: 2008,
);

const _avengers = MovieView(
  title: 'The Avengers',
  synopsis: 'Heroes assemble.',
  rating: 4.2,
  genres: ['ACTION'],
  year: 2012,
);

void main() {
  group('MovieLibraryRepository', () {
    late MovieLibraryRepository repository;

    setUp(() {
      repository = MovieLibraryRepository(
        databaseService: _FakeMovieLibraryDatabaseService(),
      );
    });

    test('keeps only the latest rating per movie', () async {
      await repository.rate(1, _ironMan, 3.0);
      await repository.rate(1, _ironMan, 4.5);

      final library = await repository.load(1);

      expect(library.ratings, {'Iron Man': 4.5});
      expect(library.ratedMovies.map((m) => m.title), ['Iron Man']);
    });

    test('orders rated movies most recent first', () async {
      await repository.rate(1, _ironMan, 3.0);
      await repository.rate(1, _avengers, 5.0);

      final library = await repository.load(1);

      expect(library.ratedMovies.map((m) => m.title), [
        'The Avengers',
        'Iron Man',
      ]);
    });

    test('toggles watchlist membership', () async {
      final added = await repository.toggleWatchlist(
        userId: 1,
        movie: _ironMan,
        isInWatchlist: false,
      );
      expect(added, isTrue);
      var library = await repository.load(1);
      expect(library.watchlistTitles, {'Iron Man'});
      expect(library.watchlistMovies.single.year, 2008);

      final stillThere = await repository.toggleWatchlist(
        userId: 1,
        movie: _ironMan,
        isInWatchlist: true,
      );
      expect(stillThere, isFalse);
      library = await repository.load(1);
      expect(library.watchlistTitles, isEmpty);
    });

    test('isolates libraries per user', () async {
      await repository.rate(1, _ironMan, 4.0);
      await repository.toggleWatchlist(
        userId: 1,
        movie: _ironMan,
        isInWatchlist: false,
      );

      final otherUser = await repository.load(2);

      expect(otherUser.ratings, isEmpty);
      expect(otherUser.watchlistTitles, isEmpty);
    });
  });
}

/// In-memory stand-in mirroring the SQLite semantics (latest-wins,
/// newest-first ordering, per-user isolation).
class _FakeMovieLibraryDatabaseService extends MovieLibraryDatabaseService {
  final Map<int, List<RatedMovie>> _ratings = {};
  final Map<int, List<MovieView>> _watchlist = {};

  @override
  Future<void> upsertRating(int userId, MovieView movie, double rating) async {
    final list = _ratings.putIfAbsent(userId, () => []);
    list.removeWhere((entry) => entry.movie.title == movie.title);
    list.insert(0, (movie: movie, rating: rating));
  }

  @override
  Future<List<RatedMovie>> fetchRatings(int userId) async {
    return List.of(_ratings[userId] ?? const []);
  }

  @override
  Future<void> addToWatchlist(int userId, MovieView movie) async {
    final list = _watchlist.putIfAbsent(userId, () => []);
    list.removeWhere((m) => m.title == movie.title);
    list.insert(0, movie);
  }

  @override
  Future<void> removeFromWatchlist(int userId, String movieTitle) async {
    _watchlist[userId]?.removeWhere((m) => m.title == movieTitle);
  }

  @override
  Future<List<MovieView>> fetchWatchlist(int userId) async {
    return List.of(_watchlist[userId] ?? const []);
  }
}
