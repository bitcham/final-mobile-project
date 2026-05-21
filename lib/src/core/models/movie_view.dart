import 'package:flutter/cupertino.dart';

/// Fallback gradient used when a movie has no artwork (e.g. API posters that
/// fail to load). Mirrors the original local-data look.
const List<Color> kDefaultMoviePalette = [
  Color(0xFF3A3A3A),
  Color(0xFFDC2626),
  Color(0xFF1B1B1B),
];

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
  final String? posterUrl;
  final String? trailerUrl;

  /// TheMovieDB movie id, set only for API-sourced movies. Used to look
  /// up a trailer on demand; null for the bundled local data.
  final int? tmdbId;

  MovieView copyWith({String? trailerUrl}) {
    return MovieView(
      title: title,
      synopsis: synopsis,
      rating: rating,
      genres: genres,
      palette: palette,
      year: year,
      posterUrl: posterUrl,
      trailerUrl: trailerUrl ?? this.trailerUrl,
      tmdbId: tmdbId,
    );
  }
}
