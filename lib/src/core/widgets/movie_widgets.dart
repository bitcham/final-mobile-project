import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';

import '../models/movie_view.dart';
import '../theme/app_theme.dart';
import 'movie_dialogs.dart';

class LiquidGlassPane extends StatelessWidget {
  const LiquidGlassPane({
    super.key,
    required this.child,
    this.borderRadius = 22,
    this.padding = EdgeInsets.zero,
    this.tint,
    this.tintOpacity = 0.18,
    this.blurSigma = 20,
    this.shadowOpacity = 0.16,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? tint;
  final double tintOpacity;
  final double blurSigma;
  final double shadowOpacity;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    final isDark = palette.brightness == Brightness.dark;
    final baseTint = tint ?? (isDark ? CupertinoColors.white : palette.surface);
    final radius = BorderRadius.circular(borderRadius);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: shadowOpacity <= 0
            ? const []
            : [
                BoxShadow(
                  color: CupertinoColors.black.withValues(
                    alpha: isDark ? shadowOpacity : shadowOpacity * 0.46,
                  ),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              color: baseTint.withValues(alpha: tintOpacity),
              border: Border.all(
                color: CupertinoColors.white.withValues(
                  alpha: isDark ? 0.16 : 0.50,
                ),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  CupertinoColors.white.withValues(alpha: isDark ? 0.12 : 0.46),
                  CupertinoColors.white.withValues(alpha: isDark ? 0.04 : 0.14),
                ],
              ),
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

/// Poster artwork with a rating badge, used in shelves and search rows.
///
/// Tapping opens the shared movie-details dialog unless [onPressed] overrides
/// it.
class PosterTile extends StatelessWidget {
  const PosterTile({
    super.key,
    required this.movie,
    required this.userRating,
    required this.onOpenTrailer,
    required this.onRateMovie,
    this.onPressed,
    this.heroTag,
    this.large = false,
    this.searchSize = false,
    this.inWatchlist = false,
    this.onToggleWatchlist,
    this.resolveMovieDetails,
  });

  final MovieView movie;
  final double? userRating;
  final Future<void> Function(MovieView movie) onOpenTrailer;
  final void Function(MovieView movie, double rating) onRateMovie;
  final VoidCallback? onPressed;
  final Object? heroTag;
  final bool large;
  final bool searchSize;
  final bool inWatchlist;
  final void Function(MovieView movie)? onToggleWatchlist;
  final Future<MovieView> Function(MovieView movie)? resolveMovieDetails;

  @override
  Widget build(BuildContext context) {
    final width = searchSize ? 116.0 : (large ? 112.0 : double.infinity);
    final height = searchSize ? 174.0 : (large ? 174.0 : double.infinity);
    final tile = SizedBox(
      width: width,
      height: height,
      child: _MaybeHero(
        tag: heroTag,
        child: _MoviePosterFrame(
          movie: movie,
          large: large,
          borderRadius: BorderRadius.circular(large ? 18 : 14),
        ),
      ),
    );

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed:
          onPressed ??
          () => showMovieDetails(
            context,
            movie,
            userRating: userRating,
            onOpenTrailer: onOpenTrailer,
            onRateMovie: onRateMovie,
            inWatchlist: inWatchlist,
            onToggleWatchlist: onToggleWatchlist,
            heroTag: heroTag,
            resolveMovieDetails: resolveMovieDetails,
          ),
      child: tile,
    );
  }
}

class _MaybeHero extends StatelessWidget {
  const _MaybeHero({required this.tag, required this.child});

  final Object? tag;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tag = this.tag;
    if (tag == null) {
      return child;
    }
    return Hero(tag: tag, child: child);
  }
}

class _MoviePosterFrame extends StatelessWidget {
  const _MoviePosterFrame({
    required this.movie,
    required this.large,
    required this.borderRadius,
  });

  final MovieView movie;
  final bool large;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final fallbackPoster = _PosterFallbackArt(movie: movie, large: large);
    final palette = context.cineratePalette;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: palette.shadow.withValues(alpha: 0.46),
            blurRadius: large ? 26 : 18,
            offset: Offset(0, large ? 14 : 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: CupertinoColors.white.withValues(alpha: 0.08),
            border: Border.all(
              color: CupertinoColors.white.withValues(alpha: 0.18),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(large ? 15 : 11),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (movie.posterUrl != null)
                    Positioned.fill(
                      child: Image.network(
                        movie.posterUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            fallbackPoster,
                      ),
                    )
                  else
                    Positioned.fill(child: fallbackPoster),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          CupertinoColors.white.withValues(alpha: 0.05),
                          CupertinoColors.transparent,
                          CupertinoColors.black.withValues(alpha: 0.44),
                        ],
                        stops: const [0, 0.54, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 8,
                    child: Center(child: RatingBadge(rating: movie.rating)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PosterFallbackArt extends StatelessWidget {
  const _PosterFallbackArt({required this.movie, required this.large});

  final MovieView movie;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
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
        CustomPaint(painter: _PosterTexturePainter(movie.palette)),
        Positioned(
          left: 8,
          right: 8,
          top: 12,
          child: Text(
            movie.title.replaceAll('\n', ' '),
            maxLines: large ? 3 : 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: large ? 18 : 13,
              height: 0.95,
              fontWeight: FontWeight.w900,
              color: palette.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _PosterTexturePainter extends CustomPainter {
  const _PosterTexturePainter(this.palette);

  final List<Color> palette;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CupertinoColors.black.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromLTWH(
        -size.width * 0.35,
        size.height * 0.18,
        size.width,
        size.height,
      ),
      paint,
    );

    final highlight = Paint()
      ..color = palette.first.withValues(alpha: 0.28)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.2),
      size.width * 0.38,
      highlight,
    );

    final slash = Paint()
      ..color = CupertinoColors.white.withValues(alpha: 0.1)
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.95),
      Offset(size.width * 0.95, size.height * 0.12),
      slash,
    );
  }

  @override
  bool shouldRepaint(covariant _PosterTexturePainter oldDelegate) {
    return oldDelegate.palette != palette;
  }
}

class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassPane(
      borderRadius: 15,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      tint: CupertinoColors.black,
      tintOpacity: 0.34,
      blurSigma: 14,
      shadowOpacity: 0.10,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.star_fill,
            color: Color(0xFFFFC928),
            size: 13,
          ),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              height: 1.0,
              fontWeight: FontWeight.w800,
              color: CupertinoColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class GenrePill extends StatelessWidget {
  const GenrePill(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassPane(
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      tint: CupertinoColors.black,
      tintOpacity: 0.18,
      blurSigma: 14,
      shadowOpacity: 0.08,
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: CupertinoColors.white,
        ),
      ),
    );
  }
}

class TinyGenrePill extends StatelessWidget {
  const TinyGenrePill(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: palette.surfaceAlt.withValues(
          alpha: palette.brightness == Brightness.dark ? 0.62 : 0.78,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.tagBackground),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: palette.textSecondary,
        ),
      ),
    );
  }
}

class RoundedActionButton extends StatelessWidget {
  const RoundedActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isLightButton = color.computeLuminance() > 0.72;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(22),
      minimumSize: const Size(38, 38),
      onPressed: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: color,
          border: Border.all(
            color:
                (isLightButton ? CupertinoColors.black : CupertinoColors.white)
                    .withValues(alpha: isLightButton ? 0.08 : 0.18),
          ),
          boxShadow: [
            BoxShadow(
              color: (isLightButton ? CupertinoColors.black : color).withValues(
                alpha: isLightButton ? 0.18 : 0.26,
              ),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SizedBox(
          height: 42,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 17),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: textColor,
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

class CircleActionButton extends StatelessWidget {
  const CircleActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(24),
      minimumSize: const Size(42, 42),
      onPressed: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: palette.brightness == Brightness.dark
              ? CupertinoColors.white
              : palette.surface,
          border: Border.all(
            color: CupertinoColors.black.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: const Color(0xFF161A22), size: 18),
        ),
      ),
    );
  }
}
