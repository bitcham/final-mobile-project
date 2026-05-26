import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:movie_rating/src/core/models/movie_view.dart';
import 'package:movie_rating/src/core/theme/app_theme.dart';
import 'package:movie_rating/src/core/theme/cinerate_palette.dart';
import 'package:movie_rating/src/core/widgets/cinerate_logo.dart';
import 'package:movie_rating/src/core/widgets/movie_dialogs.dart';
import 'package:movie_rating/src/core/widgets/movie_widgets.dart';
import 'package:movie_rating/src/core/widgets/profile_avatar.dart';
import 'package:movie_rating/src/features/auth/models/app_user.dart';
import 'package:movie_rating/src/features/search/data/search_providers.dart';
import 'package:movie_rating/src/features/search/presentation/search_screen.dart';

import 'trailer_launcher.dart';

part 'components/main_tab_data.dart';
part 'components/home_tab.dart';
part 'components/settings_tab.dart';
part 'components/settings_widgets.dart';
part 'components/main_tab_dialogs.dart';
part 'components/watchlist_tab.dart';
part 'components/bottom_nav.dart';

typedef ProfileUpdateCallback = Future<AppUser> Function(String realName);
typedef PasswordChangeCallback =
    Future<bool> Function({
      required String currentPassword,
      required String newPassword,
    });
typedef TrailerLauncherCallback = Future<void> Function(Uri trailerUrl);

class MainTabScreen extends ConsumerStatefulWidget {
  const MainTabScreen({
    super.key,
    required this.user,
    this.onLogout,
    this.onUpdateProfile,
    this.onChangePassword,
    this.onOpenTrailer,
    this.initialRatings = const {},
    this.initialRatedMovies = const [],
    this.initialWatchlist = const [],
    this.onPersistRating,
    this.onPersistWatchlistToggle,
  });

  final AppUser user;
  final VoidCallback? onLogout;
  final ProfileUpdateCallback? onUpdateProfile;
  final PasswordChangeCallback? onChangePassword;
  final TrailerLauncherCallback? onOpenTrailer;
  final Map<String, double> initialRatings;
  final List<MovieView> initialRatedMovies;
  final List<MovieView> initialWatchlist;
  final Future<void> Function(MovieView movie, double rating)? onPersistRating;
  final Future<void> Function(MovieView movie)? onPersistWatchlistToggle;

  @override
  ConsumerState<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends ConsumerState<MainTabScreen> {
  _MainTab _tab = _MainTab.home;
  late AppUser _user = widget.user;
  bool _darkMode = true;
  late Map<String, double> _userMovieRatings;
  late Set<String> _watchlistMovieTitles;
  late List<MovieView> _watchlistMovies;
  late List<_RatingHistoryEntry> _ratingHistory;
  final Map<int, String?> _trailerCache = {};

  @override
  void initState() {
    super.initState();
    _seedLibrary();
  }

  void _seedLibrary() {
    _userMovieRatings = {...widget.initialRatings};
    _watchlistMovies = [...widget.initialWatchlist];
    _watchlistMovieTitles = {for (final movie in _watchlistMovies) movie.title};
    _ratingHistory = [
      for (final movie in widget.initialRatedMovies)
        _RatingHistoryEntry(
          movie: movie,
          rating: widget.initialRatings[movie.title] ?? movie.rating,
        ),
    ];
  }

  @override
  void didUpdateWidget(covariant MainTabScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user != widget.user) {
      _user = widget.user;
      if (oldWidget.user.id != widget.user.id) {
        _seedLibrary();
      }
    }
  }

  Future<AppUser> _updateProfile(String realName) async {
    final updater = widget.onUpdateProfile;
    final updated = updater == null
        ? _user.copyWith(realName: realName.trim())
        : await updater(realName.trim());
    if (mounted) {
      setState(() => _user = updated);
    }
    return updated;
  }

  Future<bool> _changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final changer = widget.onChangePassword;
    if (changer == null) {
      return true;
    }
    return changer(currentPassword: currentPassword, newPassword: newPassword);
  }

  Future<void> _openTrailer(MovieView movie) async {
    var trailerUrl = movie.trailerUrl;
    final tmdbId = movie.tmdbId;
    if (trailerUrl == null && tmdbId != null) {
      if (_trailerCache.containsKey(tmdbId)) {
        trailerUrl = _trailerCache[tmdbId];
      } else {
        trailerUrl = await ref
            .read(tmdbApiClientProvider)
            .fetchTrailerUrl(tmdbId);
        _trailerCache[tmdbId] = trailerUrl;
      }
      if (!mounted) {
        return;
      }
    }

    final movieTitle = movie.title.replaceAll('\n', ' ');
    if (trailerUrl == null) {
      await showInfoDialog(
        context,
        title: 'Trailer unavailable',
        message: '$movieTitle does not have a trailer link yet.',
      );
      return;
    }

    final trailerUri = Uri.parse(trailerUrl);
    final launcher = widget.onOpenTrailer;
    if (launcher != null) {
      await launcher(trailerUri);
      return;
    }

    final opened = await openTrailerUri(trailerUri);
    if (!opened && mounted) {
      await showInfoDialog(
        context,
        title: 'Trailer unavailable',
        message: 'Could not open $movieTitle on YouTube.',
      );
    }
  }

  void _rateMovie(MovieView movie, double rating) {
    final normalizedRating = normalizeRating(rating);
    setState(() {
      _userMovieRatings[movie.title] = normalizedRating;
      _ratingHistory.removeWhere((entry) => entry.movie.title == movie.title);
      _ratingHistory.insert(
        0,
        _RatingHistoryEntry(movie: movie, rating: normalizedRating),
      );
    });
    widget.onPersistRating?.call(movie, normalizedRating);
  }

  void _toggleWatchlist(MovieView movie) {
    setState(() {
      if (_watchlistMovieTitles.add(movie.title)) {
        _watchlistMovies.insert(0, movie);
      } else {
        _watchlistMovieTitles.remove(movie.title);
        _watchlistMovies.removeWhere((m) => m.title == movie.title);
      }
    });
    widget.onPersistWatchlistToggle?.call(movie);
  }

  @override
  Widget build(BuildContext context) {
    final palette = _darkMode ? CineratePalette.dark : CineratePalette.light;
    final homeMoviesAsync = ref.watch(_homeMovieCollectionsProvider);
    final homeMovieCollections = homeMoviesAsync.when(
      data: (collections) => collections,
      loading: _HomeMovieCollections.fallback,
      error: (_, _) => _HomeMovieCollections.fallback(),
    );
    final homeMovieStatus = homeMoviesAsync.when<String?>(
      data: (collections) => collections.fromApi
          ? null
          : 'Bundled picks are showing until TMDB is ready.',
      loading: () => 'Loading TMDB posters...',
      error: (error, _) => error.toString().replaceFirst('TmdbException: ', ''),
    );

    return CinerateThemeScope(
      palette: palette,
      child: CupertinoTheme(
        data: CupertinoThemeData(
          brightness: palette.brightness,
          primaryColor: palette.primary,
          primaryContrastingColor: CupertinoColors.white,
          scaffoldBackgroundColor: palette.background,
          barBackgroundColor: palette.background,
          textTheme: CupertinoTextThemeData(
            primaryColor: palette.primary,
            textStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: palette.textPrimary,
            ),
            actionTextStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: palette.primary,
            ),
          ),
        ),
        child: CupertinoPageScaffold(
          backgroundColor: palette.background,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final mediaSize = MediaQuery.sizeOf(context);
              final frameWidth = constraints.hasBoundedWidth
                  ? constraints.maxWidth
                  : mediaSize.width;
              final measuredHeight = constraints.hasBoundedHeight
                  ? constraints.maxHeight
                  : mediaSize.height;
              final frameHeight = frameWidth >= 700
                  ? math.min(measuredHeight, 600.0)
                  : measuredHeight;

              return Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  key: const ValueKey('main-design-frame'),
                  width: frameWidth,
                  height: frameHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: palette.background),
                    child: ClipRect(
                      child: Column(
                        children: [
                          Expanded(
                            child: IndexedStack(
                              index: _tab.index,
                              children: [
                                _HomeTab(
                                  user: _user,
                                  movieCollections: homeMovieCollections,
                                  movieFeedStatus: homeMovieStatus,
                                  movieFeedStatusIsLoading:
                                      homeMoviesAsync.isLoading,
                                  userRatings: _userMovieRatings,
                                  watchlistMovieTitles: _watchlistMovieTitles,
                                  onOpenSearch: () =>
                                      setState(() => _tab = _MainTab.search),
                                  onOpenSettings: () =>
                                      setState(() => _tab = _MainTab.settings),
                                  onOpenWatchlist: () =>
                                      setState(() => _tab = _MainTab.watchlist),
                                  onRefreshMovies: () => ref.invalidate(
                                    _homeMovieCollectionsProvider,
                                  ),
                                  onOpenTrailer: _openTrailer,
                                  onRateMovie: _rateMovie,
                                  onToggleWatchlist: _toggleWatchlist,
                                ),
                                SearchScreen(
                                  userRatings: _userMovieRatings,
                                  watchlistTitles: _watchlistMovieTitles,
                                  onOpenTrailer: _openTrailer,
                                  onRateMovie: _rateMovie,
                                  onToggleWatchlist: _toggleWatchlist,
                                ),
                                _WatchlistTab(
                                  movies: _watchlistMovies,
                                  userRatings: _userMovieRatings,
                                  watchlistMovieTitles: _watchlistMovieTitles,
                                  onOpenSearch: () =>
                                      setState(() => _tab = _MainTab.search),
                                  onOpenTrailer: _openTrailer,
                                  onRateMovie: _rateMovie,
                                  onToggleWatchlist: _toggleWatchlist,
                                ),
                                _SettingsTab(
                                  user: _user,
                                  watchlistMovies: _watchlistMovies,
                                  ratingHistory: _ratingHistory,
                                  onLogout: widget.onLogout,
                                  onUpdateProfile: _updateProfile,
                                  onChangePassword: _changePassword,
                                  darkMode: _darkMode,
                                  onDarkModeChanged: (value) =>
                                      setState(() => _darkMode = value),
                                ),
                              ],
                            ),
                          ),
                          _CinerateBottomNav(
                            selectedTab: _tab,
                            onSelected: (tab) => setState(() => _tab = tab),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
