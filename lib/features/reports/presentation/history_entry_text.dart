import '../domain/history_entry.dart';

extension HistoryEntryText on HistoryEntry {
  /// One line saying what the entry changed.
  String get headline {
    if (fromStatus == null) return HistoryEntry.initialNote;
    final changes = [
      if (fromStatus != toStatus)
        'Status: ${fromStatus?.label} → ${toStatus.label}',
      if (fromPriority != toPriority)
        'Priority: ${fromPriority?.label ?? 'None'} → ${toPriority?.label ?? 'None'}',
    ];
    return changes.join('\n');
  }
}
