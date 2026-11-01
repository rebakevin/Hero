import 'package:equatable/equatable.dart';
import 'package:hero/features/reports/reports.dart';

import 'notification_type.dart';

/// A `users/{uid}/notifications/{id}` document: a staff change to the user's report.
class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.reportId,
    required this.reportTitle,
    required this.type,
    required this.status,
    required this.priority,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String reportId;
  final String reportTitle;
  final NotificationType type;
  final ReportStatus status;
  final Priority? priority;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    reportId,
    reportTitle,
    type,
    status,
    priority,
    message,
    isRead,
    createdAt,
  ];
}
