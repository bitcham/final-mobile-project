import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import 'package:movie_rating/src/core/theme/app_theme.dart';
import 'package:movie_rating/src/core/widgets/cinerate_logo.dart';
import 'package:movie_rating/src/core/widgets/profile_avatar.dart';
import 'package:movie_rating/src/features/auth/models/app_user.dart';

import 'trailer_launcher.dart';

part 'components/main_tab_theme.dart';
part 'components/main_tab_data.dart';
part 'components/home_tab.dart';
part 'components/search_tab.dart';
part 'components/search_widgets.dart';
part 'components/settings_tab.dart';
part 'components/settings_widgets.dart';
part 'components/movie_widgets.dart';
part 'components/main_tab_dialogs.dart';
part 'components/bottom_nav.dart';

typedef ProfileUpdateCallback = Future<AppUser> Function(String realName);
typedef PasswordChangeCallback =
    Future<bool> Function({
      required String currentPassword,
      required String newPassword,
    });
typedef TrailerLauncherCallback = Future<void> Function(Uri trailerUrl);

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({
    super.key,
    required this.user,
    this.onLogout,
    this.onUpdateProfile,
    this.onChangePassword,
    this.onOpenTrailer,
  });

  final AppUser user;
  final VoidCallback? onLogout;
  final ProfileUpdateCallback? onUpdateProfile;
  final PasswordChangeCallback? onChangePassword;
  final TrailerLauncherCallback? onOpenTrailer;

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  _MainTab _tab = _MainTab.home;
  late AppUser _user = widget.user;
  bool _darkMode = true;
  final Map<String, double> _userMovieRatings = <String, double>{};
  final Set<String> _watchlistMovieTitles = <String>{};
  final List<_RatingHistoryEntry> _ratingHistory = <_RatingHistoryEntry>[];

  List<_DesignMovie> get _watchlistMovies {
    return _marvelMovies
        .where((movie) => _watchlistMovieTitles.contains(movie.title))
        .toList(growable: false);
  }

  @override
  void didUpdateWidget(covariant MainTabScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user != widget.user) {
      _user = widget.user;
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

  Future<void> _openTrailer(_DesignMovie movie) async {
    final trailerUrl = movie.trailerUrl;
    final movieTitle = movie.title.replaceAll('\n', ' ');
    if (trailerUrl == null) {
      await _showInfoDialog(
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
      await _showInfoDialog(
        context,
        title: 'Trailer unavailable',
        message: 'Could not open $movieTitle on YouTube.',
      );
    }
  }

  void _rateMovie(_DesignMovie movie, double rating) {
    final normalizedRating = _normalizeRating(rating);
    setState(() {
      _userMovieRatings[movie.title] = normalizedRating;
      _ratingHistory.insert(
        0,
        _RatingHistoryEntry(movie: movie, rating: normalizedRating),
      );
    });
  }

  void _toggleWatchlist(_DesignMovie movie) {
    setState(() {
      if (!_watchlistMovieTitles.add(movie.title)) {
        _watchlistMovieTitles.remove(movie.title);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = _darkMode ? _CineratePalette.dark : _CineratePalette.light;

    return _CinerateThemeScope(
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
                                  userRatings: _userMovieRatings,
                                  watchlistMovieTitles: _watchlistMovieTitles,
                                  onOpenSearch: () =>
                                      setState(() => _tab = _MainTab.search),
                                  onOpenSettings: () =>
                                      setState(() => _tab = _MainTab.settings),
                                  onOpenTrailer: _openTrailer,
                                  onRateMovie: _rateMovie,
                                  onToggleWatchlist: _toggleWatchlist,
                                ),
                                _SearchTab(
                                  userRatings: _userMovieRatings,
                                  onOpenTrailer: _openTrailer,
                                  onRateMovie: _rateMovie,
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
