import 'package:movie_rating/models/review.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Review', () {
    test('parses review data from JSON', () {
      final review = Review.fromJson({
        'id': 'review-1',
        'authorName': 'John Doe',
        'rating': 4.5,
        'content': 'A visually stunning movie.',
      });

      expect(review.id, 'review-1');
      expect(review.authorName, 'John Doe');
      expect(review.rating, 4.5);
      expect(review.content, 'A visually stunning movie.');
    });

    test('converts integer ratings to double when parsing JSON', () {
      final review = Review.fromJson({
        'id': 'review-1',
        'authorName': 'John Doe',
        'rating': 4,
        'content': 'A strong watch.',
      });

      expect(review.rating, 4.0);
    });

    test('serializes to the movies.json review key shape', () {
      const review = Review(
        id: 'review-1',
        authorName: 'John Doe',
        rating: 4.5,
        content: 'A visually stunning movie.',
      );

      expect(review.toJson(), {
        'id': 'review-1',
        'authorName': 'John Doe',
        'rating': 4.5,
        'content': 'A visually stunning movie.',
      });
    });

    test('defaults missing values to empty strings and zero rating', () {
      final review = Review.fromJson({});

      expect(review.id, '');
      expect(review.authorName, '');
      expect(review.rating, 0);
      expect(review.content, '');
    });
  });
}
