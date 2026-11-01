import 'package:equatable/equatable.dart';

import '../domain/auth_failure.dart';

/// What happened after a form action, for the screen to tell the user about.
enum AuthFormOutcome {
  passwordResetSent,
  verificationEmailSent,
  emailNotVerifiedYet,
}

sealed class AuthFormState extends Equatable {
  const AuthFormState();

  @override
  List<Object?> get props => [];
}

final class AuthFormIdle extends AuthFormState {
  const AuthFormIdle();
}

final class AuthFormSubmitting extends AuthFormState {
  const AuthFormSubmitting();
}

final class AuthFormFailed extends AuthFormState {
  const AuthFormFailed(this.failure);

  final AuthFailure failure;

  @override
  List<Object?> get props => [failure];
}

final class AuthFormSucceeded extends AuthFormState {
  const AuthFormSucceeded(this.outcome);

  final AuthFormOutcome outcome;

  @override
  List<Object?> get props => [outcome];
}
