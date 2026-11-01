enum AuthFailure {
  invalidCredentials,
  invalidEmail,
  emailInUse,
  weakPassword,
  tooManyRequests,
  userDisabled,
  network,
  accountNotProvisioned,
  unknown,
}

/// Thrown by repositories so nothing above the data layer sees SDK exceptions.
class AuthException implements Exception {
  const AuthException(this.failure);

  final AuthFailure failure;

  @override
  String toString() => 'AuthException($failure)';
}
