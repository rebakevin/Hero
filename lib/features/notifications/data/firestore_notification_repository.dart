import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/app_notification.dart';
import '../domain/notification_repository.dart';
import '../domain/notifications_failure.dart';
import 'notification_mapper.dart';

class FirestoreNotificationRepository implements NotificationRepository {
  FirestoreNotificationRepository(this._firestore);

  static const _timeout = Duration(seconds: 30);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _notifications(String userId) =>
      _firestore.collection('users').doc(userId).collection('notifications');

  @override
  Stream<List<AppNotification>> watchLatest(
    String userId, {
    required int limit,
  }) =>
      _notifications(userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map(
            (snapshot) => [
              for (final doc in snapshot.docs)
                NotificationMapper.fromMap(doc.id, doc.data()),
            ],
          )
          .transform(
            StreamTransformer.fromHandlers(
              handleError: (error, stackTrace, sink) => sink.addError(
                error is FirebaseException ? _translate(error) : error,
                stackTrace,
              ),
            ),
          );

  @override
  Future<void> markRead({
    required String userId,
    required String notificationId,
  }) async {
    try {
      await _notifications(userId)
          .doc(notificationId)
          .update({'read': true})
          .timeout(_timeout);
    } on TimeoutException {
      throw const NotificationsException(NotificationsFailure.network);
    } on FirebaseException catch (error) {
      throw _translate(error);
    }
  }

  NotificationsException _translate(FirebaseException error) =>
      NotificationsException(
        error.code == 'unavailable' || error.code == 'deadline-exceeded'
            ? NotificationsFailure.network
            : NotificationsFailure.unknown,
      );
}
