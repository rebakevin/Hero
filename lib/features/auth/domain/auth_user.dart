import 'package:equatable/equatable.dart';

import '../../../core/constants.dart';

/// The signed-in identity from the auth provider, before a profile is loaded.
class AuthUser extends Equatable {
  const AuthUser({
    required this.uid,
    required this.email,
    required this.emailVerified,
    this.displayName,
  });

  final String uid;
  final String email;
  final bool emailVerified;
  final String? displayName;

  /// Verifying is optional for students, but staff must verify before entering.
  bool get mustVerifyEmail =>
      !emailVerified && !email.endsWith(studentEmailDomain);

  @override
  List<Object?> get props => [uid, email, emailVerified, displayName];
}
