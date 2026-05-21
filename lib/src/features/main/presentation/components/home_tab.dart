part of '../main_tab_screen.dart';

class _HomeTab extends StatefulWidget {
  const _HomeTab({
    required this.user,
    required this.userRatings,
    required this.watchlistMovieTitles,
    required this.onOpenSearch,
    required this.onOpenSettings,
    required this.onOpenTrailer,
    required this.onRateMovie,
    required this.onToggleWatchlist,
  });

  final AppUser user;
  final Map<String, double> userRatings;
  final Set<String> watchlistMovieTitles;
  final VoidCallback onOpenSearch;
  final VoidCallback onOpenSettings;
  final Future<void> Function(MovieView movie) onOpenTrailer;
  final void Function(MovieView movie, double rating) onRateMovie;
  final void Function(MovieView movie) onToggleWatchlist;

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final ScrollController _scrollController = ScrollController();
  MovieView _selectedMovie = _featuredMovie;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _selectTrendingMovie(MovieView movie) {
    setState(() => _selectedMovie = movie);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
  }

  double? _userRatingFor(MovieView movie) {
    return widget.userRatings[movie.title];
  }

  bool _isInWatchlist(MovieView movie) {
    return widget.watchlistMovieTitles.contains(movie.title);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 14),
            sliver: SliverToBoxAdapter(
              child: _HomeHeader(
                user: widget.user,
                onOpenSearch: widget.onOpenSearch,
                onOpenSettings: widget.onOpenSettings,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _HeroMoviePanel(
              key: ValueKey('hero-${_selectedMovie.title}'),
              movie: _selectedMovie,
              userRating: _userRatingFor(_selectedMovie),
              inWatchlist: _isInWatchlist(_selectedMovie),
              onOpenTrailer: widget.onOpenTrailer,
              onRateMovie: widget.onRateMovie,
              onToggleWatchlist: widget.onToggleWatchlist,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 14),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Trending Now',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: palette.textPrimary,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(28, 28),
                    onPressed: () => _showTrendingDialog(context),
                    child: const Text(
                      'SEE ALL',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                        color: Color(0xFFFFC7C7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverLayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.crossAxisExtent;
              final columnCount = availableWidth >= 900
                  ? 6
                  : availableWidth >= 640
                  ? 4
                  : 3;
              final horizontalPadding = availableWidth >= 640 ? 32.0 : 22.0;
              final crossAxisSpacing = availableWidth >= 640 ? 20.0 : 24.0;

              return SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  0,
                  horizontalPadding,
                  112,
                ),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => PosterTile(
                      key: ValueKey(
                        'trending-movie-${_trendingMovies[index].title}',
                      ),
                      movie: _trendingMovies[index],
                      userRating: _userRatingFor(_trendingMovies[index]),
                      onOpenTrailer: widget.onOpenTrailer,
                      onRateMovie: widget.onRateMovie,
                      onPressed: () =>
                          _selectTrendingMovie(_trendingMovies[index]),
                    ),
                    childCount: _trendingMovies.length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columnCount,
                    mainAxisSpacing: 22,
                    crossAxisSpacing: crossAxisSpacing,
                    childAspectRatio: 0.62,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.user,
    required this.onOpenSearch,
    required this.onOpenSettings,
  });

  final AppUser user;
  final VoidCallback onOpenSearch;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    return Row(
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: const Size(36, 36),
          onPressed: () => _showHomeMenu(
            context,
            onOpenSearch: onOpenSearch,
            onOpenSettings: onOpenSettings,
          ),
          child: Icon(
            CupertinoIcons.line_horizontal_3,
            size: 25,
            color: palette.textPrimary,
          ),
        ),
        const Expanded(child: Center(child: CinerateLogo(fontSize: 21))),
        ProfileAvatar(
          imagePath: user.profileImagePath,
          size: 38,
          onTap: onOpenSettings,
        ),
      ],
    );
  }
}

class _HeroMoviePanel extends StatelessWidget {
  const _HeroMoviePanel({
    super.key,
    required this.movie,
    required this.userRating,
    required this.inWatchlist,
    required this.onOpenTrailer,
    required this.onRateMovie,
    required this.onToggleWatchlist,
  });

  final MovieView movie;
  final double? userRating;
  final bool inWatchlist;
  final Future<void> Function(MovieView movie) onOpenTrailer;
  final void Function(MovieView movie, double rating) onRateMovie;
  final void Function(MovieView movie) onToggleWatchlist;

  @override
  Widget build(BuildContext context) {
    final movie = this.movie;
    return SizedBox(
      height: 340,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _HeroBackdrop(movie: movie),
          DecoratedBox(
            decoration: BoxDecoration(
              color: CupertinoColors.black.withValues(alpha: 0.48),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    CupertinoColors.black.withValues(alpha: 0.08),
                    CupertinoColors.black.withValues(alpha: 0.48),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 36, 22, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PosterTile(
                        movie: movie,
                        userRating: userRating,
                        large: true,
                        onOpenTrailer: onOpenTrailer,
                        onRateMovie: onRateMovie,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movie.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 28,
                                  height: 0.95,
                                  fontWeight: FontWeight.w900,
                                  color: CupertinoColors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Flexible(
                                child: Text(
                                  movie.synopsis,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: CinerateText.bodySmall.copyWith(
                                    color: CupertinoColors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: movie.genres
                                    .map(GenrePill.new)
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: RoundedActionButton(
                            label: 'Watch Trailer',
                            icon: CupertinoIcons.play_fill,
                            color: const Color(0xFFFF3131),
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
                                initialRating: userRating ?? movie.rating,
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
                        const SizedBox(width: 12),
                        CircleActionButton(
                          key: ValueKey('hero-watchlist-${movie.title}'),
                          icon: inWatchlist
                              ? CupertinoIcons.check_mark
                              : CupertinoIcons.plus,
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBackdrop extends StatelessWidget {
  const _HeroBackdrop({required this.movie});

  final MovieView movie;

  @override
  Widget build(BuildContext context) {
    final posterUrl = movie.posterUrl;
    if (posterUrl == null) {
      return DecoratedBox(decoration: BoxDecoration(color: movie.palette.last));
    }

    return Image.network(
      posterUrl,
      fit: BoxFit.cover,
      color: CupertinoColors.black.withValues(alpha: 0.72),
      colorBlendMode: BlendMode.darken,
      errorBuilder: (context, error, stackTrace) {
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: movie.palette,
            ),
          ),
        );
      },
    );
  }
}
