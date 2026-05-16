import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_database_service.dart';
import '../models/app_user.dart';
import 'auth_repository.dart';
import 'profile_image_service.dart';
import 'session_service.dart';

sealed class AuthState {
  const AuthState();
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class Authenticated extends AuthState {
  const Authenticated(this.user);

  final AppUser user;
}

final authDatabaseServiceProvider = Provider((ref) => AuthDatabaseService());

final authRepositoryProvider = Provider(
  (ref) =>
      AuthRepository(databaseService: ref.watch(authDatabaseServiceProvider)),
);

final sessionServiceProvider = Provider((ref) => SessionService());

final profileImageServiceProvider = Provider((ref) => ProfileImageService());

final authRouterRefreshProvider = Provider<ValueNotifier<int>>((ref) {
  final notifier = ValueNotifier<int>(0);
  ref.onDispose(notifier.dispose);
  return notifier;
});

class AuthController extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final sessionService = ref.read(sessionServiceProvider);
    final id = await sessionService.getCurrentUserId();
    if (id == null) {
      return const Unauthenticated();
    }
    final repo = ref.read(authRepositoryProvider);
    final user = await repo.findById(id);
    if (user == null) {
      await sessionService.clearCurrentUserId();
      return const Unauthenticated();
    }
    return Authenticated(user);
  }

  Future<bool> login({required String email, required String password}) async {
    final repo = ref.read(authRepositoryProvider);
    final sessionService = ref.read(sessionServiceProvider);
    final user = await repo.login(email: email, password: password);
    if (user == null || user.id == null) {
      state = const AsyncData<AuthState>(Unauthenticated());
      _bumpRouter();
      return false;
    }
    await sessionService.setCurrentUserId(user.id!);
    state = AsyncData<AuthState>(Authenticated(user));
    _bumpRouter();
    return true;
  }

  Future<AppUser> register({
    required String email,
    required String password,
    required String realName,
    String? profileImagePath,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    final sessionService = ref.read(sessionServiceProvider);
    try {
      final user = await repo.register(
        email: email,
        password: password,
        realName: realName,
        profileImagePath: profileImagePath,
      );
      await sessionService.setCurrentUserId(user.id!);
      state = AsyncData<AuthState>(Authenticated(user));
      _bumpRouter();
      return user;
    } catch (_) {
      state = const AsyncData<AuthState>(Unauthenticated());
      _bumpRouter();
      rethrow;
    }
  }

  Future<void> logout() async {
    final sessionService = ref.read(sessionServiceProvider);
    await sessionService.clearCurrentUserId();
    state = const AsyncData<AuthState>(Unauthenticated());
    _bumpRouter();
  }

  Future<AppUser> updateProfile({required String realName}) async {
    final authState = state.value;
    if (authState is! Authenticated) {
      throw StateError('A signed-in user is required to update the profile.');
    }

    final repo = ref.read(authRepositoryProvider);
    final updated = await repo.updateProfile(
      user: authState.user,
      realName: realName,
    );
    state = AsyncData<AuthState>(Authenticated(updated));
    _bumpRouter();
    return updated;
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final authState = state.value;
    if (authState is! Authenticated) {
      return false;
    }

    final repo = ref.read(authRepositoryProvider);
    final changed = await repo.changePassword(
      user: authState.user,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    if (changed) {
      final refreshedUser = await repo.findById(authState.user.id!);
      state = AsyncData<AuthState>(
        Authenticated(refreshedUser ?? authState.user),
      );
      _bumpRouter();
    }
    return changed;
  }

  void _bumpRouter() {
    final notifier = ref.read(authRouterRefreshProvider);
    notifier.value = notifier.value + 1;
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
