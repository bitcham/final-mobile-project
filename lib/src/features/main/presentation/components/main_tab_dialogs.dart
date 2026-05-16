part of '../main_tab_screen.dart';

const Object _noSelection = Object();

class _Option<T> {
  const _Option({required this.label, this.value});

  final String label;
  final T? value;
}

class _SheetSelection {
  const _SheetSelection(this.value);

  final Object? value;
}

Future<Object?> _showOptionSheet<T>(
  BuildContext context, {
  required String title,
  required List<_Option<T>> options,
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
  return selected == null ? _noSelection : selected.value;
}

double _normalizeRating(double rating) {
  return (rating.clamp(0.0, 5.0) * 10).round() / 10;
}

const int _minimumFilterYear = 1920;
const int _maximumFilterYear = 2026;

Future<int?> _showYearRangeSheet(
  BuildContext context, {
  required int initialYear,
}) {
  return showCupertinoModalPopup<int>(
    context: context,
    useRootNavigator: false,
    builder: (context) {
      var draftYear = initialYear.clamp(_minimumFilterYear, _maximumFilterYear);

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
                          min: _minimumFilterYear.toDouble(),
                          max: _maximumFilterYear.toDouble(),
                          divisions: _maximumFilterYear - _minimumFilterYear,
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

Future<double?> _showRatingRangeSheet(
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
      var draftRating = _normalizeRating(initialRating);

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
                              draftRating = _normalizeRating(value);
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

Future<void> _showInfoDialog(
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

Future<void> _showWatchlistDialog(
  BuildContext context,
  List<_DesignMovie> movies,
) {
  final content = movies.isEmpty
      ? 'No movies saved yet.'
      : movies.map((movie) => movie.title).join('\n');

  return showCupertinoDialog<void>(
    context: context,
    useRootNavigator: false,
    builder: (context) => CupertinoAlertDialog(
      title: const Text('My watchlist'),
      content: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(content),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

Future<void> _showRatingHistoryDialog(
  BuildContext context,
  List<_RatingHistoryEntry> history,
) {
  final content = history.isEmpty
      ? 'No rating history yet.'
      : history
            .map(
              (entry) =>
                  '${entry.movie.title} - ${entry.rating.toStringAsFixed(1)} ★',
            )
            .join('\n');

  return showCupertinoDialog<void>(
    context: context,
    useRootNavigator: false,
    builder: (context) => CupertinoAlertDialog(
      title: const Text('Rating history'),
      content: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(content),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

Future<void> _showMovieDetails(
  BuildContext context,
  _DesignMovie movie, {
  required double? userRating,
  required Future<void> Function(_DesignMovie movie) onOpenTrailer,
  required void Function(_DesignMovie movie, double rating) onRateMovie,
}) {
  final ratingText = userRating == null
      ? 'Your rating: Not rated'
      : 'Your rating: ${userRating.toStringAsFixed(1)} ★';

  return showCupertinoDialog<void>(
    context: context,
    useRootNavigator: false,
    builder: (dialogContext) => CupertinoAlertDialog(
      title: Text(movie.title.replaceAll('\n', ' ')),
      content: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          '${movie.year} • ${movie.rating.toStringAsFixed(1)} ★\n'
          '$ratingText\n'
          '${movie.genres.join(', ')}\n\n${movie.synopsis}',
        ),
      ),
      actions: [
        if (movie.trailerUrl != null)
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onOpenTrailer(movie);
            },
            child: const Text('Watch Trailer'),
          ),
        CupertinoDialogAction(
          onPressed: () async {
            Navigator.of(dialogContext).pop();
            if (!context.mounted) {
              return;
            }
            final rating = await _showRatingRangeSheet(
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
          child: const Text('Rate'),
        ),
        CupertinoDialogAction(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

Future<void> _showTrendingDialog(BuildContext context) {
  return showCupertinoDialog<void>(
    context: context,
    useRootNavigator: false,
    builder: (context) => CupertinoAlertDialog(
      title: const Text('All trending'),
      content: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(_trendingMovies.map((movie) => movie.title).join('\n')),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

Future<void> _showHomeMenu(
  BuildContext context, {
  required VoidCallback onOpenSearch,
  required VoidCallback onOpenSettings,
}) {
  return showCupertinoModalPopup<void>(
    context: context,
    useRootNavigator: false,
    builder: (context) => CupertinoActionSheet(
      title: const Text('Quick menu'),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(context).pop();
            onOpenSearch();
          },
          child: const Text('Search'),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(context).pop();
            onOpenSettings();
          },
          child: const Text('Settings'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
    ),
  );
}

Future<void> _showFiltersDialog(
  BuildContext context, {
  required VoidCallback onReset,
}) {
  return showCupertinoDialog<void>(
    context: context,
    useRootNavigator: false,
    builder: (context) => CupertinoAlertDialog(
      title: const Text('Filters'),
      content: const Padding(
        padding: EdgeInsets.only(top: 10),
        child: Text(
          'Use the Year, Rating, and Sort controls to refine search.',
        ),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () {
            onReset();
            Navigator.of(context).pop();
          },
          child: const Text('Reset'),
        ),
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    ),
  );
}
