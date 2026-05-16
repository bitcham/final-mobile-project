import 'package:flutter_test/flutter_test.dart';
import 'package:movie_rating/src/features/auth/data/auth_database_service.dart';
import 'package:movie_rating/src/features/auth/data/auth_repository.dart';
import 'package:movie_rating/src/features/auth/data/password_hasher.dart';
import 'package:movie_rating/src/features/auth/models/app_user.dart';

void main() {
  group('AuthRepository', () {
    test(
      'register stores a trimmed user with a non-plain-text password hash',
      () async {
        final database = _FakeAuthDatabaseService();
        final repository = AuthRepository(
          databaseService: database,
          passwordHasher: PasswordHasher(
            iterations: 2,
            saltGenerator: () => List<int>.filled(16, 1),
          ),
        );

        final user = await repository.register(
          email: '  Person@example.com  ',
          password: 'password1',
          realName: '  Person One  ',
        );

        final stored = database.insertedUser!;
        expect(user.id, 42);
        expect(stored.email, 'Person@example.com');
        expect(stored.realName, 'Person One');
        expect(stored.passwordHash, isNot('password1'));
        expect(stored.passwordHash, startsWith('pbkdf2_sha256\$2\$'));
        expect(stored.passwordSalt, isNotEmpty);
      },
    );

    test(
      'login returns the stored user only when the password matches',
      () async {
        final database = _FakeAuthDatabaseService();
        final repository = AuthRepository(
          databaseService: database,
          passwordHasher: PasswordHasher(
            iterations: 2,
            saltGenerator: () => List<int>.filled(16, 1),
          ),
        );

        await repository.register(
          email: 'person@example.com',
          password: 'password1',
          realName: 'Person One',
        );

        final validLogin = await repository.login(
          email: ' PERSON@example.com ',
          password: 'password1',
        );
        final invalidLogin = await repository.login(
          email: 'person@example.com',
          password: 'wrong-password',
        );

        expect(validLogin?.email, 'person@example.com');
        expect(invalidLogin, isNull);
      },
    );

    test('updates profile and password for an existing stored user', () async {
      final database = _FakeAuthDatabaseService();
      final repository = AuthRepository(
        databaseService: database,
        passwordHasher: PasswordHasher(
          iterations: 2,
          saltGenerator: () => List<int>.filled(16, 1),
        ),
      );

      final user = await repository.register(
        email: 'person@example.com',
        password: 'password1',
        realName: 'Person One',
      );

      final updatedProfile = await repository.updateProfile(
        user: user,
        realName: 'Person Two',
      );
      final passwordChanged = await repository.changePassword(
        user: updatedProfile,
        currentPassword: 'password1',
        newPassword: 'password2',
      );

      expect(updatedProfile.realName, 'Person Two');
      expect(passwordChanged, isTrue);
      expect(
        await repository.login(
          email: 'person@example.com',
          password: 'password1',
        ),
        isNull,
      );
      expect(
        (await repository.login(
          email: 'person@example.com',
          password: 'password2',
        ))?.realName,
        'Person Two',
      );
    });
  });
}

class _FakeAuthDatabaseService extends AuthDatabaseService {
  AppUser? insertedUser;

  @override
  Future<int> insertUser(AppUser user) async {
    insertedUser = user.copyWith(id: 42);
    return 42;
  }

  @override
  Future<AppUser?> findByEmail(String email) async {
    final user = insertedUser;
    if (user == null) {
      return null;
    }
    return user.email.toLowerCase() == email.trim().toLowerCase() ? user : null;
  }

  @override
  Future<AppUser?> findById(int id) async {
    final user = insertedUser;
    return user?.id == id ? user : null;
  }

  @override
  Future<void> updateUser(AppUser user) async {
    insertedUser = user;
  }
}
