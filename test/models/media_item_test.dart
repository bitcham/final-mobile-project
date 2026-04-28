import 'package:movie_rating/models/media_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MediaItem', () {
    test('parses media item data from JSON', () {
      final mediaItem = MediaItem.fromJson({
        'id': 'trailer-1',
        'title': 'Official Trailer',
        'type': 'trailer',
        'thumbnailAsset': 'assets/images/neon_horizon_trailer.jpg',
        'url': 'https://example.com/trailer',
      });

      expect(mediaItem.id, 'trailer-1');
      expect(mediaItem.title, 'Official Trailer');
      expect(mediaItem.type, 'trailer');
      expect(
        mediaItem.thumbnailAsset,
        'assets/images/neon_horizon_trailer.jpg',
      );
      expect(mediaItem.url, 'https://example.com/trailer');
    });

    test('serializes to the movies.json media item key shape', () {
      const mediaItem = MediaItem(
        id: 'trailer-1',
        title: 'Official Trailer',
        type: 'trailer',
        thumbnailAsset: 'assets/images/neon_horizon_trailer.jpg',
        url: 'https://example.com/trailer',
      );

      expect(mediaItem.toJson(), {
        'id': 'trailer-1',
        'title': 'Official Trailer',
        'type': 'trailer',
        'thumbnailAsset': 'assets/images/neon_horizon_trailer.jpg',
        'url': 'https://example.com/trailer',
      });
    });

    test('defaults missing values to empty strings', () {
      final mediaItem = MediaItem.fromJson({});

      expect(mediaItem.id, '');
      expect(mediaItem.title, '');
      expect(mediaItem.type, '');
      expect(mediaItem.thumbnailAsset, '');
      expect(mediaItem.url, '');
    });
  });
}
