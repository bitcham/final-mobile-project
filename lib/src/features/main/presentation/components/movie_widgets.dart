part of '../main_tab_screen.dart';

class _PosterTile extends StatelessWidget {
  const _PosterTile({
    super.key,
    required this.movie,
    required this.userRating,
    required this.onOpenTrailer,
    required this.onRateMovie,
    this.onPressed,
    this.large = false,
    this.searchSize = false,
  });

  final _DesignMovie movie;
  final double? userRating;
  final Future<void> Function(_DesignMovie movie) onOpenTrailer;
  final void Function(_DesignMovie movie, double rating) onRateMovie;
  final VoidCallback? onPressed;
  final bool large;
  final bool searchSize;

  @override
  Widget build(BuildContext context) {
    final width = searchSize ? 86.0 : (large ? 112.0 : double.infinity);
    final height = searchSize ? 140.0 : (large ? 174.0 : double.infinity);
    final fallbackPoster = _PosterFallbackArt(movie: movie, large: large);

    final tile = SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(large ? 18 : 14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (movie.posterUrl != null)
              Positioned.fill(
                child: Image.network(
                  movie.posterUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => fallbackPoster,
                ),
              )
            else
              Positioned.fill(child: fallbackPoster),
            Positioned(
              left: 8,
              bottom: 8,
              child: _RatingBadge(rating: movie.rating),
            ),
          ],
        ),
      ),
    );
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed:
          onPressed ??
          () => _showMovieDetails(
            context,
            movie,
            userRating: userRating,
            onOpenTrailer: onOpenTrailer,
            onRateMovie: onRateMovie,
          ),
      child: tile,
    );
  }
}

class _PosterFallbackArt extends StatelessWidget {
  const _PosterFallbackArt({required this.movie, required this.large});

  final _DesignMovie movie;
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

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: CupertinoColors.black.withValues(alpha: 0.62),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
              fontWeight: FontWeight.w800,
              color: CinerateColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _GenrePill extends StatelessWidget {
  const _GenrePill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: CupertinoColors.black.withValues(alpha: 0.46),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: CupertinoColors.white,
        ),
      ),
    );
  }
}

class _TinyGenrePill extends StatelessWidget {
  const _TinyGenrePill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.tagBackground),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 7,
          color: palette.textSecondary,
        ),
      ),
    );
  }
}

class _RoundedActionButton extends StatelessWidget {
  const _RoundedActionButton({
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
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      borderRadius: BorderRadius.circular(22),
      color: color,
      minimumSize: const Size(38, 38),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 17),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
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
      color: palette.brightness == Brightness.dark
          ? const Color(0xFFEDEDED)
          : palette.surfaceAlt,
      minimumSize: const Size(42, 42),
      onPressed: onPressed,
      child: Icon(icon, color: const Color(0xFF161A22), size: 18),
    );
  }
}
