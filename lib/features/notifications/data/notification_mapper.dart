import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hero/features/reports/reports.dart';

import '../domain/app_notification.dart';
import '../domain/notification_type.dart';

abstract final class NotificationMapper {
  static AppNotification fromMap(String id, Map<String, dynamic> map) {
    final priority = map['priority'] as String?;
    return AppNotification(
      id: id,
      reportId: map['reportId'] as String,
      reportTitle: map['reportTitle'] as String,
      type: NotificationType.fromKey(map['type'] as String),
      status: ReportStatus.fromKey(map['status'] as String),
      priority: priority == null ? null : Priority.fromKey(priority),
      message: map['message'] as String,
      isRead: map['read'] as bool,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
