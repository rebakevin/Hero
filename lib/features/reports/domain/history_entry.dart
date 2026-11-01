import 'package:equatable/equatable.dart';
import 'package:hero/features/auth/auth.dart';

import 'priority.dart';
import 'report_status.dart';

/// One line of a report's append-only audit trail.
class HistoryEntry extends Equatable {
  const HistoryEntry({
    required this.id,
    required this.actorId,
    required this.actorName,
    required this.actorRole,
    required this.fromStatus,
    required this.toStatus,
    required this.fromPriority,
    required this.toPriority,
    required this.note,
    required this.createdAt,
  });

  /// Id of the entry written together with every new report.
  static const initialId = 'initial';
  static const initialNote = 'Report submitted';

  final String id;
  final String actorId;
  final String actorName;
  final Role actorRole;
  final ReportStatus? fromStatus;
  final ReportStatus toStatus;
  final Priority? fromPriority;
  final Priority? toPriority;
  final String note;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    actorId,
    actorName,
    actorRole,
    fromStatus,
    toStatus,
    fromPriority,
    toPriority,
    note,
    createdAt,
  ];
}
