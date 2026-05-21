import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_rating/src/core/models/movie_view.dart';
import 'package:movie_rating/src/features/auth/data/auth_providers.dart';
import 'movie_library_database_service.dart';
import 'movie_library_repository.dart';

final movieLibraryDatabaseServiceProvider = Provider(
  (ref) => MovieLibraryDatabaseService(),
);

final movieLibraryRepositoryProvider = Provider(
  (ref) => MovieLibraryRepository(
    databaseService: ref.watch(movieLibraryDatabaseServiceProvider),
  ),
);

class MovieLibraryController extends AsyncNotifier<MovieLibrary> {
  int? _userId;

  @override
  Future<MovieLibrary> build() async {
    final authState = ref.watch(authControllerProvider).value;
    final user = authState is Authenticated ? authState.user : null;
    _userId = user?.id;
    if (_userId == null) {
      return const MovieLibrary.empty();
    }
    return ref.read(movieLibraryRepositoryProvider).load(_userId!);
  }

  Future<void> rate(MovieView movie, double rating) async {
    final userId = _userId;
    if (userId == null) return;
    final repo = ref.read(movieLibraryRepositoryProvider);
    await repo.rate(userId, movie, rating);
    state = AsyncData(await repo.load(userId));
  }

  Future<void> toggleWatchlist(MovieView movie) async {
    final userId = _userId;
    if (userId == null) return;
    final repo = ref.read(movieLibraryRepositoryProvider);
    final current = state.value ?? const MovieLibrary.empty();
    await repo.toggleWatchlist(
      userId: userId,
      movie: movie,
      isInWatchlist: current.watchlistTitles.contains(movie.title),
    );
    state = AsyncData(await repo.load(userId));
  }
}

final movieLibraryControllerProvider =
    AsyncNotifierProvider<MovieLibraryController, MovieLibrary>(
      MovieLibraryController.new,
    );
