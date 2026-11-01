import 'package:firebase_auth/firebase_auth.dart';

import '../domain/auth_failure.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;

  @override
  Stream<AuthUser?> sessionChanges() => _auth.userChanges().map(_toAuthUser);

  @override
  Future<void> signIn({required String email, required String password}) =>
      _guard(
        () =>
            _auth.signInWithEmailAndPassword(email: email, password: password),
      );

  @override
  Future<void> register({
    required String displayName,
    required String email,
    required String password,
  }) => _guard(() async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(displayName);
    await user.sendEmailVerification();
  });

  @override
  Future<void> sendPasswordReset(String email) => _guard(() async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      // Do not reveal whether an account exists.
      if (error.code != 'user-not-found') rethrow;
    }
  });

  @override
  Future<void> sendVerificationEmail() => _guard(() async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException(AuthFailure.unknown);
    await user.sendEmailVerification();
  });

  @override
  Future<AuthUser?> reloadCurrentUser() => _guard(() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    await user.reload();
    final refreshed = _auth.currentUser;
    // Firestore rules read email_verified from the ID token, which stays stale until refreshed.
    if (refreshed != null && refreshed.emailVerified) {
      await refreshed.getIdToken(true);
    }
    return _toAuthUser(refreshed);
  });

  @override
  Future<void> signOut() => _auth.signOut();

  AuthUser? _toAuthUser(User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      email: (user.email ?? '').toLowerCase(),
      emailVerified: user.emailVerified,
      displayName: user.displayName,
    );
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (error) {
      throw AuthException(_failureFor(error.code));
    }
  }

  AuthFailure _failureFor(String code) => switch (code) {
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' => AuthFailure.invalidCredentials,
    'invalid-email' => AuthFailure.invalidEmail,
    'email-already-in-use' => AuthFailure.emailInUse,
    'weak-password' => AuthFailure.weakPassword,
    'too-many-requests' => AuthFailure.tooManyRequests,
    'user-disabled' => AuthFailure.userDisabled,
    'network-request-failed' => AuthFailure.network,
    _ => AuthFailure.unknown,
  };
}
