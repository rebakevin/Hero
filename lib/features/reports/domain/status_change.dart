import 'package:equatable/equatable.dart';

import 'change_kind.dart';
import 'priority.dart';
import 'report.dart';
import 'report_status.dart';
import 'report_validators.dart';

/// What staff want a report to become, with the note that explains why.
class StatusChange extends Equatable {
  StatusChange({
    required this.status,
    required this.priority,
    required String note,
  }) : note = note.trim();

  final ReportStatus status;
  final Priority? priority;
  final String note;

  /// Null when the change would leave both status and priority as they are.
  ChangeKind? kindFor(Report report) {
    final statusChanged = status != report.status;
    final priorityChanged = priority != report.priority;
    if (statusChanged && priorityChanged) return ChangeKind.both;
    if (statusChanged) return ChangeKind.statusChange;
    if (priorityChanged) return ChangeKind.priorityChange;
    return null;
  }

  bool isValidFor(Report report) =>
      kindFor(report) != null && ReportValidators.statusNote(note) == null;

  /// The text the reporter sees in their notifications.
  String messageFor(Report report) => switch (kindFor(report)) {
    ChangeKind.statusChange || null => 'Your report moved to ${status.label}',
    ChangeKind.priorityChange => _priorityMessage,
    ChangeKind.both =>
      'Your report moved to ${status.label} with '
          '${priority?.label.toLowerCase() ?? 'no'} priority',
  };

  String get _priorityMessage => switch (priority) {
    final set? => 'Priority set to ${set.label} on your report',
    null => 'Priority cleared on your report',
  };

  @override
  List<Object?> get props => [status, priority, note];
}
