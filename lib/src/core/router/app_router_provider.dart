import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:movie_rating/src/features/auth/data/auth_providers.dart';

import 'app_router.dart';

final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(authRouterRefreshProvider);
  ref.listen<AsyncValue<AuthState>>(authControllerProvider, (_, _) {
    refresh.value = refresh.value + 1;
  });
  final router = createAppRouter(
    readAuthState: () => ref.read(authControllerProvider),
    refreshListenable: refresh,
  );
  ref.onDispose(router.dispose);
  return router;
});
