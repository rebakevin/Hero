import 'package:hero/features/auth/auth.dart';

import 'report.dart';
import 'report_draft.dart';
import 'report_query.dart';

typedef UploadProgress = void Function(int uploaded, int total);

abstract interface class ReportRepository {
  /// A fresh id, so a retried create writes the same document.
  String newReportId();

  /// Live reports matching [query], at most [limit] of them.
  Stream<List<Report>> watchReports(ReportQuery query, {required int limit});

  /// Live report, or null once it no longer exists.
  Stream<Report?> watchReport(String reportId);

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

  /// W4: removes the report with its history, votes and notifications, then its photos.
  Future<void> deleteReport({required Report report, required AppUser owner});
}
