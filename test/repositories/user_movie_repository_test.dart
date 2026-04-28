import 'package:movie_rating/repositories/user_movie_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/movie_json.dart';

void main() {
  UserMovieRepository buildRepository() {
    return UserMovieRepository(loadAsset: (_) async => movieJson);
  }

  group('UserMovieRepository', () {
    test('fetchUserMovieEntries returns profile data', () async {
      final repository = buildRepository();

      final entries = await repository.fetchUserMovieEntries();

      expect(entries.length, 2);
      expect(entries.first.movieId, 'neon-horizon');
      expect(entries.first.inWatchlist, isTrue);
    });

    test('findByMovieId returns one profile entry', () async {
      final repository = buildRepository();

      final entry = await repository.findByMovieId('neon-horizon');

      expect(entry?.userRating, 5.0);
    });

    test('fetchWatchlistEntries returns only watchlist entries', () async {
      final repository = buildRepository();

      final entries = await repository.fetchWatchlistEntries();

      expect(entries.map((entry) => entry.movieId), [
        'neon-horizon',
        'quantum-leap',
      ]);
    });

    test('fetchRatedEntries returns only rated entries', () async {
      final repository = buildRepository();

      final entries = await repository.fetchRatedEntries();

      expect(entries.map((entry) => entry.movieId), ['neon-horizon']);
    });

    test('fetchWatchlistMovies combines movies with profile entries', () async {
      final repository = buildRepository();

      final movies = await repository.fetchWatchlistMovies();

      expect(movies.map((movie) => movie.id), ['neon-horizon', 'quantum-leap']);
    });

    test(
      'fetchRatedMovies combines movies with rated profile entries',
      () async {
        final repository = buildRepository();

        final movies = await repository.fetchRatedMovies();

        expect(movies.map((movie) => movie.id), ['neon-horizon']);
      },
    );
  });
}
