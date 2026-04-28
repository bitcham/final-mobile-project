import 'package:movie_rating/models/user_movie_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserMovieEntry', () {
    test('parses profile movie data from JSON', () {
      final entry = UserMovieEntry.fromJson({
        'movieId': 'neon-horizon',
        'userRating': 5,
        'inWatchlist': true,
        'watchedAt': '2026-04-28',
      });

      expect(entry.movieId, 'neon-horizon');
      expect(entry.userRating, 5.0);
      expect(entry.inWatchlist, isTrue);
      expect(entry.watchedAt, '2026-04-28');
    });

    test('serializes to the movies.json user movie entry key shape', () {
      const entry = UserMovieEntry(
        movieId: 'neon-horizon',
        userRating: 5,
        inWatchlist: true,
        watchedAt: '2026-04-28',
      );

      expect(entry.toJson(), {
        'movieId': 'neon-horizon',
        'userRating': 5.0,
        'inWatchlist': true,
        'watchedAt': '2026-04-28',
      });
    });

    test('defaults missing values to safe profile defaults', () {
      final entry = UserMovieEntry.fromJson({});

      expect(entry.movieId, '');
      expect(entry.userRating, 0);
      expect(entry.inWatchlist, isFalse);
      expect(entry.watchedAt, '');
    });
  });
}
