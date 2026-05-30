import 'package:flutter/cupertino.dart';

/// Fallback gradient used when a movie has no artwork (e.g. API posters that
/// fail to load). Mirrors the original local-data look.
const List<Color> kDefaultMoviePalette = [
  Color(0xFF3A3A3A),
  Color(0xFFDC2626),
  Color(0xFF1B1B1B),
];

const List<String> kDefaultStreamingPlatforms = [
  'Disney+',
  'Prime Video',
  'Apple TV',
];

const List<MovieCastCredit> kDefaultMovieCast = [
  MovieCastCredit(name: 'Maya Chen', roleName: 'Lead'),
  MovieCastCredit(name: 'Jonas Reed', roleName: 'Supporting'),
  MovieCastCredit(name: 'Elena Park', roleName: 'Director'),
];

const List<MovieReviewSnippet> kDefaultMovieReviews = [
  MovieReviewSnippet(
    authorName: 'Cinerate',
    rating: 4.4,
    quote: 'A polished pick with enough momentum for movie night.',
  ),
  MovieReviewSnippet(
    authorName: 'Audience',
    rating: 4.1,
    quote: 'Strong pacing, memorable moments, and a clean rewatch value.',
  ),
];

class MovieCastCredit {
  const MovieCastCredit({required this.name, required this.roleName});

  final String name;
  final String roleName;

  factory MovieCastCredit.fromJson(Map<String, Object?> json) {
    return MovieCastCredit(
      name: json['name'] as String? ?? '',
      roleName: json['roleName'] as String? ?? '',
    );
  }

  Map<String, Object?> toJson() {
    return {'name': name, 'roleName': roleName};
  }
}

class MovieReviewSnippet {
  const MovieReviewSnippet({
    required this.authorName,
    required this.rating,
    required this.quote,
  });

  final String authorName;
  final double rating;
  final String quote;

  factory MovieReviewSnippet.fromJson(Map<String, Object?> json) {
    return MovieReviewSnippet(
      authorName: json['authorName'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      quote: json['quote'] as String? ?? '',
    );
  }

  Map<String, Object?> toJson() {
    return {'authorName': authorName, 'rating': rating, 'quote': quote};
  }
}

/// View model rendered by every movie surface (home, search, dialogs).
///
/// It is intentionally presentation-shaped: ratings are on a 0–5 scale and
/// [palette] drives the placeholder artwork.
class MovieView {
  const MovieView({
    required this.title,
    required this.synopsis,
    required this.rating,
    required this.genres,
    this.palette = kDefaultMoviePalette,
    this.year = 2025,
    this.runtimeMinutes = 124,
    this.ageRating = 'PG-13',
    this.streamingPlatforms = kDefaultStreamingPlatforms,
    this.cast = kDefaultMovieCast,
    this.reviews = kDefaultMovieReviews,
    this.posterUrl,
    this.trailerUrl,
    this.tmdbId,
  });

  final String title;
  final String synopsis;
  final double rating;
  final List<String> genres;
  final List<Color> palette;
  final int year;
  final int runtimeMinutes;
  final String ageRating;
  final List<String> streamingPlatforms;
  final List<MovieCastCredit> cast;
  final List<MovieReviewSnippet> reviews;
  final String? posterUrl;
  final String? trailerUrl;

  /// TheMovieDB movie id, set only for API-sourced movies. Used to look
  /// up a trailer on demand; null for the bundled local data.
  final int? tmdbId;

  MovieView copyWith({
    String? title,
    String? synopsis,
    double? rating,
    List<String>? genres,
    List<Color>? palette,
    int? year,
    int? runtimeMinutes,
    String? ageRating,
    List<String>? streamingPlatforms,
    List<MovieCastCredit>? cast,
    List<MovieReviewSnippet>? reviews,
    String? posterUrl,
    String? trailerUrl,
    int? tmdbId,
  }) {
    return MovieView(
      title: title ?? this.title,
      synopsis: synopsis ?? this.synopsis,
      rating: rating ?? this.rating,
      genres: genres ?? this.genres,
      palette: palette ?? this.palette,
      year: year ?? this.year,
      runtimeMinutes: runtimeMinutes ?? this.runtimeMinutes,
      ageRating: ageRating ?? this.ageRating,
      streamingPlatforms: streamingPlatforms ?? this.streamingPlatforms,
      cast: cast ?? this.cast,
      reviews: reviews ?? this.reviews,
      posterUrl: posterUrl ?? this.posterUrl,
      trailerUrl: trailerUrl ?? this.trailerUrl,
      tmdbId: tmdbId ?? this.tmdbId,
    );
  }
}
