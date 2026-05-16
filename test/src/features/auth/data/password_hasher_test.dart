import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_rating/src/features/auth/data/password_hasher.dart';

void main() {
  group('PasswordHasher', () {
    test(
      'hashes passwords with a random salt and verifies the original password',
      () {
        final hasher = PasswordHasher(
          iterations: 2,
          saltGenerator: () => List<int>.filled(16, 1),
        );

        final hash = hasher.hash('password1');

        expect(hash.algorithm, 'pbkdf2_sha256');
        expect(hash.iterations, 2);
        expect(hash.salt, isNotEmpty);
        expect(hash.digest, isNotEmpty);
        expect(hasher.verify('password1', hash), isTrue);
        expect(hasher.verify('wrong-password', hash), isFalse);
      },
    );

    test('uses a new salt for each hash', () {
      var nextByte = 0;
      final hasher = PasswordHasher(
        iterations: 2,
        saltGenerator: () => List<int>.generate(16, (_) => nextByte++),
      );

      final first = hasher.hash('password1');
      final second = hasher.hash('password1');

      expect(first.salt, isNot(second.salt));
      expect(first.digest, isNot(second.digest));
    });

    test('verifies hashes serialized for storage', () {
      final hasher = PasswordHasher(
        iterations: 2,
        saltGenerator: () => List<int>.filled(16, 1),
      );
      final hash = hasher.hash('password1');

      expect(
        hasher.verifyStored(
          password: 'password1',
          salt: hash.salt,
          storedHash: hash.toStorageString(),
        ),
        isTrue,
      );
    });

    test(
      'still verifies legacy sha256 hashes created by the first auth version',
      () {
        final hasher = PasswordHasher(iterations: 2);
        final legacyHash = sha256
            .convert(utf8.encode('saltpassword1'))
            .toString();

        expect(
          hasher.verifyStored(
            password: 'password1',
            salt: 'salt',
            storedHash: legacyHash,
          ),
          isTrue,
        );
      },
    );
  });
}
