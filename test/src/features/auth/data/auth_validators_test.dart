import 'package:flutter_test/flutter_test.dart';
import 'package:movie_rating/src/features/auth/data/auth_validators.dart';

void main() {
  group('validateEmail', () {
    test('rejects an empty or whitespace-only value', () {
      expect(validateEmail(null), 'Email is required.');
      expect(validateEmail(''), 'Email is required.');
      expect(validateEmail('   '), 'Email is required.');
    });

    test('rejects malformed addresses', () {
      expect(validateEmail('person'), 'Enter a valid email address.');
      expect(validateEmail('person@'), 'Enter a valid email address.');
      expect(validateEmail('person@example'), 'Enter a valid email address.');
      expect(validateEmail('@example.com'), 'Enter a valid email address.');
      expect(validateEmail('a b@example.com'), 'Enter a valid email address.');
    });

    test('accepts well-formed addresses, ignoring surrounding spaces', () {
      expect(validateEmail('person@example.com'), isNull);
      expect(validateEmail('  person.one+tag@sub.example.co  '), isNull);
      expect(validateEmail('a_b-c@example-domain.io'), isNull);
    });
  });

  group('validatePassword', () {
    test('rejects an empty value', () {
      expect(validatePassword(null), 'Password is required.');
      expect(validatePassword(''), 'Password is required.');
    });

    test('rejects passwords shorter than 8 characters', () {
      expect(validatePassword('pass1'), 'Min 8 characters.');
      expect(validatePassword('abc123'), 'Min 8 characters.');
    });

    test('rejects passwords without a digit', () {
      expect(
        validatePassword('passwordonly'),
        'Must include at least one digit.',
      );
    });

    test('accepts passwords with 8+ characters and a digit', () {
      expect(validatePassword('password1'), isNull);
      expect(validatePassword('12345678'), isNull);
    });
  });

  group('validateLoginPassword', () {
    test('rejects an empty value', () {
      expect(validateLoginPassword(null), 'Password is required.');
      expect(validateLoginPassword(''), 'Password is required.');
    });

    test('accepts any non-empty value without strength checks', () {
      expect(validateLoginPassword('x'), isNull);
      expect(validateLoginPassword('short'), isNull);
      expect(validateLoginPassword('password1'), isNull);
    });
  });

  group('validateRealName', () {
    test('rejects an empty or whitespace-only value', () {
      expect(validateRealName(null), 'Name is required.');
      expect(validateRealName(''), 'Name is required.');
      expect(validateRealName('   '), 'Name is required.');
    });

    test('accepts a non-empty name', () {
      expect(validateRealName('Person One'), isNull);
      expect(validateRealName('  Ada  '), isNull);
    });
  });

  group('validateConfirmPassword', () {
    test('rejects a mismatch with the original password', () {
      expect(
        validateConfirmPassword('password2', 'password1'),
        'Passwords do not match.',
      );
      expect(
        validateConfirmPassword(null, 'password1'),
        'Passwords do not match.',
      );
    });

    test('accepts an exact match', () {
      expect(validateConfirmPassword('password1', 'password1'), isNull);
      expect(validateConfirmPassword('', ''), isNull);
    });
  });
}
