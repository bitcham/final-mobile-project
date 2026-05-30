part of '../main_tab_screen.dart';

enum _HomeCategoryFilter {
  all('All', null),
  superhero('Superhero', 'SUPERHERO'),
  action('Action', 'ACTION'),
  comedy('Comedy', 'COMEDY'),
  adventure('Adventure', 'ADVENTURE'),
  drama('Drama', 'DRAMA'),
  sciFi('Sci-Fi', 'SCI-FI');

  const _HomeCategoryFilter(this.label, this.genre);

  final String label;
  final String? genre;

  bool get isActive => this != _HomeCategoryFilter.all;

  List<MovieView> apply(List<MovieView> movies) {
    final genre = this.genre;
    if (genre == null) {
      return movies;
    }
    return movies
        .where((movie) => movie.genres.contains(genre))
        .toList(growable: false);
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab({
    required this.user,
    required this.movieCollections,
    required this.movieFeedStatus,
    required this.movieFeedStatusIsLoading,
    required this.userRatings,
    required this.watchlistMovieTitles,
    required this.onOpenProfile,
    required this.onRefreshMovies,
    required this.onOpenTrailer,
    required this.onRateMovie,
    required this.onToggleWatchlist,
    required this.resolveMovieDetails,
  });

  final AppUser user;
  final _HomeMovieCollections movieCollections;
  final String? movieFeedStatus;
  final bool movieFeedStatusIsLoading;
  final Map<String, double> userRatings;
  final Set<String> watchlistMovieTitles;
  final VoidCallback onOpenProfile;
  final VoidCallback onRefreshMovies;
  final Future<void> Function(MovieView movie) onOpenTrailer;
  final void Function(MovieView movie, double rating) onRateMovie;
  final void Function(MovieView movie) onToggleWatchlist;
  final Future<MovieView> Function(MovieView movie) resolveMovieDetails;

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final PageController _showcaseController = PageController();
  int _showcaseIndex = 0;
  _HomeCategoryFilter _categoryFilter = _HomeCategoryFilter.all;

  @override
  void dispose() {
    _showcaseController.dispose();
    super.dispose();
  }

  double? _userRatingFor(MovieView movie) {
    return widget.userRatings[movie.title];
  }

  bool _isInWatchlist(MovieView movie) {
    return widget.watchlistMovieTitles.contains(movie.title);
  }

  @override
  Widget build(BuildContext context) {
    final movies = widget.movieCollections;
    final latestMovies = _categoryFilter.apply(movies.latest);
    final trendingMovies = _categoryFilter.apply(movies.trending);
    final topRatedMovies = _categoryFilter.apply(movies.topRated);
    final actionMovies = _categoryFilter.apply(movies.action);
    final rewatchMovies = _categoryFilter.apply(movies.rewatch);
    final heroSource = latestMovies.isNotEmpty ? latestMovies : trendingMovies;
    final heroMovies = heroSource.take(5).toList(growable: false);
    final heroIndex = heroMovies.isEmpty
        ? 0
        : math.min(_showcaseIndex, heroMovies.length - 1);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;
        final heroHeight = (constraints.maxHeight * (isWide ? 0.58 : 0.63))
            .clamp(isWide ? 350.0 : 450.0, isWide ? 380.0 : 510.0);

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _HeroShowcase(
                height: heroHeight,
                user: widget.user,
                movies: heroMovies,
                controller: _showcaseController,
                currentIndex: heroIndex,
                onPageChanged: (index) =>
                    setState(() => _showcaseIndex = index),
                currentFilter: _categoryFilter,
                onSelectFilter: (filter) {
                  setState(() {
                    _categoryFilter = filter;
                    _showcaseIndex = 0;
                  });
                  if (_showcaseController.hasClients) {
                    _showcaseController.jumpToPage(0);
                  }
                },
                userRatingFor: _userRatingFor,
                isInWatchlist: _isInWatchlist,
                onOpenProfile: widget.onOpenProfile,
                onOpenTrailer: widget.onOpenTrailer,
                onRateMovie: widget.onRateMovie,
                onToggleWatchlist: widget.onToggleWatchlist,
                resolveMovieDetails: widget.resolveMovieDetails,
              ),
            ),
            if (widget.movieFeedStatus != null)
              SliverToBoxAdapter(
                child: _MovieFeedStatusBanner(
                  message: widget.movieFeedStatus!,
                  isLoading: widget.movieFeedStatusIsLoading,
                  onRefresh: widget.onRefreshMovies,
                ),
              ),
            if (_categoryFilter.isActive)
              SliverToBoxAdapter(
                child: _HomeFilterBanner(
                  filter: _categoryFilter,
                  onClear: () {
                    setState(() {
                      _categoryFilter = _HomeCategoryFilter.all;
                      _showcaseIndex = 0;
                    });
                    if (_showcaseController.hasClients) {
                      _showcaseController.jumpToPage(0);
                    }
                  },
                ),
              ),
            SliverToBoxAdapter(
              child: _MovieShelf(
                title: _categoryFilter.isActive
                    ? '${_categoryFilter.label} Picks'
                    : 'Trending Now',
                actionLabel: 'SEE ALL',
                movies: trendingMovies,
                keyPrefix: 'trending',
                userRatingFor: _userRatingFor,
                isInWatchlist: _isInWatchlist,
                onActionPressed: () =>
                    _showTrendingDialog(context, trendingMovies),
                onOpenTrailer: widget.onOpenTrailer,
                onRateMovie: widget.onRateMovie,
                onToggleWatchlist: widget.onToggleWatchlist,
                resolveMovieDetails: widget.resolveMovieDetails,
              ),
            ),
            SliverToBoxAdapter(
              child: _MovieShelf(
                title: 'Top Rated',
                movies: topRatedMovies,
                keyPrefix: 'top-rated',
                userRatingFor: _userRatingFor,
                isInWatchlist: _isInWatchlist,
                onOpenTrailer: widget.onOpenTrailer,
                onRateMovie: widget.onRateMovie,
                onToggleWatchlist: widget.onToggleWatchlist,
                resolveMovieDetails: widget.resolveMovieDetails,
              ),
            ),
            if (!_categoryFilter.isActive)
              SliverToBoxAdapter(
                child: _MovieShelf(
                  title: 'Action Picks',
                  movies: actionMovies,
                  keyPrefix: 'action',
                  userRatingFor: _userRatingFor,
                  isInWatchlist: _isInWatchlist,
                  onOpenTrailer: widget.onOpenTrailer,
                  onRateMovie: widget.onRateMovie,
                  onToggleWatchlist: widget.onToggleWatchlist,
                  resolveMovieDetails: widget.resolveMovieDetails,
                ),
              ),
            if (!_categoryFilter.isActive)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 34),
                  child: _MovieShelf(
                    title: 'Rewatch Classics',
                    movies: rewatchMovies,
                    keyPrefix: 'rewatch',
                    userRatingFor: _userRatingFor,
                    isInWatchlist: _isInWatchlist,
                    onOpenTrailer: widget.onOpenTrailer,
                    onRateMovie: widget.onRateMovie,
                    onToggleWatchlist: widget.onToggleWatchlist,
                    resolveMovieDetails: widget.resolveMovieDetails,
                  ),
                ),
              ),
            if (_categoryFilter.isActive)
              const SliverToBoxAdapter(child: SizedBox(height: 34)),
          ],
        );
      },
    );
  }
}

class _MovieFeedStatusBanner extends StatelessWidget {
  const _MovieFeedStatusBanner({
    required this.message,
    required this.isLoading,
    required this.onRefresh,
  });

  final String message;
  final bool isLoading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
      child: LiquidGlassPane(
        borderRadius: 18,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        tint: CupertinoColors.black,
        tintOpacity: 0.18,
        shadowOpacity: 0.08,
        child: Row(
          children: [
            if (isLoading)
              const CupertinoActivityIndicator(radius: 7)
            else
              Icon(
                CupertinoIcons.info_circle_fill,
                size: 16,
                color: context.cineratePalette.primary,
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: context.cineratePalette.textSecondary,
                ),
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(34, 28),
              onPressed: onRefresh,
              child: Icon(
                CupertinoIcons.arrow_clockwise,
                size: 18,
                color: context.cineratePalette.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeFilterBanner extends StatelessWidget {
  const _HomeFilterBanner({required this.filter, required this.onClear});

  final _HomeCategoryFilter filter;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: palette.surface,
          border: Border.all(color: palette.tagBackground),
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.slider_horizontal_3,
              size: 17,
              color: palette.primary,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                'Showing ${filter.label}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: palette.textPrimary,
                ),
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(44, 28),
              onPressed: onClear,
              child: Text(
                'Clear',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: palette.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroShowcase extends StatelessWidget {
  const _HeroShowcase({
    required this.height,
    required this.user,
    required this.movies,
    required this.controller,
    required this.currentIndex,
    required this.onPageChanged,
    required this.currentFilter,
    required this.onSelectFilter,
    required this.userRatingFor,
    required this.isInWatchlist,
    required this.onOpenProfile,
    required this.onOpenTrailer,
    required this.onRateMovie,
    required this.onToggleWatchlist,
    required this.resolveMovieDetails,
  });

  final double height;
  final AppUser user;
  final List<MovieView> movies;
  final PageController controller;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final _HomeCategoryFilter currentFilter;
  final ValueChanged<_HomeCategoryFilter> onSelectFilter;
  final double? Function(MovieView movie) userRatingFor;
  final bool Function(MovieView movie) isInWatchlist;
  final VoidCallback onOpenProfile;
  final Future<void> Function(MovieView movie) onOpenTrailer;
  final void Function(MovieView movie, double rating) onRateMovie;
  final void Function(MovieView movie) onToggleWatchlist;
  final Future<MovieView> Function(MovieView movie) resolveMovieDetails;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: controller,
            itemCount: movies.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return _HeroShowcasePage(
                movie: movie,
                selected: index == currentIndex,
                userRating: userRatingFor(movie),
                inWatchlist: isInWatchlist(movie),
                onOpenTrailer: onOpenTrailer,
                onRateMovie: onRateMovie,
                onToggleWatchlist: onToggleWatchlist,
                resolveMovieDetails: resolveMovieDetails,
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                child: _HomeHeader(
                  user: user,
                  currentFilter: currentFilter,
                  onSelectFilter: onSelectFilter,
                  onOpenProfile: onOpenProfile,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 18,
            child: _ShowcaseDots(count: movies.length, index: currentIndex),
          ),
        ],
      ),
    );
  }
}

class _HeroShowcasePage extends StatelessWidget {
  const _HeroShowcasePage({
    required this.movie,
    required this.selected,
    required this.userRating,
    required this.inWatchlist,
    required this.onOpenTrailer,
    required this.onRateMovie,
    required this.onToggleWatchlist,
    required this.resolveMovieDetails,
  });

  final MovieView movie;
  final bool selected;
  final double? userRating;
  final bool inWatchlist;
  final Future<void> Function(MovieView movie) onOpenTrailer;
  final void Function(MovieView movie, double rating) onRateMovie;
  final void Function(MovieView movie) onToggleWatchlist;
  final Future<MovieView> Function(MovieView movie) resolveMovieDetails;

  @override
  Widget build(BuildContext context) {
    final heroTag = 'latest-${movie.title}';
    return Stack(
      fit: StackFit.expand,
      children: [
        _PosterBackdrop(movie: movie),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                CupertinoColors.black.withValues(alpha: 0.20),
                CupertinoColors.black.withValues(alpha: 0.52),
                CupertinoColors.black.withValues(alpha: 0.84),
              ],
              stops: const [0, 0.54, 1],
            ),
          ),
        ),
        Positioned.fill(
          child: SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 74, 22, 40),
              child: Align(
                alignment: const Alignment(0, 0.04),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 650),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 260),
                    opacity: selected ? 1 : 0.35,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxWidth < 380;
                        final dense = constraints.maxHeight < 285;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                PosterTile(
                                  movie: movie,
                                  userRating: userRating,
                                  inWatchlist: inWatchlist,
                                  heroTag: heroTag,
                                  large: true,
                                  onOpenTrailer: onOpenTrailer,
                                  onRateMovie: onRateMovie,
                                  onToggleWatchlist: onToggleWatchlist,
                                  resolveMovieDetails: resolveMovieDetails,
                                ),
                                SizedBox(width: compact ? 14 : 18),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        movie.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: compact
                                              ? 24
                                              : dense
                                              ? 26
                                              : 31,
                                          height: 0.98,
                                          fontWeight: FontWeight.w900,
                                          color: CupertinoColors.white,
                                          shadows: const [
                                            Shadow(
                                              color: CupertinoColors.black,
                                              blurRadius: 14,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        movie.synopsis,
                                        maxLines: compact || dense ? 2 : 4,
                                        overflow: TextOverflow.ellipsis,
                                        style: CinerateText.bodySmall.copyWith(
                                          color: CupertinoColors.white
                                              .withValues(alpha: 0.88),
                                          fontSize: compact ? 10.5 : 11.5,
                                          fontWeight: FontWeight.w600,
                                          height: 1.4,
                                          shadows: const [
                                            Shadow(
                                              color: CupertinoColors.black,
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: dense ? 10 : 12),
                                      Wrap(
                                        spacing: 7,
                                        runSpacing: 6,
                                        children: movie.genres
                                            .map(GenrePill.new)
                                            .toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: dense ? 14 : 18),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: RoundedActionButton(
                                    label: 'Watch Trailer',
                                    icon: CupertinoIcons.play_fill,
                                    color: const Color(0xFFFF453A),
                                    textColor: CupertinoColors.white,
                                    onPressed: () => onOpenTrailer(movie),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 2,
                                  child: RoundedActionButton(
                                    key: ValueKey('hero-rate-${movie.title}'),
                                    label: 'Rate',
                                    icon: CupertinoIcons.star_fill,
                                    color: CupertinoColors.white,
                                    textColor: const Color(0xFF161A22),
                                    onPressed: () async {
                                      final rating = await showRatingRangeSheet(
                                        context,
                                        initialRating:
                                            userRating ?? movie.rating,
                                        title: 'Your Rating',
                                        valueSuffix: ' ★',
                                        applyLabel: 'Save rating',
                                      );
                                      if (rating != null) {
                                        onRateMovie(movie, rating);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                CircleActionButton(
                                  key: ValueKey(
                                    'hero-watchlist-${movie.title}',
                                  ),
                                  icon: inWatchlist
                                      ? CupertinoIcons.heart_fill
                                      : CupertinoIcons.heart,
                                  onPressed: () {
                                    final willAdd = !inWatchlist;
                                    onToggleWatchlist(movie);
                                    showInfoDialog(
                                      context,
                                      title: willAdd
                                          ? 'Added to watchlist'
                                          : 'Removed from watchlist',
                                      message: movie.title,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.user,
    required this.currentFilter,
    required this.onSelectFilter,
    required this.onOpenProfile,
  });

  final AppUser user;
  final _HomeCategoryFilter currentFilter;
  final ValueChanged<_HomeCategoryFilter> onSelectFilter;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CupertinoButton(
          key: const ValueKey('home-quick-menu'),
          padding: EdgeInsets.zero,
          minimumSize: const Size(38, 38),
          borderRadius: BorderRadius.circular(19),
          onPressed: () => _showHomeMenu(
            context,
            currentFilter: currentFilter,
            onSelectFilter: onSelectFilter,
          ),
          child: const LiquidGlassPane(
            borderRadius: 19,
            tint: CupertinoColors.black,
            tintOpacity: 0.24,
            child: SizedBox(
              width: 38,
              height: 38,
              child: Icon(
                CupertinoIcons.line_horizontal_3,
                size: 22,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ),
        const Expanded(child: Center(child: CinerateLogo(fontSize: 21))),
        ProfileAvatar(
          key: const ValueKey('home-profile-avatar'),
          imagePath: user.profileImagePath,
          size: 38,
          onTap: onOpenProfile,
        ),
      ],
    );
  }
}

class _ShowcaseDots extends StatelessWidget {
  const _ShowcaseDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var dotIndex = 0; dotIndex < count; dotIndex++) ...[
          AnimatedContainer(
            key: ValueKey('showcase-dot-$dotIndex'),
            duration: const Duration(milliseconds: 220),
            width: index == dotIndex ? 22 : 6,
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: index == dotIndex
                  ? const Color(0xFFFF453A)
                  : CupertinoColors.white.withValues(alpha: 0.28),
            ),
          ),
          if (dotIndex != count - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _MovieShelf extends StatelessWidget {
  const _MovieShelf({
    required this.title,
    required this.movies,
    required this.keyPrefix,
    required this.userRatingFor,
    required this.isInWatchlist,
    required this.onOpenTrailer,
    required this.onRateMovie,
    required this.onToggleWatchlist,
    required this.resolveMovieDetails,
    this.actionLabel,
    this.onActionPressed,
  });

  final String title;
  final String? actionLabel;
  final List<MovieView> movies;
  final String keyPrefix;
  final double? Function(MovieView movie) userRatingFor;
  final bool Function(MovieView movie) isInWatchlist;
  final VoidCallback? onActionPressed;
  final Future<void> Function(MovieView movie) onOpenTrailer;
  final void Function(MovieView movie, double rating) onRateMovie;
  final void Function(MovieView movie) onToggleWatchlist;
  final Future<MovieView> Function(MovieView movie) resolveMovieDetails;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: palette.textPrimary,
                    ),
                  ),
                ),
                if (actionLabel != null && onActionPressed != null)
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(40, 28),
                    onPressed: onActionPressed,
                    child: Text(
                      actionLabel!,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                        color: Color(0xFFFFB7B3),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 242,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              scrollDirection: Axis.horizontal,
              itemCount: movies.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final movie = movies[index];
                return _ShelfMovieTile(
                  posterKey: ValueKey('$keyPrefix-movie-${movie.title}'),
                  movie: movie,
                  rank: keyPrefix == 'trending' ? index + 1 : null,
                  userRating: userRatingFor(movie),
                  inWatchlist: isInWatchlist(movie),
                  heroTag: '$keyPrefix-${movie.title}',
                  onOpenTrailer: onOpenTrailer,
                  onRateMovie: onRateMovie,
                  onToggleWatchlist: onToggleWatchlist,
                  resolveMovieDetails: resolveMovieDetails,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ShelfMovieTile extends StatelessWidget {
  const _ShelfMovieTile({
    required this.posterKey,
    required this.movie,
    required this.userRating,
    required this.inWatchlist,
    required this.heroTag,
    required this.onOpenTrailer,
    required this.onRateMovie,
    required this.onToggleWatchlist,
    required this.resolveMovieDetails,
    this.rank,
  });

  final Key posterKey;
  final MovieView movie;
  final int? rank;
  final double? userRating;
  final bool inWatchlist;
  final Object heroTag;
  final Future<void> Function(MovieView movie) onOpenTrailer;
  final void Function(MovieView movie, double rating) onRateMovie;
  final void Function(MovieView movie) onToggleWatchlist;
  final Future<MovieView> Function(MovieView movie) resolveMovieDetails;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    return SizedBox(
      width: 126,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: 126,
                height: 188,
                child: PosterTile(
                  key: posterKey,
                  movie: movie,
                  userRating: userRating,
                  inWatchlist: inWatchlist,
                  heroTag: heroTag,
                  onOpenTrailer: onOpenTrailer,
                  onRateMovie: onRateMovie,
                  onToggleWatchlist: onToggleWatchlist,
                  resolveMovieDetails: resolveMovieDetails,
                ),
              ),
              if (rank != null)
                Positioned(
                  left: -7,
                  bottom: -8,
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 42,
                      height: 0.9,
                      fontWeight: FontWeight.w900,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 2
                        ..color = CupertinoColors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              height: 1.15,
              fontWeight: FontWeight.w800,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${movie.year} • ${movie.genres.first}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PosterBackdrop extends StatelessWidget {
  const _PosterBackdrop({required this.movie});

  final MovieView movie;

  @override
  Widget build(BuildContext context) {
    final posterUrl = movie.posterUrl;
    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: movie.palette,
        ),
      ),
    );

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          fallback,
          if (posterUrl != null)
            Opacity(
              opacity: 0.34,
              child: ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Transform.scale(
                  scale: 1.18,
                  child: Image.network(
                    posterUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  CupertinoColors.black.withValues(alpha: 0.12),
                  CupertinoColors.black.withValues(alpha: 0.34),
                  CupertinoColors.black.withValues(alpha: 0.68),
                ],
                stops: const [0, 0.50, 1],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
