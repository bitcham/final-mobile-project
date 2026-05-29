import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../models/movie_view.dart';
import '../theme/app_theme.dart';

/// Sentinel returned by [showOptionSheet] when the sheet is dismissed.
const Object kNoSelection = Object();

class SheetOption<T> {
  const SheetOption({required this.label, this.value});

  final String label;
  final T? value;
}

class _SheetSelection {
  const _SheetSelection(this.value);

  final Object? value;
}

/// Shows a Cupertino action sheet and returns the chosen value, or
/// [kNoSelection] when dismissed.
Future<Object?> showOptionSheet<T>(
  BuildContext context, {
  required String title,
  required List<SheetOption<T>> options,
}) async {
  final selected = await showCupertinoModalPopup<_SheetSelection>(
    context: context,
    useRootNavigator: false,
    builder: (context) => CupertinoActionSheet(
      title: Text(title),
      actions: [
        for (final option in options)
          CupertinoActionSheetAction(
            onPressed: () =>
                Navigator.of(context).pop(_SheetSelection(option.value)),
            child: Text(option.label),
          ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
    ),
  );
  return selected == null ? kNoSelection : selected.value;
}

/// Rounds [rating] to one decimal place within the 0–5 range.
double normalizeRating(double rating) {
  return (rating.clamp(0.0, 5.0) * 10).round() / 10;
}

const int kMinimumFilterYear = 1920;
const int kMaximumFilterYear = 2026;

Future<int?> showYearRangeSheet(
  BuildContext context, {
  required int initialYear,
}) {
  return showCupertinoModalPopup<int>(
    context: context,
    useRootNavigator: false,
    builder: (context) {
      var draftYear = initialYear.clamp(kMinimumFilterYear, kMaximumFilterYear);

      return StatefulBuilder(
        builder: (context, setModalState) {
          final palette = context.cineratePalette;
          final presetYears = const [1920, 2008, 2012, 2018, 2021, 2024, 2026];
          final sheetMaxHeight = MediaQuery.sizeOf(context).height - 24;

          return SafeArea(
            top: true,
            child: Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 720,
                  maxHeight: sheetMaxHeight,
                ),
                child: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: palette.shadow,
                        blurRadius: 28,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Year Range',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: palette.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          draftYear.toString(),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: palette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        CupertinoSlider(
                          min: kMinimumFilterYear.toDouble(),
                          max: kMaximumFilterYear.toDouble(),
                          divisions: kMaximumFilterYear - kMinimumFilterYear,
                          value: draftYear.toDouble(),
                          activeColor: palette.primary,
                          onChanged: (value) {
                            setModalState(() {
                              draftYear = value.round();
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [Text('1920'), Text('2026')],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final year in presetYears)
                              CupertinoButton(
                                key: ValueKey('year-preset-$year'),
                                minimumSize: const Size(34, 34),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                color: draftYear == year
                                    ? palette.primary
                                    : palette.surfaceAlt,
                                borderRadius: BorderRadius.circular(18),
                                onPressed: () {
                                  setModalState(() {
                                    draftYear = year;
                                  });
                                },
                                child: Text(
                                  year.toString(),
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: draftYear == year
                                        ? CupertinoColors.white
                                        : palette.textPrimary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: CupertinoButton(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(44, 42),
                                color: palette.surfaceAlt,
                                borderRadius: BorderRadius.circular(16),
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w800,
                                    color: palette.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CupertinoButton(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(44, 42),
                                color: palette.primary,
                                borderRadius: BorderRadius.circular(16),
                                onPressed: () =>
                                    Navigator.of(context).pop(draftYear),
                                child: const Text(
                                  'Apply',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w800,
                                    color: CupertinoColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Future<double?> showRatingRangeSheet(
  BuildContext context, {
  required double initialRating,
  String title = 'Rating Range',
  String valueSuffix = '+',
  String applyLabel = 'Apply',
}) {
  return showCupertinoModalPopup<double>(
    context: context,
    useRootNavigator: false,
    builder: (context) {
      var draftRating = normalizeRating(initialRating);

      return StatefulBuilder(
        builder: (context, setModalState) {
          final palette = context.cineratePalette;
          final presetRatings = const [0.0, 1.0, 2.0, 3.0, 4.0, 4.5, 5.0];
          final ratingLabel = draftRating.toStringAsFixed(1);
          final sheetMaxHeight = MediaQuery.sizeOf(context).height - 24;

          return SafeArea(
            top: true,
            child: Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 720,
                  maxHeight: sheetMaxHeight,
                ),
                child: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: palette.shadow,
                        blurRadius: 28,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: palette.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$ratingLabel$valueSuffix',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: palette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        CupertinoSlider(
                          min: 0.0,
                          max: 5.0,
                          divisions: 50,
                          value: draftRating,
                          activeColor: palette.primary,
                          onChanged: (value) {
                            setModalState(() {
                              draftRating = normalizeRating(value);
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [Text('0.0'), Text('5.0')],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final rating in presetRatings)
                              CupertinoButton(
                                key: ValueKey(
                                  'rating-preset-${rating.toStringAsFixed(1)}',
                                ),
                                minimumSize: const Size(34, 34),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                color: draftRating == rating
                                    ? palette.primary
                                    : palette.surfaceAlt,
                                borderRadius: BorderRadius.circular(18),
                                onPressed: () {
                                  setModalState(() {
                                    draftRating = rating;
                                  });
                                },
                                child: Text(
                                  rating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: draftRating == rating
                                        ? CupertinoColors.white
                                        : palette.textPrimary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: CupertinoButton(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(44, 42),
                                color: palette.surfaceAlt,
                                borderRadius: BorderRadius.circular(16),
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w800,
                                    color: palette.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CupertinoButton(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(44, 42),
                                color: palette.primary,
                                borderRadius: BorderRadius.circular(16),
                                onPressed: () =>
                                    Navigator.of(context).pop(draftRating),
                                child: Text(
                                  applyLabel,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w800,
                                    color: CupertinoColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Future<void> showInfoDialog(
  BuildContext context, {
  required String title,
  required String message,
}) {
  return showCupertinoDialog<void>(
    context: context,
    useRootNavigator: false,
    builder: (context) => CupertinoAlertDialog(
      title: Text(title),
      content: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(message),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

Future<void> showMovieDetails(
  BuildContext context,
  MovieView movie, {
  required double? userRating,
  required Future<void> Function(MovieView movie) onOpenTrailer,
  required void Function(MovieView movie, double rating) onRateMovie,
  bool inWatchlist = false,
  void Function(MovieView movie)? onToggleWatchlist,
}) {
  final canOpenTrailer = movie.trailerUrl != null || movie.tmdbId != null;
  return showCupertinoModalPopup<void>(
    context: context,
    useRootNavigator: false,
    barrierColor: CupertinoColors.black.withValues(alpha: 0.48),
    builder: (dialogContext) => _MovieDetailsSheet(
      movie: movie,
      userRating: userRating,
      inWatchlist: inWatchlist,
      canOpenTrailer: canOpenTrailer,
      onClose: () => Navigator.of(dialogContext).pop(),
      onOpenTrailer: () {
        Navigator.of(dialogContext).pop();
        onOpenTrailer(movie);
      },
      onRate: () async {
        Navigator.of(dialogContext).pop();
        if (!context.mounted) {
          return;
        }
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
      onToggleWatchlist: onToggleWatchlist == null
          ? null
          : () {
              Navigator.of(dialogContext).pop();
              onToggleWatchlist(movie);
            },
    ),
  );
}

class _MovieDetailsSheet extends StatelessWidget {
  const _MovieDetailsSheet({
    required this.movie,
    required this.userRating,
    required this.inWatchlist,
    required this.canOpenTrailer,
    required this.onClose,
    required this.onOpenTrailer,
    required this.onRate,
    required this.onToggleWatchlist,
  });

  final MovieView movie;
  final double? userRating;
  final bool inWatchlist;
  final bool canOpenTrailer;
  final VoidCallback onClose;
  final VoidCallback onOpenTrailer;
  final VoidCallback onRate;
  final VoidCallback? onToggleWatchlist;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 420;
    final posterWidth = compact ? 78.0 : 94.0;
    final posterHeight = compact ? 118.0 : 142.0;
    final userRatingLabel = userRating == null
        ? 'Not rated'
        : '${userRating!.toStringAsFixed(1)} ★';

    return SafeArea(
      key: ValueKey('movie-preview-${movie.title}'),
      top: true,
      bottom: true,
      child: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 560,
              maxHeight: size.height - 28,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: palette.surface,
                border: Border.all(
                  color: CupertinoColors.white.withValues(
                    alpha: palette.brightness == Brightness.dark ? 0.12 : 0.50,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: palette.shadow.withValues(alpha: 0.55),
                    blurRadius: 34,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: compact ? 208 : 232,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _MoviePreviewBackdrop(movie: movie),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    CupertinoColors.black.withValues(
                                      alpha: 0.10,
                                    ),
                                    CupertinoColors.black.withValues(
                                      alpha: 0.30,
                                    ),
                                    CupertinoColors.black.withValues(
                                      alpha: 0.76,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: _PreviewIconButton(
                                icon: CupertinoIcons.xmark,
                                onPressed: onClose,
                              ),
                            ),
                            Positioned(
                              left: 18,
                              right: 18,
                              bottom: 16,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    width: posterWidth,
                                    height: posterHeight,
                                    child: _MoviePreviewPoster(movie: movie),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          movie.title.replaceAll('\n', ' '),
                                          maxLines: compact ? 2 : 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: compact ? 24 : 30,
                                            height: 1.02,
                                            fontWeight: FontWeight.w900,
                                            color: CupertinoColors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Wrap(
                                          spacing: 7,
                                          runSpacing: 7,
                                          children: [
                                            _PreviewMetaPill(
                                              label: movie.year.toString(),
                                            ),
                                            _PreviewMetaPill(
                                              label:
                                                  '${movie.rating.toStringAsFixed(1)} ★',
                                            ),
                                            _PreviewMetaPill(
                                              label: userRatingLabel,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              movie.synopsis,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                height: 1.45,
                                fontWeight: FontWeight.w600,
                                color: palette.textPrimary,
                              ),
                            ),
                            if (movie.genres.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: movie.genres
                                    .map(_PreviewGenreChip.new)
                                    .toList(),
                              ),
                            ],
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                if (canOpenTrailer) ...[
                                  Expanded(
                                    flex: 2,
                                    child: _PreviewActionButton(
                                      key: ValueKey(
                                        'movie-preview-trailer-${movie.title}',
                                      ),
                                      label: 'Watch Trailer',
                                      icon: CupertinoIcons.play_fill,
                                      prominent: true,
                                      onPressed: onOpenTrailer,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                                Expanded(
                                  child: _PreviewActionButton(
                                    key: ValueKey(
                                      'movie-preview-rate-${movie.title}',
                                    ),
                                    label: 'Rate',
                                    icon: CupertinoIcons.star_fill,
                                    onPressed: onRate,
                                  ),
                                ),
                                if (onToggleWatchlist != null) ...[
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _PreviewActionButton(
                                      key: ValueKey(
                                        'movie-preview-watchlist-${movie.title}',
                                      ),
                                      label: inWatchlist ? 'Liked' : 'Like',
                                      icon: inWatchlist
                                          ? CupertinoIcons.heart_fill
                                          : CupertinoIcons.heart,
                                      onPressed: onToggleWatchlist!,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MoviePreviewBackdrop extends StatelessWidget {
  const _MoviePreviewBackdrop({required this.movie});

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

    return Stack(
      fit: StackFit.expand,
      children: [
        fallback,
        if (posterUrl != null)
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Transform.scale(
              scale: 1.16,
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

class _MoviePreviewPoster extends StatelessWidget {
  const _MoviePreviewPoster({required this.movie});

  final MovieView movie;

  @override
  Widget build(BuildContext context) {
    final posterUrl = movie.posterUrl;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CupertinoColors.white.withValues(alpha: 0.34),
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.32),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: posterUrl == null
            ? _MovieFallbackPoster(movie: movie)
            : Image.network(
                posterUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _MovieFallbackPoster(movie: movie),
              ),
      ),
    );
  }
}

class _MovieFallbackPoster extends StatelessWidget {
  const _MovieFallbackPoster({required this.movie});

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
        padding: const EdgeInsets.all(10),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            movie.title.replaceAll('\n', ' '),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
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

class _PreviewMetaPill extends StatelessWidget {
  const _PreviewMetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: CupertinoColors.black.withValues(alpha: 0.36),
        border: Border.all(
          color: CupertinoColors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: CupertinoColors.white,
          ),
        ),
      ),
    );
  }
}

class _PreviewGenreChip extends StatelessWidget {
  const _PreviewGenreChip(this.label);

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

class _PreviewActionButton extends StatelessWidget {
  const _PreviewActionButton({
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
    final background = prominent ? palette.primary : palette.surfaceAlt;
    final foreground = prominent ? CupertinoColors.white : palette.textPrimary;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(44, 44),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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

class _PreviewIconButton extends StatelessWidget {
  const _PreviewIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(36, 36),
      borderRadius: BorderRadius.circular(18),
      onPressed: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: CupertinoColors.black.withValues(alpha: 0.36),
          border: Border.all(
            color: CupertinoColors.white.withValues(alpha: 0.20),
          ),
        ),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 15, color: CupertinoColors.white),
        ),
      ),
    );
  }
}
