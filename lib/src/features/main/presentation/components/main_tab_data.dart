part of '../main_tab_screen.dart';

enum _MainTab { home, search, watchlist, settings }

class _HomeMovieCollections {
  const _HomeMovieCollections({
    required this.latest,
    required this.trending,
    required this.topRated,
    required this.action,
    required this.rewatch,
    required this.fromApi,
  });

  final List<MovieView> latest;
  final List<MovieView> trending;
  final List<MovieView> topRated;
  final List<MovieView> action;
  final List<MovieView> rewatch;
  final bool fromApi;

  factory _HomeMovieCollections.fallback() {
    return _HomeMovieCollections(
      latest: _latestMovies,
      trending: _trendingMovies,
      topRated: _topRatedMovies,
      action: _actionMovies,
      rewatch: _rewatchMovies,
      fromApi: false,
    );
  }
}

final _homeMovieCollectionsProvider = FutureProvider<_HomeMovieCollections>((
  ref,
) async {
  final client = ref.read(tmdbApiClientProvider);
  final latest = await client.nowPlayingMovies();
  final trending = await client.popularMovies();
  final topRated = await client.topRatedMovies();
  final action = await client.genreMovies(genreId: 28);

  final latestMovies = _dedupeMovies(latest.movies);
  final trendingMovies = _dedupeMovies(trending.movies);
  final topRatedMovies = _dedupeMovies(topRated.movies);
  final actionMovies = _dedupeMovies(action.movies);

  return _HomeMovieCollections(
    latest: latestMovies.isEmpty ? _latestMovies : latestMovies,
    trending: trendingMovies.isEmpty ? _trendingMovies : trendingMovies,
    topRated: topRatedMovies.isEmpty ? _topRatedMovies : topRatedMovies,
    action: actionMovies.isEmpty ? _actionMovies : actionMovies,
    rewatch: topRatedMovies.isEmpty ? _rewatchMovies : topRatedMovies,
    fromApi: true,
  );
});

List<MovieView> _dedupeMovies(List<MovieView> movies) {
  final seen = <String>{};
  return [
    for (final movie in movies)
      if (seen.add('${movie.tmdbId ?? movie.title}-${movie.year}')) movie,
  ];
}

class _RatingHistoryEntry {
  const _RatingHistoryEntry({required this.movie, required this.rating});

  final MovieView movie;
  final double rating;
}

const _marvelMovies = [
  MovieView(
    title: 'Deadpool & Wolverine',
    synopsis:
        'Wade Wilson is pulled back into action when his homeworld is threatened and he has to convince a reluctant Wolverine to help.',
    rating: 4.6,
    genres: ['SUPERHERO', 'ACTION', 'COMEDY'],
    palette: [Color(0xFFE4C441), Color(0xFFD92929), Color(0xFF1B1B1B)],
    year: 2024,
    posterUrl:
        'https://cdn.marvel.com/content/2x/deadpoolandwolverine_lob_crd_03.jpg',
    trailerUrl: 'https://www.youtube.com/watch?v=73_1biulkYk',
  ),
  MovieView(
    title: 'Iron Man',
    synopsis:
        'Tony Stark escapes captivity by building a high-tech suit of armor, then uses it to confront a global threat tied to his own weapons.',
    rating: 4.0,
    genres: ['SUPERHERO', 'ACTION', 'SCI-FI'],
    palette: [Color(0xFFB51F1A), Color(0xFFE3B23C), Color(0xFF132033)],
    year: 2008,
    posterUrl: 'https://cdn.marvel.com/content/2x/ironman_lob_crd_01_4.jpg',
    trailerUrl: 'https://www.youtube.com/watch?v=8ugaeA-nMTc',
  ),
  MovieView(
    title: 'The Avengers',
    synopsis:
        'Nick Fury assembles Iron Man, Captain America, Thor, Hulk, Hawkeye, and Black Widow when a sudden enemy threatens global security.',
    rating: 4.0,
    genres: ['SUPERHERO', 'ACTION', 'ADVENTURE'],
    palette: [Color(0xFF254C6A), Color(0xFFB72222), Color(0xFFD7DDE6)],
    year: 2012,
    posterUrl: 'https://cdn.marvel.com/content/2x/theavengers_lob_crd_03_0.jpg',
    trailerUrl: 'https://www.youtube.com/watch?v=eOrNdBpGMv8',
  ),
  MovieView(
    title: 'Guardians of the Galaxy',
    synopsis:
        'Peter Quill steals a mysterious orb and forms an uneasy alliance with a crew of misfits to stop a cosmic threat.',
    rating: 4.0,
    genres: ['SUPERHERO', 'SCI-FI', 'ADVENTURE'],
    palette: [Color(0xFF6033B8), Color(0xFFE8572E), Color(0xFF1F2A3D)],
    year: 2014,
    posterUrl:
        'https://cdn.marvel.com/content/2x/guardiansofthegalaxy_lob_crd_03_0.jpg',
    trailerUrl: 'https://www.youtube.com/watch?v=d96cjJhvlMA',
  ),
  MovieView(
    title: 'Doctor Strange',
    synopsis:
        'After a devastating accident, Stephen Strange discovers Kamar-Taj and must choose between his old life and defending reality.',
    rating: 3.8,
    genres: ['SUPERHERO', 'FANTASY', 'ACTION'],
    palette: [Color(0xFFE76F22), Color(0xFF2A4D8F), Color(0xFF7D2D89)],
    year: 2016,
    posterUrl:
        'https://cdn.marvel.com/content/2x/doctorstrange_lob_crd_01_7.jpg',
    trailerUrl: 'https://www.youtube.com/watch?v=Lt-U_t2pUHI',
  ),
  MovieView(
    title: 'Thor: Ragnarok',
    synopsis:
        'Thor races back to Asgard to stop Hela and Ragnarok, but first he has to survive a gladiator fight against Hulk.',
    rating: 4.0,
    genres: ['SUPERHERO', 'ACTION', 'COMEDY'],
    palette: [Color(0xFFFF7A1A), Color(0xFF1FAF8E), Color(0xFF21255C)],
    year: 2017,
    posterUrl:
        'https://cdn.marvel.com/content/2x/thorragnarok_lob_crd_03_0.jpg',
    trailerUrl: 'https://www.youtube.com/watch?v=ue80QwXMRHg',
  ),
  MovieView(
    title: 'Black Panther',
    synopsis:
        'T\'Challa returns to Wakanda to become king, then faces an old enemy whose challenge could endanger his nation and the world.',
    rating: 3.7,
    genres: ['SUPERHERO', 'ACTION', 'ADVENTURE'],
    palette: [Color(0xFF243B69), Color(0xFF0F172A), Color(0xFF8FD3FF)],
    year: 2018,
    posterUrl:
        'https://cdn.marvel.com/content/2x/blackpanther_lob_crd_01_5.jpg',
    trailerUrl: 'https://www.youtube.com/watch?v=xjDjIWPwcPU',
  ),
  MovieView(
    title: 'Avengers: Infinity War',
    synopsis:
        'The Avengers and their allies face Thanos, who is hunting the six Infinity Stones to impose his will on all reality.',
    rating: 4.2,
    genres: ['SUPERHERO', 'ACTION', 'SCI-FI'],
    palette: [Color(0xFFE06724), Color(0xFF59256D), Color(0xFF1B1D35)],
    year: 2018,
    posterUrl:
        'https://cdn.marvel.com/content/2x/avengersinfinitywar_lob_crd_02.jpg',
    trailerUrl: 'https://www.youtube.com/watch?v=6ZfuNTqbHE8',
  ),
  MovieView(
    title: 'Avengers: Endgame',
    synopsis:
        'After Thanos fractures the universe and the Avengers, the remaining heroes gather for one final stand.',
    rating: 4.2,
    genres: ['SUPERHERO', 'ACTION', 'DRAMA'],
    palette: [Color(0xFF7447E0), Color(0xFF111827), Color(0xFFE84D8A)],
    year: 2019,
    posterUrl:
        'https://cdn.marvel.com/content/2x/avengersendgame_lob_crd_05.jpg',
    trailerUrl: 'https://www.youtube.com/watch?v=TcMBFSGVi1c',
  ),
  MovieView(
    title: 'Shang-Chi and the Legend of the Ten Rings',
    synopsis:
        'Shang-Chi is drawn into the Ten Rings organization and forced to confront the past he tried to leave behind.',
    rating: 3.7,
    genres: ['SUPERHERO', 'ACTION', 'ADVENTURE'],
    palette: [Color(0xFFE49A27), Color(0xFF9C1F18), Color(0xFF293648)],
    year: 2021,
    posterUrl: 'https://cdn.marvel.com/content/2x/shangchi_lob_crd_07.jpg',
    trailerUrl: 'https://www.youtube.com/watch?v=8YjFbMbfXaQ',
  ),
];

final _latestMovies = List<MovieView>.unmodifiable(
  [..._marvelMovies]..sort((a, b) => b.year.compareTo(a.year)),
);
const _trendingMovies = _marvelMovies;
final _topRatedMovies = List<MovieView>.unmodifiable(
  [..._marvelMovies]..sort((a, b) => b.rating.compareTo(a.rating)),
);
final _actionMovies = List<MovieView>.unmodifiable(
  _marvelMovies
      .where((movie) => movie.genres.contains('ACTION'))
      .toList(growable: false),
);
final _rewatchMovies = List<MovieView>.unmodifiable(
  _marvelMovies.where((movie) => movie.year < 2018).toList(growable: false),
);
const _defaultProfileBio = 'Probably watching a movie rn.🍿';
