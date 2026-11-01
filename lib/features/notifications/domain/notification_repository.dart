import 'app_notification.dart';

abstract interface class NotificationRepository {
  /// The user's newest notifications, newest first, live.
  Stream<List<AppNotification>> watchLatest(
    String userId, {
    required int limit,
  });

  /// W7: flips one notification to read.
  Future<void> markRead({
    required String userId,
    required String notificationId,
  });
}
