import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants.dart';
import '../domain/app_user.dart';
import '../domain/auth_failure.dart';
import '../domain/auth_user.dart';
import '../domain/auth_validators.dart';
import '../domain/user_repository.dart';
import 'user_mapper.dart';

class FirestoreUserRepository implements UserRepository {
  FirestoreUserRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<AppUser> loadOrCreateStudent(AuthUser authUser) async {
    final ref = _firestore.collection('users').doc(authUser.uid);
    try {
      final existing = await ref.get();
      if (existing.exists) return UserMapper.fromMap(ref.id, existing.data()!);

      if (!authUser.email.endsWith(studentEmailDomain)) {
        throw const AuthException(AuthFailure.accountNotProvisioned);
      }
      // A transaction keeps a duplicate session event from turning the create into a denied update.
      await _firestore.runTransaction((transaction) async {
        if ((await transaction.get(ref)).exists) return;
        transaction.set(
          ref,
          UserMapper.newStudentMap(
            displayName: _displayNameFor(authUser),
            email: authUser.email,
          ),
        );
      });
      final created = await ref.get();
      return UserMapper.fromMap(ref.id, created.data()!);
    } on FirebaseException catch (error) {
      throw AuthException(_failureFor(error.code));
    }
  }

  /// The rules require 2 to 50 characters; accounts made outside the app may have no name.
  String _displayNameFor(AuthUser authUser) {
    final fromProfile = authUser.displayName?.trim();
    final name =
        (fromProfile != null &&
            fromProfile.length >= AuthValidators.minNameLength)
        ? fromProfile
        : authUser.email.split('@').first;
    final padded = name.length < AuthValidators.minNameLength ? '$name ' : name;
    return padded.length > AuthValidators.maxNameLength
        ? padded.substring(0, AuthValidators.maxNameLength)
        : padded;
  }

  AuthFailure _failureFor(String code) => switch (code) {
    'permission-denied' => AuthFailure.accountNotProvisioned,
    'unavailable' || 'deadline-exceeded' => AuthFailure.network,
    _ => AuthFailure.unknown,
  };
}
