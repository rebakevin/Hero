import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/app_notification.dart';
import '../domain/notification_repository.dart';
import '../domain/notifications_failure.dart';
import 'notifications_state.dart';

/// The signed-in student's notifications, live, with the unread count for the bell.
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({required this._repository, required this._userId})
    : super(const NotificationsLoading()) {
    _subscribe();
  }

  /// Older notifications are not loaded; the badge counts unread among these.
  static const latestLimit = 50;

  final NotificationRepository _repository;
  final String _userId;
  StreamSubscription<List<AppNotification>>? _subscription;

  void retry() {
    emit(const NotificationsLoading());
    _subscribe();
  }

  Future<void> markRead(AppNotification notification) async {
    if (notification.isRead) return;
    try {
      await _repository.markRead(
        userId: _userId,
        notificationId: notification.id,
      );
    } catch (error, stackTrace) {
      // Stays unread and shows again next time; not worth interrupting the user.
      log(
        'Marking notification read failed',
        name: 'NotificationsCubit',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _subscribe() {
    unawaited(_subscription?.cancel());
    _subscription = _repository
        .watchLatest(_userId, limit: latestLimit)
        .listen(_onNotifications, onError: _onError);
  }

  void _onNotifications(List<AppNotification> notifications) => emit(
    notifications.isEmpty
        ? const NotificationsEmpty()
        : NotificationsLoaded(notifications),
  );

  void _onError(Object error, StackTrace stackTrace) {
    if (error is NotificationsException) {
      emit(NotificationsFailed(error.failure));
      return;
    }
    log(
      'Watching notifications failed',
      name: 'NotificationsCubit',
      error: error,
      stackTrace: stackTrace,
    );
    emit(const NotificationsFailed(NotificationsFailure.unknown));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
