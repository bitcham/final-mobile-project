import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:movie_rating/src/core/models/movie_view.dart';

class TmdbPage {
  const TmdbPage({
    required this.movies,
    required this.page,
    required this.totalPages,
  });

  final List<MovieView> movies;
  final int page;
  final int totalPages;
}

class TmdbException implements Exception {
  const TmdbException(this.message);

  final String message;

  @override
  String toString() => 'TmdbException: $message';
}

class TmdbApiClient {
  TmdbApiClient({http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  final http.Client _http;

  static const _host = 'api.themoviedb.org';
  static const _imageBase = 'https://image.tmdb.org/t/p/w500';

  String get _readToken =>
      (dotenv.maybeGet('TMDB_API_READ_ACCESS_TOKEN') ?? '').trim();

  String get _apiKey => (dotenv.maybeGet('TMDB_API_KEY') ?? '').trim();

  String get _watchRegion {
    final region = (dotenv.maybeGet('TMDB_WATCH_REGION') ?? 'DE').trim();
    return region.isEmpty ? 'DE' : region.toUpperCase();
  }

  bool get _usesBearer =>
      _readToken.isNotEmpty && _readToken != 'YOUR_API_READ_ACCESS_TOKEN_HERE';

  bool get _hasCredentials =>
      _usesBearer || (_apiKey.isNotEmpty && _apiKey != 'YOUR_API_KEY_HERE');

  Future<TmdbPage> searchMovies({
    required String query,
    int page = 1,
    int? year,
  }) {
    return _getPage('/3/search/movie', {
      'query': query,
      'page': '$page',
      'include_adult': 'false',
      if (year != null) 'primary_release_year': '$year',
    });
  }

  Future<TmdbPage> discoverMovies({
    int page = 1,
    int? year,
    double minRating = 0.0,
    bool sortByRating = false,
    int? genreId,
  }) {
    return _getPage('/3/discover/movie', {
      'page': '$page',
      'include_adult': 'false',
      'sort_by': sortByRating ? 'vote_average.desc' : 'popularity.desc',
      if (sortByRating) 'vote_count.gte': '200',
      if (minRating > 0) 'vote_average.gte': '${minRating * 2}',
      if (year != null) 'primary_release_year': '$year',
      if (genreId != null) 'with_genres': '$genreId',
    });
  }

  Future<TmdbPage> nowPlayingMovies({int page = 1}) {
    return _getPage('/3/movie/now_playing', {
      'page': '$page',
      'include_adult': 'false',
    });
  }

  Future<TmdbPage> popularMovies({int page = 1}) {
    return discoverMovies(page: page);
  }

  Future<TmdbPage> topRatedMovies({int page = 1}) {
    return _getPage('/3/movie/top_rated', {
      'page': '$page',
      'include_adult': 'false',
    });
  }

  Future<TmdbPage> genreMovies({required int genreId, int page = 1}) {
    return discoverMovies(page: page, genreId: genreId);
  }

  Future<Map<String, dynamic>> _getJson(
    String path,
    Map<String, String> queryParameters,
  ) async {
    if (!_hasCredentials) {
      throw const TmdbException(
        'Add your TheMovieDB keys to the .env file to load movies.',
      );
    }

    final params = <String, String>{...queryParameters, 'language': 'en-US'};
    if (!_usesBearer) {
      params['api_key'] = _apiKey;
    }
    final uri = Uri.https(_host, path, params);

    final http.Response response;
    try {
      response = await _http.get(
        uri,
        headers: _usesBearer
            ? {'Authorization': 'Bearer $_readToken'}
            : const {},
      );
    } catch (error) {
      throw TmdbException('Could not reach TheMovieDB ($error).');
    }

    if (response.statusCode != 200) {
      throw TmdbException(
        'TheMovieDB request failed (${response.statusCode}).',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<TmdbPage> _getPage(
    String path,
    Map<String, String> queryParameters,
  ) async {
    final body = await _getJson(path, queryParameters);
    final results = (body['results'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .map(_mapMovie)
        .toList(growable: false);

    return TmdbPage(
      movies: results,
      page: (body['page'] as num?)?.toInt() ?? 1,
      totalPages: (body['total_pages'] as num?)?.toInt() ?? 1,
    );
  }

  Future<String?> fetchTrailerUrl(int movieId) async {
    final Map<String, dynamic> body;
    try {
      body = await _getJson('/3/movie/$movieId/videos', const {});
    } on TmdbException {
      return null;
    }

    return _trailerUrlFromVideos(body);
  }

  Future<MovieView> fetchMovieDetails(MovieView movie) async {
    final movieId = movie.tmdbId;
    if (movieId == null) {
      return movie;
    }

    final Map<String, dynamic> body;
    try {
      body = await _getJson('/3/movie/$movieId', const {
        'append_to_response':
            'watch/providers,credits,reviews,videos,release_dates',
      });
    } on TmdbException {
      return movie;
    }

    return _mapMovieDetails(movie, body);
  }

  String? _trailerUrlFromVideos(Map<String, dynamic> body) {
    final videos = (body['results'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .where((v) => v['site'] == 'YouTube' && v['key'] is String)
        .toList();
    if (videos.isEmpty) {
      return null;
    }

    final preferred = videos.firstWhere(
      (v) => v['type'] == 'Trailer' && v['official'] == true,
      orElse: () => videos.firstWhere(
        (v) => v['type'] == 'Trailer',
        orElse: () => videos.first,
      ),
    );
    return 'https://www.youtube.com/watch?v=${preferred['key']}';
  }

  MovieView _mapMovieDetails(MovieView movie, Map<String, dynamic> json) {
    final posterPath = json['poster_path'] as String?;
    final overview = (json['overview'] as String?)?.trim();
    final voteAverage = (json['vote_average'] as num?)?.toDouble();
    final genres = (json['genres'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((genre) => (genre['name'] as String?)?.trim().toUpperCase())
        .whereType<String>()
        .where((genre) => genre.isNotEmpty)
        .toList(growable: false);
    final runtime = (json['runtime'] as num?)?.toInt();
    final releaseDate = (json['release_date'] as String?) ?? '';
    final year = releaseDate.length >= 4
        ? int.tryParse(releaseDate.substring(0, 4))
        : null;
    final streamingPlatforms = _watchProviderNames(json['watch/providers']);
    final cast = _castCredits(json['credits']);
    final reviews = _reviewSnippets(json['reviews'], movie.rating);
    final trailerUrl =
        _trailerUrlFromVideos(json['videos'] as Map<String, dynamic>? ?? {}) ??
        movie.trailerUrl;

    return movie.copyWith(
      synopsis: overview == null || overview.isEmpty ? null : overview,
      rating: voteAverage == null ? null : (voteAverage / 2 * 10).round() / 10,
      genres: genres.isEmpty ? null : genres,
      year: year,
      runtimeMinutes: runtime == null || runtime <= 0 ? null : runtime,
      ageRating: _certification(json['release_dates']) ?? movie.ageRating,
      streamingPlatforms: streamingPlatforms.isEmpty
          ? null
          : streamingPlatforms,
      cast: cast.isEmpty ? null : cast,
      reviews: reviews.isEmpty ? null : reviews,
      posterUrl: posterPath == null ? null : '$_imageBase$posterPath',
      trailerUrl: trailerUrl,
    );
  }

  List<String> _watchProviderNames(Object? providers) {
    if (providers is! Map<String, dynamic>) {
      return const [];
    }
    final results = providers['results'];
    if (results is! Map<String, dynamic>) {
      return const [];
    }

    final regionEntry = results[_watchRegion] ?? results['US'] ?? results['DE'];
    if (regionEntry is! Map<String, dynamic>) {
      return const [];
    }

    final names = <String>{};
    for (final bucket in const ['flatrate', 'free', 'ads', 'rent', 'buy']) {
      final providers = regionEntry[bucket];
      if (providers is! List<dynamic>) {
        continue;
      }
      for (final provider in providers) {
        if (provider is! Map<String, dynamic>) {
          continue;
        }
        final name = (provider['provider_name'] as String?)?.trim();
        if (name != null && name.isNotEmpty) {
          names.add(name);
        }
      }
    }
    return names.take(6).toList(growable: false);
  }

  List<MovieCastCredit> _castCredits(Object? credits) {
    if (credits is! Map<String, dynamic>) {
      return const [];
    }

    final cast = credits['cast'];
    if (cast is! List<dynamic>) {
      return const [];
    }

    return cast
        .whereType<Map<String, dynamic>>()
        .map((person) {
          final name = (person['name'] as String?)?.trim();
          if (name == null || name.isEmpty) {
            return null;
          }
          final character = (person['character'] as String?)?.trim();
          return MovieCastCredit(
            name: name,
            roleName: character == null || character.isEmpty
                ? 'Cast'
                : character,
          );
        })
        .whereType<MovieCastCredit>()
        .take(8)
        .toList(growable: false);
  }

  List<MovieReviewSnippet> _reviewSnippets(
    Object? reviews,
    double fallbackRating,
  ) {
    if (reviews is! Map<String, dynamic>) {
      return const [];
    }

    final results = reviews['results'];
    if (results is! List<dynamic>) {
      return const [];
    }

    return results
        .whereType<Map<String, dynamic>>()
        .map((review) {
          final author = (review['author'] as String?)?.trim();
          final content = _compactText(review['content'] as String?);
          if (author == null || author.isEmpty || content.isEmpty) {
            return null;
          }
          final authorDetails = review['author_details'];
          final rawRating = authorDetails is Map<String, dynamic>
              ? (authorDetails['rating'] as num?)?.toDouble()
              : null;
          return MovieReviewSnippet(
            authorName: author,
            rating: rawRating == null
                ? fallbackRating
                : ((rawRating / 2).clamp(0.0, 5.0) * 10).round() / 10,
            quote: _truncate(content, 180),
          );
        })
        .whereType<MovieReviewSnippet>()
        .take(3)
        .toList(growable: false);
  }

  String? _certification(Object? releaseDates) {
    if (releaseDates is! Map<String, dynamic>) {
      return null;
    }
    final results = releaseDates['results'];
    if (results is! List<dynamic>) {
      return null;
    }

    Map<String, dynamic>? regionData;
    for (final region in [_watchRegion, 'US', 'DE']) {
      regionData = results.whereType<Map<String, dynamic>>().firstWhere(
        (entry) => entry['iso_3166_1'] == region,
        orElse: () => const {},
      );
      if (regionData.isNotEmpty) {
        break;
      }
    }
    if (regionData == null || regionData.isEmpty) {
      for (final entry in results.whereType<Map<String, dynamic>>()) {
        regionData = entry;
        break;
      }
    }
    final dates = regionData?['release_dates'];
    if (dates is! List<dynamic>) {
      return null;
    }
    for (final date in dates.whereType<Map<String, dynamic>>()) {
      final certification = (date['certification'] as String?)?.trim();
      if (certification != null && certification.isNotEmpty) {
        return certification;
      }
    }
    return null;
  }

  String _compactText(String? value) {
    return (value ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _truncate(String value, int maxLength) {
    if (value.length <= maxLength) {
      return value;
    }
    return '${value.substring(0, maxLength - 1).trimRight()}...';
  }

  MovieView _mapMovie(Map<String, dynamic> json) {
    final posterPath = json['poster_path'] as String?;
    final voteAverage = (json['vote_average'] as num?)?.toDouble() ?? 0.0;
    final releaseDate = (json['release_date'] as String?) ?? '';
    final year = releaseDate.length >= 4
        ? int.tryParse(releaseDate.substring(0, 4)) ?? 0
        : 0;
    final genreIds = (json['genre_ids'] as List<dynamic>? ?? [])
        .cast<num>()
        .map((id) => _genreNames[id.toInt()])
        .whereType<String>()
        .toList(growable: false);

    return MovieView(
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? json['title'] as String
          : 'Untitled',
      synopsis: (json['overview'] as String?)?.trim().isNotEmpty == true
          ? json['overview'] as String
          : 'No description available.',
      rating: (voteAverage / 2 * 10).round() / 10,
      genres: genreIds,
      year: year,
      posterUrl: posterPath == null ? null : '$_imageBase$posterPath',
      tmdbId: (json['id'] as num?)?.toInt(),
    );
  }

  static const Map<int, String> _genreNames = {
    28: 'ACTION',
    12: 'ADVENTURE',
    16: 'ANIMATION',
    35: 'COMEDY',
    80: 'CRIME',
    99: 'DOCUMENTARY',
    18: 'DRAMA',
    10751: 'FAMILY',
    14: 'FANTASY',
    36: 'HISTORY',
    27: 'HORROR',
    10402: 'MUSIC',
    9648: 'MYSTERY',
    10749: 'ROMANCE',
    878: 'SCI-FI',
    10770: 'TV MOVIE',
    53: 'THRILLER',
    10752: 'WAR',
    37: 'WESTERN',
  };
}
