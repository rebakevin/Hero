import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hero/features/auth/auth.dart';

import '../domain/change_kind.dart';
import '../domain/report.dart';
import '../domain/status_change.dart';

/// The three documents of a staff update (W5), with the exact keys the rules require.
abstract final class StatusChangeMapper {
  static Map<String, dynamic> reportUpdate(
    StatusChange change,
    String historyId,
  ) => {
    'status': change.status.key,
    'priority': change.priority?.key,
    'lastHistoryId': historyId,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  static Map<String, dynamic> historyEntry({
    required Report report,
    required StatusChange change,
    required AppUser staff,
  }) => {
    'actorId': staff.uid,
    'actorName': staff.displayName,
    'actorRole': Role.staff.name,
    'fromStatus': report.status.key,
    'toStatus': change.status.key,
    'fromPriority': report.priority?.key,
    'toPriority': change.priority?.key,
    'note': change.note,
    'createdAt': FieldValue.serverTimestamp(),
  };

  static Map<String, dynamic> notification({
    required Report report,
    required StatusChange change,
    required ChangeKind kind,
  }) => {
    'reportId': report.id,
    'reportTitle': report.title,
    'type': kind.key,
    'status': change.status.key,
    'priority': change.priority?.key,
    'message': change.messageFor(report),
    'read': false,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
