import 'package:movie_rating/repositories/movie_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/movie_json.dart';

void main() {
  MovieRepository buildRepository() {
    return MovieRepository(loadAsset: (_) async => movieJson);
  }

  group('MovieRepository', () {
    test('fetchMoviesPage returns paged movies', () async {
      final repository = buildRepository();

      final firstPage = await repository.fetchMoviesPage(page: 1, pageSize: 2);
      final secondPage = await repository.fetchMoviesPage(page: 2, pageSize: 2);
      final emptyPage = await repository.fetchMoviesPage(page: 3, pageSize: 2);

      expect(firstPage.map((movie) => movie.id), [
        'neon-horizon',
        'the-long-walk',
      ]);
      expect(secondPage.single.id, 'quantum-leap');
      expect(emptyPage, isEmpty);
    });

    test('fetchMoviesPage can filter by category before paging', () async {
      final repository = buildRepository();

      final movies = await repository.fetchMoviesPage(
        page: 1,
        pageSize: 10,
        category: 'nowPlaying',
      );

      expect(movies.map((movie) => movie.id), [
        'neon-horizon',
        'the-long-walk',
      ]);
    });

    test('findById returns a movie by stable slug id', () async {
      final repository = buildRepository();

      final movie = await repository.findById('quantum-leap');

      expect(movie?.title, 'Quantum Leap');
    });

    test('searchMovies matches title and genres case-insensitively', () async {
      final repository = buildRepository();

      final titleResults = await repository.searchMovies('horizon');
      final genreResults = await repository.searchMovies('SCI-fi');

      expect(titleResults.single.id, 'neon-horizon');
      expect(genreResults.map((movie) => movie.id), [
        'neon-horizon',
        'quantum-leap',
      ]);
    });
  });
}
