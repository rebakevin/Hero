import 'auth_user.dart';

/// Email/password authentication. Methods throw [AuthException] on failure.
abstract interface class AuthRepository {
  /// Emits the current user on listen, then on every sign-in, sign-out, token
  /// refresh and reload. Emits null when signed out.
  Stream<AuthUser?> sessionChanges();

  Future<void> signIn({required String email, required String password});

  /// Creates a student account, stores the display name and sends the verification email.
  Future<void> register({
    required String displayName,
    required String email,
    required String password,
  });

  /// Completes normally even when no account exists for [email].
  Future<void> sendPasswordReset(String email);

  Future<void> sendVerificationEmail();

  /// Re-reads the user from the server and refreshes the ID token so rules see
  /// the new `email_verified` claim. Returns null when signed out.
  Future<AuthUser?> reloadCurrentUser();

  Future<void> signOut();
}
