import 'app_user.dart';
import 'auth_user.dart';

abstract interface class UserRepository {
  /// Returns the `users/{uid}` profile. For a verified student with no profile
  /// yet, creates it first (W1). Throws [AuthException] with
  /// [AuthFailure.accountNotProvisioned] when no profile exists and none may be created.
  Future<AppUser> loadOrCreateStudent(AuthUser authUser);
}
