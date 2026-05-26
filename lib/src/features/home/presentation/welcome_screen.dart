import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:movie_rating/src/features/auth/data/auth_providers.dart';
import 'package:movie_rating/src/features/auth/models/app_user.dart';
import 'package:movie_rating/src/features/library/data/movie_library_providers.dart';
import 'package:movie_rating/src/features/library/data/movie_library_repository.dart';
import 'package:movie_rating/src/features/main/presentation/main_tab_screen.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  static const _fallbackUser = AppUser(
    id: 0,
    email: 'moviefan@example.com',
    passwordHash: '',
    passwordSalt: '',
    realName: 'Movie Fan',
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = switch (authState.value) {
      Authenticated(:final user) => user,
      _ => _fallbackUser,
    };

    final libraryAsync = ref.watch(movieLibraryControllerProvider);
    if (libraryAsync.isLoading) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }
    final library = libraryAsync.value ?? const MovieLibrary.empty();
    final libraryController = ref.read(movieLibraryControllerProvider.notifier);

    return MainTabScreen(
      user: user,
      onLogout: () => ref.read(authControllerProvider.notifier).logout(),
      onUpdateProfile: (realName) => ref
          .read(authControllerProvider.notifier)
          .updateProfile(realName: realName),
      onChangePassword: ({required currentPassword, required newPassword}) =>
          ref
              .read(authControllerProvider.notifier)
              .changePassword(
                currentPassword: currentPassword,
                newPassword: newPassword,
              ),
      initialRatings: library.ratings,
      initialRatedMovies: library.ratedMovies,
      initialWatchlist: library.watchlistMovies,
      onPersistRating: libraryController.rate,
      onPersistWatchlistToggle: libraryController.toggleWatchlist,
    );
  }
}
