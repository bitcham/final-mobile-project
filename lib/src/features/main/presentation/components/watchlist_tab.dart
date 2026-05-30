part of '../main_tab_screen.dart';

class _WatchlistTab extends StatelessWidget {
  const _WatchlistTab({
    required this.movies,
    required this.userRatings,
    required this.watchlistMovieTitles,
    required this.onOpenSearch,
    required this.onOpenTrailer,
    required this.onRateMovie,
    required this.onToggleWatchlist,
    required this.resolveMovieDetails,
  });

  final List<MovieView> movies;
  final Map<String, double> userRatings;
  final Set<String> watchlistMovieTitles;
  final VoidCallback onOpenSearch;
  final Future<void> Function(MovieView movie) onOpenTrailer;
  final void Function(MovieView movie, double rating) onRateMovie;
  final void Function(MovieView movie) onToggleWatchlist;
  final Future<MovieView> Function(MovieView movie) resolveMovieDetails;

  double? _userRatingFor(MovieView movie) => userRatings[movie.title];

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Watchlist',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: palette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${movies.length} liked movies',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: palette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(42, 42),
                    borderRadius: BorderRadius.circular(21),
                    onPressed: onOpenSearch,
                    child: LiquidGlassPane(
                      borderRadius: 21,
                      tint: palette.surface,
                      tintOpacity: palette.brightness == Brightness.dark
                          ? 0.58
                          : 0.86,
                      shadowOpacity: 0.12,
                      child: SizedBox(
                        width: 42,
                        height: 42,
                        child: Icon(
                          CupertinoIcons.search,
                          size: 20,
                          color: palette.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (movies.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyWatchlist(onOpenSearch: onOpenSearch),
            )
          else
            SliverLayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.crossAxisExtent;
                final columns = width >= 900
                    ? 6
                    : width >= 640
                    ? 4
                    : 3;
                final horizontalPadding = width >= 640 ? 32.0 : 22.0;
                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    18,
                    horizontalPadding,
                    112,
                  ),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final movie = movies[index];
                      return _WatchlistMovieCard(
                        movie: movie,
                        userRating: _userRatingFor(movie),
                        inWatchlist: watchlistMovieTitles.contains(movie.title),
                        onOpenTrailer: onOpenTrailer,
                        onRateMovie: onRateMovie,
                        onToggleWatchlist: onToggleWatchlist,
                        resolveMovieDetails: resolveMovieDetails,
                      );
                    }, childCount: movies.length),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: width >= 640 ? 20 : 16,
                      childAspectRatio: 0.52,
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

class _WatchlistMovieCard extends StatelessWidget {
  const _WatchlistMovieCard({
    required this.movie,
    required this.userRating,
    required this.inWatchlist,
    required this.onOpenTrailer,
    required this.onRateMovie,
    required this.onToggleWatchlist,
    required this.resolveMovieDetails,
  });

  final MovieView movie;
  final double? userRating;
  final bool inWatchlist;
  final Future<void> Function(MovieView movie) onOpenTrailer;
  final void Function(MovieView movie, double rating) onRateMovie;
  final void Function(MovieView movie) onToggleWatchlist;
  final Future<MovieView> Function(MovieView movie) resolveMovieDetails;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: PosterTile(
                  key: ValueKey('watchlist-movie-${movie.title}'),
                  movie: movie,
                  userRating: userRating,
                  inWatchlist: inWatchlist,
                  heroTag: 'watchlist-${movie.title}',
                  onOpenTrailer: onOpenTrailer,
                  onRateMovie: onRateMovie,
                  onToggleWatchlist: onToggleWatchlist,
                  resolveMovieDetails: resolveMovieDetails,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(34, 34),
                  borderRadius: BorderRadius.circular(17),
                  onPressed: () => onToggleWatchlist(movie),
                  child: const LiquidGlassPane(
                    borderRadius: 17,
                    tint: CupertinoColors.black,
                    tintOpacity: 0.28,
                    blurSigma: 14,
                    shadowOpacity: 0.08,
                    child: SizedBox(
                      width: 34,
                      height: 34,
                      child: Icon(
                        CupertinoIcons.heart_fill,
                        size: 17,
                        color: Color(0xFFFF453A),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
          '${movie.year} • ${movie.genres.isEmpty ? 'MOVIE' : movie.genres.first}',
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
    );
  }
}

class _EmptyWatchlist extends StatelessWidget {
  const _EmptyWatchlist({required this.onOpenSearch});

  final VoidCallback onOpenSearch;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 112),
      child: Center(
        child: LiquidGlassPane(
          borderRadius: 28,
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
          tint: palette.surface,
          tintOpacity: palette.brightness == Brightness.dark ? 0.62 : 0.88,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.heart, size: 42, color: palette.primary),
              const SizedBox(height: 14),
              Text(
                'No liked movies yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: 180,
                child: RoundedActionButton(
                  label: 'Search',
                  icon: CupertinoIcons.search,
                  color: palette.primary,
                  textColor: CupertinoColors.white,
                  onPressed: onOpenSearch,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
