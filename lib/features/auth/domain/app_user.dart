import 'package:equatable/equatable.dart';

import 'role.dart';

/// The `users/{uid}` profile. The role here is the only source of truth for permissions.
class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  final String uid;
  final String displayName;
  final String email;
  final Role role;
  final DateTime createdAt;

  bool get isStaff => role == Role.staff;

  @override
  List<Object?> get props => [uid, displayName, email, role, createdAt];
}
