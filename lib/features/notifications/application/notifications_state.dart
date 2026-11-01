import 'package:equatable/equatable.dart';

import '../domain/app_notification.dart';
import '../domain/notifications_failure.dart';

sealed class NotificationsState extends Equatable {
  const NotificationsState();

  /// Unread among the notifications loaded (the newest ones).
  int get unreadCount => 0;

  @override
  List<Object?> get props => [];
}

final class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

final class NotificationsLoaded extends NotificationsState {
  const NotificationsLoaded(this.notifications);

  final List<AppNotification> notifications;

  @override
  int get unreadCount =>
      notifications.where((notification) => !notification.isRead).length;

  @override
  List<Object?> get props => [notifications];
}

final class NotificationsEmpty extends NotificationsState {
  const NotificationsEmpty();
}

final class NotificationsFailed extends NotificationsState {
  const NotificationsFailed(this.failure);

  final NotificationsFailure failure;

  @override
  List<Object?> get props => [failure];
}
