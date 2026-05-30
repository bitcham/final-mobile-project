part of '../main_tab_screen.dart';

Future<void> _showWatchlistDialog(
  BuildContext context,
  List<MovieView> movies,
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

Future<void> _showTrendingDialog(BuildContext context, List<MovieView> movies) {
  return showCupertinoDialog<void>(
    context: context,
    useRootNavigator: false,
    builder: (context) => CupertinoAlertDialog(
      title: const Text('All trending'),
      content: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(movies.map((movie) => movie.title).join('\n')),
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
  required _HomeCategoryFilter currentFilter,
  required ValueChanged<_HomeCategoryFilter> onSelectFilter,
}) {
  return showCupertinoModalPopup<void>(
    context: context,
    useRootNavigator: false,
    builder: (context) => CupertinoActionSheet(
      title: const Text('Filter homepage'),
      actions: [
        for (final filter in _HomeCategoryFilter.values)
          CupertinoActionSheetAction(
            key: ValueKey('home-filter-${filter.name}'),
            isDefaultAction: filter == currentFilter,
            onPressed: () {
              Navigator.of(context).pop();
              onSelectFilter(filter);
            },
            child: Text(filter.label),
          ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
    ),
  );
}
