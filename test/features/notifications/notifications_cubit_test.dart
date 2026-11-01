import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hero/features/notifications/application/notifications_cubit.dart';
import 'package:hero/features/notifications/application/notifications_state.dart';
import 'package:hero/features/notifications/domain/app_notification.dart';
import 'package:hero/features/notifications/domain/notification_repository.dart';
import 'package:hero/features/notifications/domain/notification_type.dart';
import 'package:hero/features/notifications/domain/notifications_failure.dart';
import 'package:hero/features/reports/reports.dart';

AppNotification aNotification({String id = 'n1', bool isRead = false}) =>
    AppNotification(
      id: id,
      reportId: 'report-1',
      reportTitle: 'Broken tap',
      type: NotificationType.statusChange,
      status: ReportStatus.inProgress,
      priority: null,
      message: 'Your report moved to In Progress',
      isRead: isRead,
      createdAt: DateTime(2026, 11, 1),
    );

class FakeNotificationRepository implements NotificationRepository {
  final feed = StreamController<List<AppNotification>>.broadcast();
  final marked = <String>[];
  Object? markError;

  @override
  Stream<List<AppNotification>> watchLatest(
    String userId, {
    required int limit,
  }) => feed.stream;

  @override
  Future<void> markRead({
    required String userId,
    required String notificationId,
  }) async {
    if (markError != null) throw markError!;
    marked.add('$userId:$notificationId');
  }
}

void main() {
  late FakeNotificationRepository repository;
  late NotificationsCubit cubit;

  setUp(() {
    repository = FakeNotificationRepository();
    cubit = NotificationsCubit(repository: repository, userId: 'student-1');
  });

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('counts unread notifications for the bell', () async {
    repository.feed.add([
      aNotification(id: 'a'),
      aNotification(id: 'b', isRead: true),
      aNotification(id: 'c'),
    ]);
    await settle();
    expect(cubit.state.unreadCount, 2);
  });

  test('no notifications is empty with nothing unread', () async {
    repository.feed.add([]);
    await settle();
    expect(cubit.state, isA<NotificationsEmpty>());
    expect(cubit.state.unreadCount, 0);
  });

  test('a stream error becomes a failure', () async {
    repository.feed.addError(
      const NotificationsException(NotificationsFailure.network),
    );
    await settle();
    expect(
      cubit.state,
      const NotificationsFailed(NotificationsFailure.network),
    );
  });

  test('markRead writes only for unread notifications', () async {
    await cubit.markRead(aNotification(id: 'a'));
    await cubit.markRead(aNotification(id: 'b', isRead: true));
    expect(repository.marked, ['student-1:a']);
  });

  test('a failed markRead does not break the list', () async {
    repository.markError = StateError('offline');
    repository.feed.add([aNotification()]);
    await settle();
    await cubit.markRead(aNotification());
    expect(cubit.state, isA<NotificationsLoaded>());
  });

  test('close cancels the subscription', () async {
    await cubit.close();
    expect(repository.feed.hasListener, isFalse);
  });
}
