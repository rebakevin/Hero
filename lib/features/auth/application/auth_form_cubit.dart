import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/auth_failure.dart';
import '../domain/auth_repository.dart';
import 'auth_form_state.dart';

/// Submit state for one auth screen. Create one per screen. A successful sign-in
/// or registration is not reported here: the session stream moves the auth gate on.
class AuthFormCubit extends Cubit<AuthFormState> {
  AuthFormCubit(this._auth) : super(const AuthFormIdle());

  final AuthRepository _auth;

  Future<void> signIn({required String email, required String password}) =>
      _submit(() async {
        await _auth.signIn(email: email, password: password);
        return null;
      });

  Future<void> register({
    required String displayName,
    required String email,
    required String password,
  }) => _submit(() async {
    await _auth.register(
      displayName: displayName,
      email: email,
      password: password,
    );
    return null;
  });

  Future<void> sendPasswordReset(String email) => _submit(() async {
    await _auth.sendPasswordReset(email);
    return AuthFormOutcome.passwordResetSent;
  });

  Future<void> resendVerificationEmail() => _submit(() async {
    await _auth.sendVerificationEmail();
    return AuthFormOutcome.verificationEmailSent;
  });

  Future<void> checkEmailVerified() => _submit(() async {
    final user = await _auth.reloadCurrentUser();
    return (user?.emailVerified ?? false)
        ? null
        : AuthFormOutcome.emailNotVerifiedYet;
  });

  Future<void> _submit(Future<AuthFormOutcome?> Function() action) async {
    if (state is AuthFormSubmitting) return;
    emit(const AuthFormSubmitting());
    try {
      final outcome = await action();
      if (isClosed) return;
      emit(outcome == null ? const AuthFormIdle() : AuthFormSucceeded(outcome));
    } on AuthException catch (error) {
      if (!isClosed) emit(AuthFormFailed(error.failure));
    } catch (error, stackTrace) {
      log(
        'Auth action failed',
        name: 'AuthFormCubit',
        error: error,
        stackTrace: stackTrace,
      );
      if (!isClosed) emit(const AuthFormFailed(AuthFailure.unknown));
    }
  }
}
