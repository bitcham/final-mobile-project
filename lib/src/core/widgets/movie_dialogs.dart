import 'package:flutter/cupertino.dart';

import '../models/movie_view.dart';
import '../theme/app_theme.dart';
import 'movie_detail_screen.dart';

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
  Object? heroTag,
  Future<MovieView> Function(MovieView movie)? resolveMovieDetails,
}) {
  return Navigator.of(context).push<void>(
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (routeContext, animation, secondaryAnimation) =>
          MovieDetailScreen(
            movie: movie,
            userRating: userRating,
            inWatchlist: inWatchlist,
            heroTag: heroTag,
            onOpenTrailer: onOpenTrailer,
            onToggleWatchlist: onToggleWatchlist,
            resolveMovieDetails: resolveMovieDetails,
            onRatePressed: (sheetContext, ratedMovie, initialRating) async {
              final rating = await showRatingRangeSheet(
                sheetContext,
                initialRating: initialRating,
                title: 'Your Rating',
                valueSuffix: ' ★',
                applyLabel: 'Save rating',
              );
              if (rating != null) {
                onRateMovie(ratedMovie, rating);
              }
              return rating;
            },
          ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.035),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    ),
  );
}
