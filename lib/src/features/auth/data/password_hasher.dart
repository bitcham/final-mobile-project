import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

class PasswordHash {
  const PasswordHash({
    required this.algorithm,
    required this.iterations,
    required this.salt,
    required this.digest,
  });

  final String algorithm;
  final int iterations;
  final String salt;
  final String digest;

  String toStorageString() => '$algorithm\$$iterations\$$digest';
}

class PasswordHasher {
  PasswordHasher({
    this.iterations = 120000,
    this.keyLength = 32,
    List<int> Function()? saltGenerator,
  }) : _saltGenerator = saltGenerator ?? _generateSecureSalt;

  static const String algorithm = 'pbkdf2_sha256';

  final int iterations;
  final int keyLength;
  final List<int> Function() _saltGenerator;

  PasswordHash hash(String password) {
    final saltBytes = _saltGenerator();
    final digestBytes = _deriveKey(
      password: utf8.encode(password),
      salt: saltBytes,
      iterations: iterations,
      keyLength: keyLength,
    );

    return PasswordHash(
      algorithm: algorithm,
      iterations: iterations,
      salt: base64UrlEncode(saltBytes),
      digest: base64UrlEncode(digestBytes),
    );
  }

  bool verify(String password, PasswordHash hash) {
    if (hash.algorithm != algorithm || hash.iterations <= 0) {
      return false;
    }

    final expected = base64Url.decode(hash.digest);
    final actual = _deriveKey(
      password: utf8.encode(password),
      salt: base64Url.decode(hash.salt),
      iterations: hash.iterations,
      keyLength: expected.length,
    );
    return _constantTimeEquals(actual, expected);
  }

  bool verifyStored({
    required String password,
    required String salt,
    required String storedHash,
  }) {
    final parts = storedHash.split(r'$');
    if (parts.length == 3) {
      final parsedIterations = int.tryParse(parts[1]);
      if (parsedIterations == null) {
        return false;
      }
      return verify(
        password,
        PasswordHash(
          algorithm: parts[0],
          iterations: parsedIterations,
          salt: salt,
          digest: parts[2],
        ),
      );
    }

    final legacyHash = sha256.convert(utf8.encode(salt + password)).toString();
    return _constantTimeEquals(
      utf8.encode(legacyHash),
      utf8.encode(storedHash),
    );
  }

  static List<int> _generateSecureSalt() {
    final random = Random.secure();
    return List<int>.generate(16, (_) => random.nextInt(256));
  }

  static List<int> _deriveKey({
    required List<int> password,
    required List<int> salt,
    required int iterations,
    required int keyLength,
  }) {
    final hmac = Hmac(sha256, password);
    final blocks = (keyLength / sha256.blockSize).ceil();
    final output = <int>[];

    for (var block = 1; block <= blocks; block++) {
      var previous = hmac.convert([...salt, ..._int32(block)]).bytes;
      final result = Uint8List.fromList(previous);

      for (var round = 1; round < iterations; round++) {
        previous = hmac.convert(previous).bytes;
        for (var index = 0; index < result.length; index++) {
          result[index] ^= previous[index];
        }
      }

      output.addAll(result);
    }

    return output.take(keyLength).toList(growable: false);
  }

  static List<int> _int32(int value) {
    return [
      (value >> 24) & 0xff,
      (value >> 16) & 0xff,
      (value >> 8) & 0xff,
      value & 0xff,
    ];
  }

  static bool _constantTimeEquals(List<int> left, List<int> right) {
    if (left.length != right.length) {
      return false;
    }

    var difference = 0;
    for (var index = 0; index < left.length; index++) {
      difference |= left[index] ^ right[index];
    }
    return difference == 0;
  }
}
