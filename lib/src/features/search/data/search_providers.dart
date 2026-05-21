import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_rating/src/core/models/movie_view.dart';
import '../models/search_filters.dart';
import 'tmdb_api_client.dart';

final tmdbApiClientProvider = Provider<TmdbApiClient>((ref) => TmdbApiClient());

class SearchState {
  const SearchState({
    this.movies = const [],
    this.filters = const SearchFilters(),
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.page = 0,
    this.totalPages = 1,
  });

  final List<MovieView> movies;
  final SearchFilters filters;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final int page;
  final int totalPages;

  bool get canLoadMore => page > 0 && page < totalPages;

  SearchState copyWith({
    List<MovieView>? movies,
    SearchFilters? filters,
    bool? isLoading,
    bool? isLoadingMore,
    Object? errorMessage = _unset,
    int? page,
    int? totalPages,
  }) {
    return SearchState(
      movies: movies ?? this.movies,
      filters: filters ?? this.filters,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  static const _unset = Object();
}

class SearchController extends Notifier<SearchState> {
  int _requestId = 0;

  @override
  SearchState build() {
    Future.microtask(refresh);
    return const SearchState(isLoading: true);
  }

  TmdbApiClient get _client => ref.read(tmdbApiClientProvider);

  void setQuery(String query) {
    if (query == state.filters.query) return;
    state = state.copyWith(filters: state.filters.copyWith(query: query));
    refresh();
  }

  void setYear(int? year) {
    state = state.copyWith(
      filters: state.filters.copyWith(year: year, clearYear: year == null),
    );
    refresh();
  }

  void setMinRating(double minRating) {
    state = state.copyWith(
      filters: state.filters.copyWith(
        minRating: minRating,
        ratingTouched: true,
      ),
    );
    refresh();
  }

  void setSort(SearchSort sort) {
    state = state.copyWith(filters: state.filters.copyWith(sort: sort));
    refresh();
  }

  void resetFilters() {
    state = state.copyWith(filters: const SearchFilters());
    refresh();
  }

  Future<void> refresh() => _fetch(targetPage: 1, append: false);

  Future<void> loadMore() {
    if (state.isLoading || state.isLoadingMore || !state.canLoadMore) {
      return Future.value();
    }
    return _fetch(targetPage: state.page + 1, append: true);
  }

  Future<void> _fetch({required int targetPage, required bool append}) async {
    final requestId = ++_requestId;
    final filters = state.filters;
    state = append
        ? state.copyWith(isLoadingMore: true)
        : state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = filters.hasQuery
          ? await _client.searchMovies(
              query: filters.query.trim(),
              page: targetPage,
              year: filters.year,
            )
          : await _client.discoverMovies(
              page: targetPage,
              year: filters.year,
              minRating: filters.minRating,
              sortByRating: filters.sort == SearchSort.rating,
            );

      if (requestId != _requestId) return;

      final combined = append
          ? [...state.movies, ...result.movies]
          : result.movies;
      state = state.copyWith(
        movies: _postProcess(combined, filters),
        page: result.page,
        totalPages: result.totalPages,
        isLoading: false,
        isLoadingMore: false,
        errorMessage: null,
      );
    } on TmdbException catch (error) {
      if (requestId != _requestId) return;
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: error.message,
      );
    }
  }

  List<MovieView> _postProcess(List<MovieView> movies, SearchFilters filters) {
    var result = movies
        .where((movie) => movie.rating >= filters.minRating)
        .toList();
    if (filters.sort == SearchSort.rating) {
      result.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return result;
  }
}

final searchControllerProvider =
    NotifierProvider<SearchController, SearchState>(SearchController.new);
