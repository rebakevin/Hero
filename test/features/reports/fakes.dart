import 'dart:async';
import 'dart:typed_data';

import 'package:hero/features/auth/auth.dart';
import 'package:hero/features/reports/domain/building.dart';
import 'package:hero/features/reports/domain/category.dart';
import 'package:hero/features/reports/domain/photo_picker.dart';
import 'package:hero/features/reports/domain/photo_source.dart';
import 'package:hero/features/reports/domain/picked_photo.dart';
import 'package:hero/features/reports/domain/priority.dart';
import 'package:hero/features/reports/domain/report.dart';
import 'package:hero/features/reports/domain/report_draft.dart';
import 'package:hero/features/reports/domain/report_failure.dart';
import 'package:hero/features/reports/domain/report_query.dart';
import 'package:hero/features/reports/domain/report_repository.dart';
import 'package:hero/features/reports/domain/report_status.dart';

Report aReport({
  String id = 'report-1',
  String title = 'Broken tap in hostel',
  Category category = Category.water,
  ReportStatus status = ReportStatus.submitted,
  Priority? priority,
  String reporterId = 'student-1',
  int upvoteCount = 0,
  DateTime? createdAt,
  List<String> photoPaths = const [],
}) => Report(
  id: id,
  title: title,
  description: 'The tap on the second floor leaks all day.',
  category: category,
  building: Building.hostels,
  room: '',
  photoPaths: photoPaths,
  status: status,
  priority: priority,
  reporterId: reporterId,
  reporterName: 'Amina Hassan',
  upvoteCount: upvoteCount,
  createdAt: createdAt ?? DateTime(2026, 11, 1, 9),
  updatedAt: createdAt ?? DateTime(2026, 11, 1, 9),
);

AppUser aUser({String uid = 'student-1', Role role = Role.student}) => AppUser(
  uid: uid,
  displayName: 'Amina Hassan',
  email: 'amina@alustudent.com',
  role: role,
  createdAt: DateTime(2026, 11, 1),
);

PickedPhoto aPhoto([int byte = 1]) =>
    PickedPhoto(Uint8List.fromList([byte, byte, byte]));

class FakeReportRepository implements ReportRepository {
  final feeds = <StreamController<List<Report>>>[];
  final queries = <ReportQuery>[];
  final limits = <int>[];
  final detail = StreamController<Report?>.broadcast();
  final created = <ReportDraft>[];
  final updated = <ReportDraft>[];
  final deleted = <String>[];
  Object? writeError;
  Completer<void>? writeGate;

  @override
  String newReportId() => 'new-report';

  @override
  Stream<List<Report>> watchReports(ReportQuery query, {required int limit}) {
    queries.add(query);
    limits.add(limit);
    final controller = StreamController<List<Report>>();
    feeds.add(controller);
    return controller.stream;
  }

  StreamController<List<Report>> get latestFeed => feeds.last;

  @override
  Stream<Report?> watchReport(String reportId) => detail.stream;

  Future<void> _write() async {
    await writeGate?.future;
    if (writeError != null) throw writeError!;
  }

  @override
  Future<void> createReport({
    required String reportId,
    required ReportDraft draft,
    required AppUser reporter,
    UploadProgress? onUploadProgress,
  }) async {
    created.add(draft);
    onUploadProgress?.call(draft.newPhotos.length, draft.newPhotos.length);
    await _write();
  }

  @override
  Future<void> updateReport({
    required Report original,
    required ReportDraft draft,
    required AppUser editor,
    UploadProgress? onUploadProgress,
  }) async {
    updated.add(draft);
    await _write();
  }

  @override
  Future<void> deleteReport({
    required Report report,
    required AppUser owner,
  }) async {
    deleted.add(report.id);
    await _write();
  }
}

class FakePhotoPicker implements PhotoPicker {
  List<PickedPhoto> next = [];
  ReportFailure? failWith;
  final requestedLimits = <int>[];

  @override
  Future<List<PickedPhoto>> pick(
    PhotoSource source, {
    required int limit,
  }) async {
    requestedLimits.add(limit);
    if (failWith != null) throw ReportException(failWith!);
    return next;
  }
}
