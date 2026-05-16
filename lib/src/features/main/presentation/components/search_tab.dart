part of '../main_tab_screen.dart';

class _SearchTab extends StatefulWidget {
  const _SearchTab({
    required this.userRatings,
    required this.onOpenTrailer,
    required this.onRateMovie,
  });

  final Map<String, double> userRatings;
  final Future<void> Function(_DesignMovie movie) onOpenTrailer;
  final void Function(_DesignMovie movie, double rating) onRateMovie;

  @override
  State<_SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<_SearchTab> {
  final TextEditingController _queryController = TextEditingController();
  int? _year;
  double _minimumRating = 0.0;
  bool _ratingFilterTouched = false;
  String _sortBy = 'Sort By';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  List<_DesignMovie> get _visibleMovies {
    final query = _queryController.text.trim().toLowerCase();
    var movies = _searchMovies.where((movie) {
      final matchesQuery =
          query.isEmpty ||
          movie.title.toLowerCase().contains(query) ||
          movie.synopsis.toLowerCase().contains(query) ||
          movie.genres.any((genre) => genre.toLowerCase().contains(query));
      final matchesYear = _year == null || movie.year == _year;
      final matchesRating = movie.rating >= _minimumRating;
      return matchesQuery && matchesYear && matchesRating;
    }).toList();

    if (_sortBy == 'Rating') {
      movies.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_sortBy == 'Title') {
      movies.sort((a, b) => a.title.compareTo(b.title));
    }
    return movies;
  }

  double? _userRatingFor(_DesignMovie movie) {
    return widget.userRatings[movie.title];
  }

  Future<void> _pickYear() async {
    final selected = await _showYearRangeSheet(
      context,
      initialYear: _year ?? _maximumFilterYear,
    );
    if (selected != null) {
      setState(() => _year = selected);
    }
  }

  Future<void> _pickRating() async {
    final selected = await _showRatingRangeSheet(
      context,
      initialRating: _minimumRating,
    );
    if (selected != null) {
      setState(() {
        _minimumRating = selected;
        _ratingFilterTouched = true;
      });
    }
  }

  Future<void> _pickSort() async {
    final selected = await _showOptionSheet<String>(
      context,
      title: 'Sort By',
      options: const [
        _Option(label: 'Default', value: 'Sort By'),
        _Option(label: 'Rating', value: 'Rating'),
        _Option(label: 'Title', value: 'Title'),
      ],
    );
    if (selected is String) {
      setState(() => _sortBy = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleMovies = _visibleMovies;
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  _SearchField(
                    controller: _queryController,
                    onChanged: (_) => setState(() {}),
                    onVoiceSearch: () => _showInfoDialog(
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
                              _FilterChip(
                                label: _year?.toString() ?? 'Year',
                                onPressed: _pickYear,
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: !_ratingFilterTouched
                                    ? 'Rating'
                                    : '${_minimumRating.toStringAsFixed(1)}+',
                                onPressed: _pickRating,
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(label: _sortBy, onPressed: _pickSort),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(36, 36),
                        onPressed: () => _showFiltersDialog(
                          context,
                          onReset: () => setState(() {
                            _queryController.clear();
                            _year = null;
                            _minimumRating = 0.0;
                            _ratingFilterTouched = false;
                            _sortBy = 'Sort By';
                          }),
                        ),
                        child: const SizedBox(
                          width: 32,
                          height: 32,
                          child: _FunnelIcon(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 30, 18, 112),
            sliver: visibleMovies.isEmpty
                ? const SliverToBoxAdapter(child: _EmptySearchState())
                : SliverList.separated(
                    itemCount: visibleMovies.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 24),
                    itemBuilder: (context, index) => _SearchResultTile(
                      movie: visibleMovies[index],
                      userRating: _userRatingFor(visibleMovies[index]),
                      onOpenTrailer: widget.onOpenTrailer,
                      onRateMovie: widget.onRateMovie,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
