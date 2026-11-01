import 'package:flutter_test/flutter_test.dart';
import 'package:hero/features/auth/domain/auth_validators.dart';

void main() {
  group('registerEmail', () {
    test('accepts a student address, ignoring case and spaces', () {
      expect(AuthValidators.registerEmail('  Amina@AluStudent.com '), isNull);
    });

    test('rejects empty input', () {
      expect(AuthValidators.registerEmail(''), 'Enter your email.');
      expect(AuthValidators.registerEmail(null), 'Enter your email.');
    });

    test('rejects a malformed address', () {
      expect(
        AuthValidators.registerEmail('amina@alustudent'),
        'Enter a valid email address.',
      );
    });

    test('rejects other domains, including the staff domain', () {
      expect(
        AuthValidators.registerEmail('amina@gmail.com'),
        'Use your @alustudent.com email.',
      );
      expect(
        AuthValidators.registerEmail('kevin@alueducation.com'),
        'Use your @alustudent.com email.',
      );
    });
  });

  group('loginEmail', () {
    test('accepts student and staff addresses', () {
      expect(AuthValidators.loginEmail('a@alustudent.com'), isNull);
      expect(AuthValidators.loginEmail('k@alueducation.com'), isNull);
    });

    test('rejects any other domain', () {
      expect(AuthValidators.loginEmail('a@gmail.com'), isNotNull);
    });
  });

  group('newPassword', () {
    test('accepts 8 or more characters with a letter and a number', () {
      expect(AuthValidators.newPassword('hunter22'), isNull);
    });

    test('rejects empty, short, letters-only and digits-only passwords', () {
      expect(AuthValidators.newPassword(''), 'Enter a password.');
      expect(
        AuthValidators.newPassword('abc123'),
        'Use at least 8 characters.',
      );
      expect(
        AuthValidators.newPassword('abcdefgh'),
        'Include at least one letter and one number.',
      );
      expect(
        AuthValidators.newPassword('12345678'),
        'Include at least one letter and one number.',
      );
    });
  });

  group('confirmPassword', () {
    test('requires a match', () {
      expect(AuthValidators.confirmPassword('hunter22', 'hunter22'), isNull);
      expect(
        AuthValidators.confirmPassword('hunter23', 'hunter22'),
        'Passwords do not match.',
      );
      expect(
        AuthValidators.confirmPassword('', 'hunter22'),
        'Confirm your password.',
      );
    });
  });

  group('displayName', () {
    test('accepts 2 to 50 trimmed characters', () {
      expect(AuthValidators.displayName('Al'), isNull);
      expect(AuthValidators.displayName(' ${'a' * 50} '), isNull);
    });

    test('rejects empty, too short and too long names', () {
      expect(AuthValidators.displayName('   '), 'Enter your name.');
      expect(AuthValidators.displayName('A'), isNotNull);
      expect(AuthValidators.displayName('a' * 51), isNotNull);
    });
  });

  test('loginPassword only requires a value', () {
    expect(AuthValidators.loginPassword('x'), isNull);
    expect(AuthValidators.loginPassword(''), 'Enter your password.');
  });
}
