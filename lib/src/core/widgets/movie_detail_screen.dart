import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../models/movie_view.dart';
import '../theme/app_theme.dart';

typedef MovieRatingRequest =
    Future<double?> Function(
      BuildContext context,
      MovieView movie,
      double initialRating,
    );

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({
    super.key,
    required this.movie,
    required this.userRating,
    required this.inWatchlist,
    required this.heroTag,
    required this.onOpenTrailer,
    required this.onRatePressed,
    required this.onToggleWatchlist,
    this.resolveMovieDetails,
  });

  final MovieView movie;
  final double? userRating;
  final bool inWatchlist;
  final Object? heroTag;
  final Future<void> Function(MovieView movie) onOpenTrailer;
  final MovieRatingRequest onRatePressed;
  final void Function(MovieView movie)? onToggleWatchlist;
  final Future<MovieView> Function(MovieView movie)? resolveMovieDetails;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late MovieView _movie = widget.movie;
  late double? _userRating = widget.userRating;
  late bool _inWatchlist = widget.inWatchlist;
  late bool _isLoadingDetails = widget.resolveMovieDetails != null;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  @override
  void didUpdateWidget(covariant MovieDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.movie.title != widget.movie.title ||
        oldWidget.movie.tmdbId != widget.movie.tmdbId) {
      _movie = widget.movie;
      _userRating = widget.userRating;
      _inWatchlist = widget.inWatchlist;
      _isLoadingDetails = widget.resolveMovieDetails != null;
      _loadDetails();
    }
  }

  Future<void> _loadDetails() async {
    final resolver = widget.resolveMovieDetails;
    if (resolver == null) {
      return;
    }

    final requestedMovie = _movie;
    try {
      final detailedMovie = await resolver(requestedMovie);
      if (!mounted || _movie.title != requestedMovie.title) {
        return;
      }
      setState(() {
        _movie = detailedMovie;
        _isLoadingDetails = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingDetails = false);
      }
    }
  }

  Future<void> _rateMovie() async {
    final rating = await widget.onRatePressed(
      context,
      _movie,
      _userRating ?? _movie.rating,
    );
    if (rating != null && mounted) {
      setState(() => _userRating = rating);
    }
  }

  void _toggleWatchlist() {
    final toggle = widget.onToggleWatchlist;
    if (toggle == null) {
      return;
    }
    toggle(_movie);
    setState(() => _inWatchlist = !_inWatchlist);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    final movie = _movie;
    return CupertinoPageScaffold(
      key: ValueKey('movie-preview-${movie.title}'),
      backgroundColor: palette.background,
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _DetailHeroHeader(movie: movie, heroTag: widget.heroTag),
              ),
              SliverToBoxAdapter(
                child: ColoredBox(
                  color: palette.background,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ActionRow(
                          movie: movie,
                          onOpenTrailer: () => widget.onOpenTrailer(movie),
                          onRate: _rateMovie,
                        ),
                        if (_isLoadingDetails) ...[
                          const SizedBox(height: 12),
                          const Center(
                            child: CupertinoActivityIndicator(radius: 8),
                          ),
                        ],
                        const SizedBox(height: 22),
                        _SectionTitle('Where to watch'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: movie.streamingPlatforms
                              .map(_StreamingChip.new)
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                        _SectionTitle('Details'),
                        const SizedBox(height: 10),
                        _DetailsGrid(movie: movie, userRating: _userRating),
                        const SizedBox(height: 24),
                        _SectionTitle('Synopsis'),
                        const SizedBox(height: 10),
                        Text(
                          movie.synopsis,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            height: 1.55,
                            fontWeight: FontWeight.w600,
                            color: palette.textPrimary,
                          ),
                        ),
                        if (movie.genres.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: movie.genres.map(_GenreChip.new).toList(),
                          ),
                        ],
                        const SizedBox(height: 24),
                        _SectionTitle('Cast'),
                        const SizedBox(height: 10),
                        _CastList(cast: movie.cast),
                        const SizedBox(height: 24),
                        _SectionTitle('Reviews'),
                        const SizedBox(height: 10),
                        _ReviewList(reviews: movie.reviews),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Row(
                  children: [
                    _RoundIconButton(
                      key: ValueKey('movie-detail-back-${movie.title}'),
                      icon: CupertinoIcons.chevron_left,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    if (widget.onToggleWatchlist != null)
                      _RoundIconButton(
                        key: ValueKey('movie-preview-watchlist-${movie.title}'),
                        icon: _inWatchlist
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.heart,
                        onPressed: _toggleWatchlist,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailHeroHeader extends StatelessWidget {
  const _DetailHeroHeader({required this.movie, required this.heroTag});

  final MovieView movie;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 430;
    final posterWidth = compact ? 154.0 : 178.0;
    final posterHeight = compact ? 232.0 : 266.0;
    final titleSize = compact ? 27.0 : 30.0;
    final poster = _DetailPoster(movie: movie);
    return ClipRect(
      child: SizedBox(
        height: compact ? 418 : 468,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _DetailBackdrop(movie: movie),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    CupertinoColors.black.withValues(alpha: 0.14),
                    CupertinoColors.black.withValues(alpha: 0.52),
                    palette.background.withValues(alpha: 0.96),
                    palette.background,
                  ],
                  stops: const [0, 0.58, 0.90, 1],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 34,
              child: ColoredBox(color: palette.background),
            ),
            SafeArea(
              top: true,
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(22, compact ? 54 : 66, 22, 54),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: SizedBox(
                            width: posterWidth,
                            height: posterHeight,
                            child: heroTag == null
                                ? poster
                                : Hero(tag: heroTag!, child: poster),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      movie.title.replaceAll('\n', ' '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: titleSize,
                        height: 1.02,
                        fontWeight: FontWeight.w900,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailBackdrop extends StatelessWidget {
  const _DetailBackdrop({required this.movie});

  final MovieView movie;

  @override
  Widget build(BuildContext context) {
    final posterUrl = movie.posterUrl;
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: movie.palette,
            ),
          ),
        ),
        if (posterUrl != null)
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Transform.scale(
              scale: 1.18,
              child: Image.network(
                posterUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),
      ],
    );
  }
}

class _DetailPoster extends StatelessWidget {
  const _DetailPoster({required this.movie});

  final MovieView movie;

  @override
  Widget build(BuildContext context) {
    final posterUrl = movie.posterUrl;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: CupertinoColors.white.withValues(alpha: 0.26),
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.42),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: posterUrl == null
            ? _PosterFallback(movie: movie)
            : Image.network(
                posterUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _PosterFallback(movie: movie),
              ),
      ),
    );
  }
}

class _PosterFallback extends StatelessWidget {
  const _PosterFallback({required this.movie});

  final MovieView movie;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: movie.palette,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            movie.title.replaceAll('\n', ' '),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              height: 1,
              fontWeight: FontWeight.w900,
              color: CupertinoColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.movie,
    required this.onOpenTrailer,
    required this.onRate,
  });

  final MovieView movie;
  final VoidCallback onOpenTrailer;
  final VoidCallback onRate;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    final canOpenTrailer = movie.trailerUrl != null || movie.tmdbId != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: palette.surface,
        border: Border.all(color: palette.tagBackground),
        boxShadow: [
          BoxShadow(
            color: palette.shadow.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            if (canOpenTrailer) ...[
              Expanded(
                flex: 5,
                child: _DetailActionButton(
                  key: ValueKey('movie-preview-trailer-${movie.title}'),
                  label: 'Trailer',
                  icon: CupertinoIcons.play_fill,
                  prominent: true,
                  onPressed: onOpenTrailer,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              flex: 3,
              child: _DetailActionButton(
                key: ValueKey('movie-preview-rate-${movie.title}'),
                label: 'Rate',
                icon: CupertinoIcons.star_fill,
                onPressed: onRate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsGrid extends StatelessWidget {
  const _DetailsGrid({required this.movie, required this.userRating});

  final MovieView movie;
  final double? userRating;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _DetailMetric(label: 'Year', value: movie.year.toString()),
        _DetailMetric(label: 'Runtime', value: '${movie.runtimeMinutes} min'),
        _DetailMetric(label: 'Age', value: movie.ageRating),
        _DetailMetric(
          label: 'Cinerate',
          value: movie.rating.toStringAsFixed(1),
        ),
        _DetailMetric(
          label: 'Your rating',
          value: userRating?.toStringAsFixed(1) ?? 'Not rated',
        ),
      ],
    );
  }
}

class _CastList extends StatelessWidget {
  const _CastList({required this.cast});

  final List<MovieCastCredit> cast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final member in cast)
          _InfoRow(title: member.name, subtitle: member.roleName),
      ],
    );
  }
}

class _ReviewList extends StatelessWidget {
  const _ReviewList({required this.reviews});

  final List<MovieReviewSnippet> reviews;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final review in reviews)
          _ReviewCard(
            author: review.authorName,
            rating: review.rating,
            quote: review.quote,
          ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.author,
    required this.rating,
    required this.quote,
  });

  final String author;
  final double rating;
  final String quote;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: palette.surface,
        border: Border.all(color: palette.tagBackground),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  author,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: palette.textPrimary,
                  ),
                ),
              ),
              Text(
                '${rating.toStringAsFixed(1)} stars',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: palette.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            quote,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: palette.surface,
        border: Border.all(color: palette.tagBackground),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: palette.textPrimary,
              ),
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 19,
        fontWeight: FontWeight.w900,
        color: context.cineratePalette.textPrimary,
      ),
    );
  }
}

class _StreamingChip extends StatelessWidget {
  const _StreamingChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: palette.surface,
        border: Border.all(color: palette.tagBackground),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: palette.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: palette.surfaceAlt,
        border: Border.all(color: palette.tagBackground),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: palette.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _DetailMetric extends StatelessWidget {
  const _DetailMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    return Container(
      width: 128,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: palette.surface,
        border: Border.all(color: palette.tagBackground),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: palette.textSecondary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: palette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailActionButton extends StatelessWidget {
  const _DetailActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.prominent = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    final background = prominent ? palette.primary : palette.surface;
    final foreground = prominent ? CupertinoColors.white : palette.textPrimary;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(44, 46),
      borderRadius: BorderRadius.circular(18),
      onPressed: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: background,
          border: Border.all(
            color: prominent
                ? CupertinoColors.white.withValues(alpha: 0.16)
                : palette.tagBackground,
          ),
        ),
        child: SizedBox(
          height: 46,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: foreground),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(40, 40),
      borderRadius: BorderRadius.circular(20),
      onPressed: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: CupertinoColors.black.withValues(alpha: 0.38),
          border: Border.all(
            color: CupertinoColors.white.withValues(alpha: 0.18),
          ),
        ),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 18, color: CupertinoColors.white),
        ),
      ),
    );
  }
}
