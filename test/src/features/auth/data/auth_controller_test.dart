import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_rating/src/features/auth/data/auth_providers.dart';
import 'package:movie_rating/src/features/auth/data/auth_repository.dart';
import 'package:movie_rating/src/features/auth/data/session_service.dart';
import 'package:movie_rating/src/features/auth/models/app_user.dart';

void main() {
  ProviderContainer buildContainer({
    required AuthRepository repository,
    required SessionService sessionService,
  }) {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        sessionServiceProvider.overrideWithValue(sessionService),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('AuthController', () {
    test(
      'login keeps the current auth state while credentials are checked',
      () async {
        final loginCompleter = Completer<AppUser?>();
        final container = buildContainer(
          repository: _FakeAuthRepository(loginCompleter: loginCompleter),
          sessionService: _FakeSessionService(),
        );
        await container.read(authControllerProvider.future);

        final login = container
            .read(authControllerProvider.notifier)
            .login(email: 'bad@example.com', password: 'wrong-password');

        expect(container.read(authControllerProvider).isLoading, isFalse);

        loginCompleter.complete(null);
        expect(await login, isFalse);
        expect(
          container.read(authControllerProvider).value,
          isA<Unauthenticated>(),
        );
      },
    );

    test(
      'register restores unauthenticated state when registration fails',
      () async {
        final container = buildContainer(
          repository: _FakeAuthRepository(
            registerError: const EmailAlreadyRegisteredException(
              'taken@example.com',
            ),
          ),
          sessionService: _FakeSessionService(),
        );
        await container.read(authControllerProvider.future);

        await expectLater(
          container
              .read(authControllerProvider.notifier)
              .register(
                email: 'taken@example.com',
                password: 'password1',
                realName: 'Taken User',
              ),
          throwsA(isA<EmailAlreadyRegisteredException>()),
        );

        final state = container.read(authControllerProvider);
        expect(state.isLoading, isFalse);
        expect(state.value, isA<Unauthenticated>());
      },
    );
  });
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({Completer<AppUser?>? loginCompleter, this.registerError})
    : _loginCompleter =
          loginCompleter ?? (Completer<AppUser?>()..complete(null));

  final Completer<AppUser?> _loginCompleter;
  final Object? registerError;

  @override
  Future<AppUser?> findById(int id) async => null;

  @override
  Future<bool> changePassword({
    required AppUser user,
    required String currentPassword,
    required String newPassword,
  }) async => false;

  @override
  Future<AppUser?> login({required String email, required String password}) {
    return _loginCompleter.future;
  }

  @override
  Future<AppUser> register({
    required String email,
    required String password,
    required String realName,
    String? profileImagePath,
  }) async {
    final error = registerError;
    if (error != null) {
      throw error;
    }
    return AppUser(
      id: 7,
      email: email,
      passwordHash: 'hash',
      passwordSalt: 'salt',
      realName: realName,
      profileImagePath: profileImagePath,
    );
  }

  @override
  Future<AppUser> updateProfile({
    required AppUser user,
    required String realName,
  }) async => user.copyWith(realName: realName);
}

class _FakeSessionService implements SessionService {
  int? currentUserId;

  @override
  Future<void> clearCurrentUserId() async {
    currentUserId = null;
  }

  @override
  Future<int?> getCurrentUserId() async => currentUserId;

  @override
  Future<void> setCurrentUserId(int userId) async {
    currentUserId = userId;
  }
}
