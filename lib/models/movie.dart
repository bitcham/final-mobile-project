import 'cast_member.dart';
import 'media_item.dart';
import 'review.dart';

class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.synopsis,
    required this.releaseYear,
    required this.runtimeMinutes,
    required this.rating,
    required this.ageRating,
    required this.posterAsset,
    required this.backdropAsset,
    required this.trailerUrl,
    required this.category,
    required this.genres,
    required this.cast,
    required this.reviews,
    required this.mediaItems,
  });

  final String id;
  final String title;
  final String synopsis;
  final int releaseYear;
  final int runtimeMinutes;
  final double rating;
  final String ageRating;
  final String posterAsset;
  final String backdropAsset;
  final String trailerUrl;
  final String category;
  final List<String> genres;
  final List<CastMember> cast;
  final List<Review> reviews;
  final List<MediaItem> mediaItems;

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      synopsis: json['synopsis'] as String? ?? '',
      releaseYear: (json['releaseYear'] as num?)?.toInt() ?? 0,
      runtimeMinutes: (json['runtimeMinutes'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      ageRating: json['ageRating'] as String? ?? '',
      posterAsset: json['posterAsset'] as String? ?? '',
      backdropAsset: json['backdropAsset'] as String? ?? '',
      trailerUrl: json['trailerUrl'] as String? ?? '',
      category: json['category'] as String? ?? '',
      genres: _stringList(json['genres']),
      cast: _objectList(json['cast'], CastMember.fromJson),
      reviews: _objectList(json['reviews'], Review.fromJson),
      mediaItems: _objectList(json['mediaItems'], MediaItem.fromJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'synopsis': synopsis,
      'releaseYear': releaseYear,
      'runtimeMinutes': runtimeMinutes,
      'rating': rating,
      'ageRating': ageRating,
      'posterAsset': posterAsset,
      'backdropAsset': backdropAsset,
      'trailerUrl': trailerUrl,
      'category': category,
      'genres': genres,
      'cast': cast.map((member) => member.toJson()).toList(),
      'reviews': reviews.map((review) => review.toJson()).toList(),
      'mediaItems': mediaItems.map((item) => item.toJson()).toList(),
    };
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) {
      return const [];
    }

    return value.whereType<String>().toList();
  }

  static List<T> _objectList<T>(
    Object? value,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    if (value is! List) {
      return const [];
    }

    return value.whereType<Map<String, dynamic>>().map(fromJson).toList();
  }
}
