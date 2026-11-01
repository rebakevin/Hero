import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hero/features/auth/auth.dart';

import '../domain/history_entry.dart';
import '../domain/priority.dart';
import '../domain/report_status.dart';

abstract final class HistoryMapper {
  static HistoryEntry fromMap(String id, Map<String, dynamic> map) {
    final fromStatus = map['fromStatus'] as String?;
    final fromPriority = map['fromPriority'] as String?;
    final toPriority = map['toPriority'] as String?;
    return HistoryEntry(
      id: id,
      actorId: map['actorId'] as String,
      actorName: map['actorName'] as String,
      actorRole: Role.fromKey(map['actorRole'] as String),
      fromStatus: fromStatus == null ? null : ReportStatus.fromKey(fromStatus),
      toStatus: ReportStatus.fromKey(map['toStatus'] as String),
      fromPriority: fromPriority == null
          ? null
          : Priority.fromKey(fromPriority),
      toPriority: toPriority == null ? null : Priority.fromKey(toPriority),
      note: map['note'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  /// The `history/initial` entry written with every new report (W2).
  static Map<String, dynamic> initialMap(AppUser reporter) => {
    'actorId': reporter.uid,
    'actorName': reporter.displayName,
    'actorRole': Role.student.name,
    'fromStatus': null,
    'toStatus': ReportStatus.submitted.key,
    'fromPriority': null,
    'toPriority': null,
    'note': HistoryEntry.initialNote,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
