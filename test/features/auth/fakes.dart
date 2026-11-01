import 'dart:async';

import 'package:hero/features/auth/domain/app_user.dart';
import 'package:hero/features/auth/domain/auth_failure.dart';
import 'package:hero/features/auth/domain/auth_repository.dart';
import 'package:hero/features/auth/domain/auth_user.dart';
import 'package:hero/features/auth/domain/role.dart';
import 'package:hero/features/auth/domain/user_repository.dart';

const studentAuthUser = AuthUser(
  uid: 'student-1',
  email: 'amina@alustudent.com',
  emailVerified: true,
  displayName: 'Amina Hassan',
);

const unverifiedAuthUser = AuthUser(
  uid: 'student-1',
  email: 'amina@alustudent.com',
  emailVerified: false,
  displayName: 'Amina Hassan',
);

final studentProfile = AppUser(
  uid: 'student-1',
  displayName: 'Amina Hassan',
  email: 'amina@alustudent.com',
  role: Role.student,
  createdAt: DateTime(2026, 11, 1),
);

class FakeAuthRepository implements AuthRepository {
  final session = StreamController<AuthUser?>.broadcast();
  AuthFailure? failWith;
  AuthUser? reloadResult;
  final calls = <String>[];

  Future<void> _record(String call) async {
    calls.add(call);
    if (failWith != null) throw AuthException(failWith!);
  }

  @override
  Stream<AuthUser?> sessionChanges() => session.stream;

  @override
  Future<void> signIn({required String email, required String password}) =>
      _record('signIn:$email');

  @override
  Future<void> register({
    required String displayName,
    required String email,
    required String password,
  }) => _record('register:$displayName:$email');

  @override
  Future<void> sendPasswordReset(String email) => _record('reset:$email');

  @override
  Future<void> sendVerificationEmail() => _record('resend');

  @override
  Future<AuthUser?> reloadCurrentUser() async {
    await _record('reload');
    return reloadResult;
  }

  @override
  Future<void> signOut() => _record('signOut');
}

class FakeUserRepository implements UserRepository {
  AppUser? profile;
  Object? error;
  int loads = 0;

  final renames = <String>[];

  @override
  Future<void> rename({
    required String uid,
    required String displayName,
  }) async {
    if (error != null) throw error!;
    renames.add('$uid:$displayName');
  }

  @override
  Future<AppUser> loadOrCreateStudent(AuthUser authUser) async {
    loads++;
    if (error != null) throw error!;
    return profile ?? studentProfile;
  }
}
