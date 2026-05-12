import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:movie_rating/src/features/auth/data/auth_providers.dart';
import 'package:movie_rating/src/features/auth/presentation/login_screen.dart';
import 'package:movie_rating/src/features/auth/presentation/register_credentials_screen.dart';
import 'package:movie_rating/src/features/auth/presentation/register_profile_screen.dart';
import 'package:movie_rating/src/features/auth/presentation/splash_screen.dart';
import 'package:movie_rating/src/features/home/presentation/welcome_screen.dart';

import 'app_routes.dart';

const Set<String> _publicLocations = <String>{
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.registerProfile,
};

GoRouter createAppRouter({
  required AsyncValue<AuthState> Function() readAuthState,
  required Listenable refreshListenable,
}) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authState = readAuthState();
      final location = state.matchedLocation;

      if (authState.isLoading) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final value = authState.value;
      final isAuthenticated = value is Authenticated;

      if (isAuthenticated) {
        if (location == AppRoutes.splash ||
            _publicLocations.contains(location)) {
          return AppRoutes.welcome;
        }
        return null;
      }

      if (location == AppRoutes.welcome || location == AppRoutes.splash) {
        return AppRoutes.login;
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterCredentialsScreen(),
      ),
      GoRoute(
        path: AppRoutes.registerProfile,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! PendingRegistration) {
            return const RegisterCredentialsScreen();
          }
          return RegisterProfileScreen(pending: extra);
        },
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
    ],
  );
}
