import '../domain/auth_failure.dart';

extension AuthFailureMessage on AuthFailure {
  String get message => switch (this) {
    AuthFailure.invalidCredentials =>
      'Email or password is incorrect. Please try again.',
    AuthFailure.invalidEmail => 'Enter a valid email address.',
    AuthFailure.emailInUse =>
      'An account with this email already exists. Try logging in.',
    AuthFailure.weakPassword => 'Choose a stronger password.',
    AuthFailure.tooManyRequests =>
      'Too many attempts. Wait a few minutes and try again.',
    AuthFailure.userDisabled =>
      'This account has been disabled. Contact campus staff.',
    AuthFailure.network => 'No connection. Check your internet and try again.',
    AuthFailure.accountNotProvisioned => 'This account is not set up for Hero. Use your ALU email, or ask an admin to add you.',
    AuthFailure.unknown => 'Something went wrong. Please try again.',
  };
}
