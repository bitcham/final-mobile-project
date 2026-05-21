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
  }) {
    return _getPage('/3/discover/movie', {
      'page': '$page',
      'include_adult': 'false',
      'sort_by': sortByRating ? 'vote_average.desc' : 'popularity.desc',
      if (sortByRating) 'vote_count.gte': '200',
      if (minRating > 0) 'vote_average.gte': '${minRating * 2}',
      if (year != null) 'primary_release_year': '$year',
    });
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
