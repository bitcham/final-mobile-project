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
