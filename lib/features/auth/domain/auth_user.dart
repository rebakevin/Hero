import 'package:equatable/equatable.dart';

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

  @override
  List<Object?> get props => [uid, email, emailVerified, displayName];
}
