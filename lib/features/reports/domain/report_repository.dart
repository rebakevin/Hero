import 'package:hero/features/auth/auth.dart';

import 'building.dart';
import 'category.dart';
import 'history_entry.dart';
import 'report.dart';
import 'report_draft.dart';
import 'report_query.dart';
import 'report_status.dart';
import 'status_change.dart';

typedef UploadProgress = void Function(int uploaded, int total);

abstract interface class ReportRepository {
  /// A fresh id, so a retried create writes the same document.
  String newReportId();

  /// Live reports matching [query], at most [limit] of them.
  Stream<List<Report>> watchReports(ReportQuery query, {required int limit});

  /// Live report, or null once it no longer exists.
  Stream<Report?> watchReport(String reportId);

  /// Live audit trail, oldest first.
  Stream<List<HistoryEntry>> watchHistory(String reportId);

  /// How many reports are in each status.
  Future<Map<ReportStatus, int>> countByStatus();

  /// Recent open reports (submitted or in progress) in the same place and category.
  Future<List<Report>> findOpenIn({
    required Category category,
    required Building building,
  });

  /// W2: uploads the photos, then writes the report and its first history entry in one batch.
  Future<void> createReport({
    required String reportId,
    required ReportDraft draft,
    required AppUser reporter,
    UploadProgress? onUploadProgress,
  });

  /// W3: only while [original] can be edited by [editor].
  Future<void> updateReport({
    required Report original,
    required ReportDraft draft,
    required AppUser editor,
    UploadProgress? onUploadProgress,
  });

  /// W5: staff change status and/or priority. Writes the report update, a history
  /// entry and the reporter's notification in one batch.
  Future<void> updateStatus({
    required Report report,
    required StatusChange change,
    required AppUser staff,
  });

  /// W4: removes the report with its history, votes and notifications, then its photos.
  Future<void> deleteReport({required Report report, required AppUser owner});
}
