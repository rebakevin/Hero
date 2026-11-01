import '../../../core/constants.dart';

/// Form validators. Each returns an error message, or null when the value is valid.
abstract final class AuthValidators {
  static const minPasswordLength = 8;
  static const minNameLength = 2;
  static const maxNameLength = 50;

  static final _emailFormat = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? registerEmail(String? value) =>
      _email(value, allowedDomains: const [studentEmailDomain]);

  static String? loginEmail(String? value) => _email(
    value,
    allowedDomains: const [studentEmailDomain, staffEmailDomain],
  );

  static String? loginPassword(String? value) =>
      (value == null || value.isEmpty) ? 'Enter your password.' : null;

  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter a password.';
    if (value.length < minPasswordLength) {
      return 'Use at least $minPasswordLength characters.';
    }
    final hasLetter = value.contains(RegExp(r'[A-Za-z]'));
    final hasDigit = value.contains(RegExp(r'\d'));
    if (!hasLetter || !hasDigit) {
      return 'Include at least one letter and one number.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Confirm your password.';
    if (value != password) return 'Passwords do not match.';
    return null;
  }

  static String? displayName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Enter your name.';
    if (name.length < minNameLength || name.length > maxNameLength) {
      return 'Use between $minNameLength and $maxNameLength characters.';
    }
    return null;
  }

  static String? _email(String? value, {required List<String> allowedDomains}) {
    final email = value?.trim().toLowerCase() ?? '';
    if (email.isEmpty) return 'Enter your email.';
    if (!_emailFormat.hasMatch(email)) return 'Enter a valid email address.';
    if (!allowedDomains.any(email.endsWith)) {
      return allowedDomains.length == 1
          ? 'Use your ${allowedDomains.single} email.'
          : 'Use your ${allowedDomains.join(' or ')} email.';
    }
    return null;
  }
}
