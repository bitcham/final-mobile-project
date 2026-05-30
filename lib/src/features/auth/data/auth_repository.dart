import 'package:sqflite/sqflite.dart';

import 'auth_database_service.dart';
import 'password_hasher.dart';
import '../models/app_user.dart';

class EmailAlreadyRegisteredException implements Exception {
  const EmailAlreadyRegisteredException(this.email);

  final String email;

  @override
  String toString() => 'Email already registered: $email';
}

class AuthRepository {
  AuthRepository({
    AuthDatabaseService? databaseService,
    PasswordHasher? passwordHasher,
  }) : _databaseService = databaseService ?? AuthDatabaseService(),
       _passwordHasher = passwordHasher ?? PasswordHasher();

  final AuthDatabaseService _databaseService;
  final PasswordHasher _passwordHasher;

  Future<AppUser> register({
    required String email,
    required String password,
    required String realName,
    String? profileImagePath,
  }) async {
    final normalizedEmail = email.trim();

    final passwordHash = _passwordHasher.hash(password);

    final pending = AppUser(
      email: normalizedEmail,
      passwordHash: passwordHash.toStorageString(),
      passwordSalt: passwordHash.salt,
      realName: realName.trim(),
      profileImagePath: profileImagePath,
    );

    try {
      final id = await _databaseService.insertUser(pending);
      return pending.copyWith(id: id);
    } on DatabaseException catch (error) {
      if (error.isUniqueConstraintError()) {
        throw EmailAlreadyRegisteredException(normalizedEmail);
      }
      rethrow;
    }
  }

  Future<AppUser?> login({
    required String email,
    required String password,
  }) async {
    final user = await _databaseService.findByEmail(email);
    if (user == null) {
      return null;
    }
    final passwordMatches = _passwordHasher.verifyStored(
      password: password,
      salt: user.passwordSalt,
      storedHash: user.passwordHash,
    );
    if (!passwordMatches) {
      return null;
    }
    return user;
  }

  Future<AppUser?> findById(int id) => _databaseService.findById(id);

  Future<AppUser> updateProfile({
    required AppUser user,
    String? realName,
    String? profileImagePath,
    String? profileBannerImagePath,
    String? bio,
  }) async {
    final updated = user.copyWith(
      realName: realName?.trim(),
      profileImagePath: profileImagePath,
      profileBannerImagePath: profileBannerImagePath,
      bio: bio?.trim(),
    );
    await _databaseService.updateUser(updated);
    return updated;
  }

  Future<bool> changePassword({
    required AppUser user,
    required String currentPassword,
    required String newPassword,
  }) async {
    final passwordMatches = _passwordHasher.verifyStored(
      password: currentPassword,
      salt: user.passwordSalt,
      storedHash: user.passwordHash,
    );
    if (!passwordMatches) {
      return false;
    }

    final passwordHash = _passwordHasher.hash(newPassword);
    await _databaseService.updateUser(
      user.copyWith(
        passwordHash: passwordHash.toStorageString(),
        passwordSalt: passwordHash.salt,
      ),
    );
    return true;
  }
}
