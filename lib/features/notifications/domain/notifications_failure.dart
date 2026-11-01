enum NotificationsFailure { network, unknown }

/// Thrown by repositories so nothing above the data layer sees SDK exceptions.
class NotificationsException implements Exception {
  const NotificationsException(this.failure);

  final NotificationsFailure failure;

  @override
  String toString() => 'NotificationsException($failure)';
}
