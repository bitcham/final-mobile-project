import 'package:flutter/cupertino.dart';
import 'package:movie_rating/src/core/models/movie_view.dart';
import 'package:movie_rating/src/core/theme/cinerate_palette.dart';
import 'package:movie_rating/src/core/widgets/movie_dialogs.dart';
import 'package:movie_rating/src/core/widgets/movie_widgets.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onVoiceSearch,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onVoiceSearch;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    return SizedBox(
      height: 46,
      child: CupertinoTextField(
        controller: controller,
        onChanged: onChanged,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        placeholder: 'search for movies, series,...',
        placeholderStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 17,
          color: palette.textSecondary,
        ),
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 17,
          color: palette.textPrimary,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: palette.inputBackground,
          border: Border.all(color: palette.tagBackground),
        ),
        prefix: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Icon(
            CupertinoIcons.search,
            size: 22,
            color: palette.textSecondary,
          ),
        ),
        suffix: CupertinoButton(
          padding: const EdgeInsets.only(right: 12),
          minimumSize: const Size(36, 36),
          onPressed: onVoiceSearch,
          child: Icon(
            CupertinoIcons.mic,
            size: 21,
            color: palette.textSecondary,
          ),
        ),
      ),
    );
  }
}

class SearchFilterChip extends StatelessWidget {
  const SearchFilterChip({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onPressed,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: palette.inputBackground,
          border: Border.all(color: palette.tagBackground),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              CupertinoIcons.chevron_down,
              size: 13,
              color: palette.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

class EmptySearchState extends StatelessWidget {
  const EmptySearchState({super.key, this.message = 'No matches'});

  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    return Padding(
      padding: const EdgeInsets.only(top: 72),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            color: palette.textSecondary,
          ),
        ),
      ),
    );
  }
}

class FunnelIcon extends StatelessWidget {
  const FunnelIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FunnelIconPainter(context.cineratePalette.textPrimary),
    );
  }
}

class _FunnelIconPainter extends CustomPainter {
  const _FunnelIconPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.14, size.height * 0.18)
      ..lineTo(size.width * 0.86, size.height * 0.18)
      ..lineTo(size.width * 0.58, size.height * 0.52)
      ..lineTo(size.width * 0.58, size.height * 0.82)
      ..lineTo(size.width * 0.42, size.height * 0.72)
      ..lineTo(size.width * 0.42, size.height * 0.52)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FunnelIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class SearchResultTile extends StatelessWidget {
  const SearchResultTile({
    super.key,
    required this.movie,
    required this.userRating,
    required this.onOpenTrailer,
    required this.onRateMovie,
    required this.inWatchlist,
    required this.onToggleWatchlist,
    required this.resolveTrailer,
  });

  final MovieView movie;
  final double? userRating;
  final Future<void> Function(MovieView movie) onOpenTrailer;
  final void Function(MovieView movie, double rating) onRateMovie;
  final bool inWatchlist;
  final void Function(MovieView movie) onToggleWatchlist;

  final Future<String?> Function(MovieView movie) resolveTrailer;

  Future<void> _openDetails(BuildContext context) async {
    var resolved = movie;
    if (movie.trailerUrl == null && movie.tmdbId != null) {
      final url = await resolveTrailer(movie);
      if (url != null) {
        resolved = movie.copyWith(trailerUrl: url);
      }
    }
    if (!context.mounted) {
      return;
    }
    showMovieDetails(
      context,
      resolved,
      userRating: userRating,
      onOpenTrailer: onOpenTrailer,
      onRateMovie: onRateMovie,
      inWatchlist: inWatchlist,
      onToggleWatchlist: onToggleWatchlist,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: () => _openDetails(context),
      child: SizedBox(
        height: 150,
        child: Row(
          children: [
            PosterTile(
              movie: movie,
              userRating: userRating,
              searchSize: true,
              onPressed: () => _openDetails(context),
              onOpenTrailer: onOpenTrailer,
              onRateMovie: onRateMovie,
              inWatchlist: inWatchlist,
              onToggleWatchlist: onToggleWatchlist,
            ),
            const SizedBox(width: 26),
            Expanded(
              child: Container(
                height: 140,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: palette.surface,
                  border: Border.all(color: palette.textPrimary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Text(
                        movie.synopsis,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          height: 1.55,
                          fontWeight: FontWeight.w700,
                          color: palette.textPrimary,
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 6,
                      children: movie.genres.map(TinyGenrePill.new).toList(),
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
