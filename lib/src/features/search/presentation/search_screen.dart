import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_rating/src/core/models/movie_view.dart';
import 'package:movie_rating/src/core/theme/cinerate_palette.dart';
import 'package:movie_rating/src/core/widgets/movie_dialogs.dart';
import '../data/search_providers.dart';
import '../models/search_filters.dart';
import 'widgets/search_widgets.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({
    super.key,
    required this.userRatings,
    required this.watchlistTitles,
    required this.onOpenTrailer,
    required this.onRateMovie,
    required this.onToggleWatchlist,
  });

  final Map<String, double> userRatings;
  final Set<String> watchlistTitles;
  final Future<void> Function(MovieView movie) onOpenTrailer;
  final void Function(MovieView movie, double rating) onRateMovie;
  final void Function(MovieView movie) onToggleWatchlist;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _queryController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  bool _showJumpTop = false;
  final Map<int, String?> _trailerCache = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _queryController.dispose();
    super.dispose();
  }

  SearchController get _controller =>
      ref.read(searchControllerProvider.notifier);

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 320) {
      _controller.loadMore();
    }
    final shouldShow = position.pixels > 600;
    if (shouldShow != _showJumpTop) {
      setState(() => _showJumpTop = shouldShow);
    }
  }

  void _jumpToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => _controller.setQuery(value),
    );
  }

  Future<void> _pickYear(int? currentYear) async {
    final selected = await showYearRangeSheet(
      context,
      initialYear: currentYear ?? kMaximumFilterYear,
    );
    if (selected != null) {
      _controller.setYear(selected);
    }
  }

  Future<void> _pickRating(double currentRating) async {
    final selected = await showRatingRangeSheet(
      context,
      initialRating: currentRating,
    );
    if (selected != null) {
      _controller.setMinRating(selected);
    }
  }

  Future<void> _pickSort() async {
    final selected = await showOptionSheet<SearchSort>(
      context,
      title: 'Sort By',
      options: const [
        SheetOption(label: 'Default', value: SearchSort.popularity),
        SheetOption(label: 'Rating', value: SearchSort.rating),
      ],
    );
    if (selected is SearchSort) {
      _controller.setSort(selected);
    }
  }

  Future<void> _showFiltersDialog() {
    return showCupertinoDialog<void>(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) => CupertinoAlertDialog(
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
              _queryController.clear();
              _controller.resetFilters();
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Reset'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  double? _userRatingFor(MovieView movie) => widget.userRatings[movie.title];

  Future<String?> _resolveTrailer(MovieView movie) async {
    final id = movie.tmdbId;
    if (id == null) {
      return null;
    }
    if (_trailerCache.containsKey(id)) {
      return _trailerCache[id];
    }
    final url = await ref.read(tmdbApiClientProvider).fetchTrailerUrl(id);
    _trailerCache[id] = url;
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchControllerProvider);
    final filters = state.filters;

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SearchField(
                        controller: _queryController,
                        onChanged: _onQueryChanged,
                        onVoiceSearch: () => showInfoDialog(
                          context,
                          title: 'Voice search',
                          message: 'Listening for a movie, series, or genre.',
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  SearchFilterChip(
                                    label: filters.year?.toString() ?? 'Year',
                                    onPressed: () => _pickYear(filters.year),
                                  ),
                                  const SizedBox(width: 8),
                                  SearchFilterChip(
                                    label: !filters.ratingTouched
                                        ? 'Rating'
                                        : '${filters.minRating.toStringAsFixed(1)}+',
                                    onPressed: () =>
                                        _pickRating(filters.minRating),
                                  ),
                                  const SizedBox(width: 8),
                                  SearchFilterChip(
                                    label: filters.sort == SearchSort.rating
                                        ? 'Rating'
                                        : 'Sort By',
                                    onPressed: _pickSort,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(36, 36),
                            onPressed: _showFiltersDialog,
                            child: const SizedBox(
                              width: 32,
                              height: 32,
                              child: FunnelIcon(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ..._buildResultSlivers(state),
            ],
          ),
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: !_showJumpTop,
              child: AnimatedOpacity(
                opacity: _showJumpTop ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: Center(child: _JumpToTopButton(onPressed: _jumpToTop)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildResultSlivers(SearchState state) {
    if (state.isLoading) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CupertinoActivityIndicator()),
        ),
      ];
    }

    if (state.errorMessage != null && state.movies.isEmpty) {
      return [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 30, 18, 112),
          sliver: SliverToBoxAdapter(
            child: EmptySearchState(message: state.errorMessage!),
          ),
        ),
      ];
    }

    if (state.movies.isEmpty) {
      return const [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(18, 30, 18, 112),
          sliver: SliverToBoxAdapter(child: EmptySearchState()),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(18, 30, 18, 18),
        sliver: SliverList.separated(
          itemCount: state.movies.length,
          separatorBuilder: (_, _) => const SizedBox(height: 24),
          itemBuilder: (context, index) => SearchResultTile(
            movie: state.movies[index],
            userRating: _userRatingFor(state.movies[index]),
            inWatchlist: widget.watchlistTitles.contains(
              state.movies[index].title,
            ),
            onOpenTrailer: widget.onOpenTrailer,
            onRateMovie: widget.onRateMovie,
            onToggleWatchlist: widget.onToggleWatchlist,
            resolveTrailer: _resolveTrailer,
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.only(bottom: 112),
        sliver: SliverToBoxAdapter(
          child: SizedBox(
            height: 48,
            child: Center(
              child: state.isLoadingMore
                  ? const CupertinoActivityIndicator()
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    ];
  }
}

class _JumpToTopButton extends StatelessWidget {
  const _JumpToTopButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.cineratePalette;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: palette.surface,
          border: Border.all(color: palette.tagBackground),
          boxShadow: [
            BoxShadow(
              color: palette.shadow,
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.chevron_up, size: 15, color: palette.primary),
            const SizedBox(width: 6),
            Text(
              'Jump to top',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: palette.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
