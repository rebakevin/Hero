import 'package:equatable/equatable.dart';

import '../domain/app_user.dart';
import '../domain/auth_failure.dart';

/// Where the user is in the sign-in journey. Drives the auth gate.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Restoring the session or loading the profile.
final class AuthChecking extends AuthState {
  const AuthChecking();
}

final class Unauthenticated extends AuthState {
  const Unauthenticated();
}

final class EmailUnverified extends AuthState {
  const EmailUnverified(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

final class Authenticated extends AuthState {
  const Authenticated(this.user, {this.emailVerified = true});

  final AppUser user;
  final bool emailVerified;

  @override
  List<Object?> get props => [user, emailVerified];
}

/// Signed in, but the profile could not be loaded or created.
final class AuthProfileFailed extends AuthState {
  const AuthProfileFailed(this.failure);

  final AuthFailure failure;

  @override
  List<Object?> get props => [failure];
}
