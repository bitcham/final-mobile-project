enum SearchSort { popularity, rating }

class SearchFilters {
  const SearchFilters({
    this.query = '',
    this.year,
    this.minRating = 0.0,
    this.ratingTouched = false,
    this.sort = SearchSort.popularity,
  });

  final String query;
  final int? year;
  final double minRating;
  final bool ratingTouched;
  final SearchSort sort;

  bool get hasQuery => query.trim().isNotEmpty;

  SearchFilters copyWith({
    String? query,
    int? year,
    bool clearYear = false,
    double? minRating,
    bool? ratingTouched,
    SearchSort? sort,
  }) {
    return SearchFilters(
      query: query ?? this.query,
      year: clearYear ? null : (year ?? this.year),
      minRating: minRating ?? this.minRating,
      ratingTouched: ratingTouched ?? this.ratingTouched,
      sort: sort ?? this.sort,
    );
  }
}
