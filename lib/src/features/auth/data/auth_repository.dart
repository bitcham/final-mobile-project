import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';

import 'auth_database_service.dart';
import '../models/app_user.dart';

class EmailAlreadyRegisteredException implements Exception {
  const EmailAlreadyRegisteredException(this.email);

  final String email;

  @override
  String toString() => 'Email already registered: $email';
}

class AuthRepository {
  AuthRepository({AuthDatabaseService? databaseService})
    : _databaseService = databaseService ?? AuthDatabaseService();

  final AuthDatabaseService _databaseService;

  Future<AppUser> register({
    required String email,
    required String password,
    required String realName,
    String? profileImagePath,
  }) async {
    final normalizedEmail = email.trim();

    final random = Random.secure();
    final saltBytes = List<int>.generate(16, (_) => random.nextInt(256));
    final salt = saltBytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    final hash = sha256.convert(utf8.encode(salt + password)).toString();

    final pending = AppUser(
      email: normalizedEmail,
      passwordHash: hash,
      passwordSalt: salt,
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
    final attemptedHash = sha256
        .convert(utf8.encode(user.passwordSalt + password))
        .toString();
    if (attemptedHash != user.passwordHash) {
      return null;
    }
    return user;
  }

  Future<AppUser?> findById(int id) => _databaseService.findById(id);
}
