import 'package:movie_rating/models/movie.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Movie', () {
    test('parses primitive fields and nested lists from JSON', () {
      final movie = Movie.fromJson({
        'id': 'neon-horizon',
        'title': 'Neon Horizon',
        'synopsis': 'In a world where memories are currency...',
        'releaseYear': 2024,
        'runtimeMinutes': 165,
        'rating': 8.9,
        'ageRating': 'PG-13',
        'posterAsset': 'assets/images/neon_horizon_poster.jpg',
        'backdropAsset': 'assets/images/neon_horizon_backdrop.jpg',
        'trailerUrl': 'https://example.com/trailer',
        'category': 'nowPlaying',
        'genres': ['Sci-Fi', 'Thriller'],
        'cast': [
          {'id': 'elias-thorne', 'name': 'Elias Thorne', 'roleName': 'Kaelen'},
        ],
        'reviews': [
          {
            'id': 'review-1',
            'authorName': 'John Doe',
            'rating': 4.5,
            'content': 'A visually stunning movie.',
          },
        ],
        'mediaItems': [
          {
            'id': 'trailer-1',
            'title': 'Official Trailer',
            'type': 'trailer',
            'thumbnailAsset': 'assets/images/neon_horizon_trailer.jpg',
            'url': 'https://example.com/trailer',
          },
        ],
      });

      expect(movie.id, 'neon-horizon');
      expect(movie.title, 'Neon Horizon');
      expect(movie.releaseYear, 2024);
      expect(movie.runtimeMinutes, 165);
      expect(movie.rating, 8.9);
      expect(movie.genres, ['Sci-Fi', 'Thriller']);
      expect(movie.cast.single.name, 'Elias Thorne');
      expect(movie.reviews.single.authorName, 'John Doe');
      expect(movie.mediaItems.single.type, 'trailer');
    });

    test('serializes to the movies.json key shape without originalTitle', () {
      const movie = Movie(
        id: 'neon-horizon',
        title: 'Neon Horizon',
        synopsis: 'In a world where memories are currency...',
        releaseYear: 2024,
        runtimeMinutes: 165,
        rating: 8.9,
        ageRating: 'PG-13',
        posterAsset: 'assets/images/neon_horizon_poster.jpg',
        backdropAsset: 'assets/images/neon_horizon_backdrop.jpg',
        trailerUrl: 'https://example.com/trailer',
        category: 'nowPlaying',
        genres: ['Sci-Fi', 'Thriller'],
        cast: [],
        reviews: [],
        mediaItems: [],
      );

      final json = movie.toJson();

      expect(json.containsKey('originalTitle'), isFalse);
      expect(json, {
        'id': 'neon-horizon',
        'title': 'Neon Horizon',
        'synopsis': 'In a world where memories are currency...',
        'releaseYear': 2024,
        'runtimeMinutes': 165,
        'rating': 8.9,
        'ageRating': 'PG-13',
        'posterAsset': 'assets/images/neon_horizon_poster.jpg',
        'backdropAsset': 'assets/images/neon_horizon_backdrop.jpg',
        'trailerUrl': 'https://example.com/trailer',
        'category': 'nowPlaying',
        'genres': ['Sci-Fi', 'Thriller'],
        'cast': [],
        'reviews': [],
        'mediaItems': [],
      });
    });

    test('defaults missing optional lists to empty lists', () {
      final movie = Movie.fromJson({'id': 'void', 'title': 'Void'});

      expect(movie.genres, isEmpty);
      expect(movie.cast, isEmpty);
      expect(movie.reviews, isEmpty);
      expect(movie.mediaItems, isEmpty);
    });
  });
}
