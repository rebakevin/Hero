import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/app_user.dart';
import '../domain/role.dart';

abstract final class UserMapper {
  static AppUser fromMap(String uid, Map<String, dynamic> map) => AppUser(
    uid: uid,
    displayName: map['displayName'] as String,
    email: map['email'] as String,
    role: Role.fromKey(map['role'] as String),
    createdAt: (map['createdAt'] as Timestamp).toDate(),
  );

  /// Exactly the four keys the rules require for a first sign-in profile.
  static Map<String, dynamic> newStudentMap({
    required String displayName,
    required String email,
  }) => {
    'displayName': displayName,
    'email': email,
    'role': Role.student.name,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
