import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hero/features/auth/auth.dart';

import '../domain/created_range.dart';
import '../domain/history_entry.dart';
import '../domain/photo_paths.dart';
import '../domain/photo_storage.dart';
import '../domain/picked_photo.dart';
import '../domain/report.dart';
import '../domain/report_draft.dart';
import '../domain/report_failure.dart';
import '../domain/report_query.dart';
import '../domain/report_repository.dart';
import 'history_mapper.dart';
import 'report_mapper.dart';

class FirestoreReportRepository implements ReportRepository {
  FirestoreReportRepository({required this._firestore, required this._photos});

  /// Without a bound an offline commit would wait forever for the server.
  static const _timeout = Duration(seconds: 30);

  final FirebaseFirestore _firestore;
  final PhotoStorage _photos;

  CollectionReference<Map<String, dynamic>> get _reports =>
      _firestore.collection('reports');

  @override
  String newReportId() => _reports.doc().id;

  @override
  Stream<List<Report>> watchReports(ReportQuery query, {required int limit}) =>
      _translateErrors(
        _buildQuery(query, limit).snapshots().map(
          (snapshot) => [
            for (final doc in snapshot.docs)
              ReportMapper.fromMap(doc.id, doc.data()),
          ],
        ),
      );

  @override
  Stream<Report?> watchReport(String reportId) => _translateErrors(
    _reports.doc(reportId).snapshots().map((snapshot) {
      final data = snapshot.data();
      return data == null ? null : ReportMapper.fromMap(snapshot.id, data);
    }),
  );

  @override
  Future<void> createReport({
    required String reportId,
    required ReportDraft draft,
    required AppUser reporter,
    UploadProgress? onUploadProgress,
  }) async {
    if (!draft.isValid || draft.keptPhotoPaths.isNotEmpty) {
      throw const ReportException(ReportFailure.invalidInput);
    }
    final uploaded = await _uploadAll(
      draft.newPhotos,
      reporterId: reporter.uid,
      reportId: reportId,
      onProgress: onUploadProgress,
    );
    final report = _reports.doc(reportId);
    final batch = _firestore.batch()
      ..set(
        report,
        ReportMapper.newReportMap(
          draft: draft,
          photoPaths: uploaded,
          reporter: reporter,
        ),
      )
      ..set(
        report.collection('history').doc(HistoryEntry.initialId),
        HistoryMapper.initialMap(reporter),
      );
    await _commit(batch, discardOnFailure: uploaded);
  }

  @override
  Future<void> updateReport({
    required Report original,
    required ReportDraft draft,
    required AppUser editor,
    UploadProgress? onUploadProgress,
  }) async {
    if (!original.canBeEditedBy(editor)) {
      throw const ReportException(ReportFailure.changed);
    }
    final keepsOnlyOwnPhotos = draft.keptPhotoPaths.every(
      original.photoPaths.contains,
    );
    if (!draft.isValid || !keepsOnlyOwnPhotos) {
      throw const ReportException(ReportFailure.invalidInput);
    }
    final uploaded = await _uploadAll(
      draft.newPhotos,
      reporterId: editor.uid,
      reportId: original.id,
      onProgress: onUploadProgress,
    );
    final batch = _firestore.batch()
      ..update(
        _reports.doc(original.id),
        ReportMapper.editMap(
          draft: draft,
          photoPaths: [...draft.keptPhotoPaths, ...uploaded],
        ),
      );
    await _commit(batch, discardOnFailure: uploaded);
    await _discardQuietly(
      original.photoPaths.where((p) => !draft.keptPhotoPaths.contains(p)),
    );
  }

  @override
  Future<void> deleteReport({
    required Report report,
    required AppUser owner,
  }) async {
    if (!report.canBeEditedBy(owner)) {
      throw const ReportException(ReportFailure.changed);
    }
    final reportRef = _reports.doc(report.id);
    final batch = _firestore.batch();
    try {
      final subdocuments = await Future.wait([
        reportRef.collection('history').get(),
        reportRef.collection('upvotes').get(),
        _firestore
            .collection('users')
            .doc(owner.uid)
            .collection('notifications')
            .where('reportId', isEqualTo: report.id)
            .get(),
      ]).timeout(_timeout);
      for (final snapshot in subdocuments) {
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
      }
    } on TimeoutException {
      throw const ReportException(ReportFailure.network);
    } on FirebaseException catch (error) {
      throw ReportException(_failureFor(error.code));
    }
    batch.delete(reportRef);
    await _commit(batch);
    await _discardQuietly(report.photoPaths);
  }

  Query<Map<String, dynamic>> _buildQuery(ReportQuery query, int limit) {
    Query<Map<String, dynamic>> result = _reports;
    if (query.reporterId != null) {
      result = result.where('reporterId', isEqualTo: query.reporterId);
    }
    if (query.status != null) {
      result = result.where('status', isEqualTo: query.status!.key);
    }
    if (query.category != null) {
      result = result.where('category', isEqualTo: query.category!.key);
    }
    result = switch (query.serverOrder) {
      ServerOrder.createdAt => _orderByNewest(result, query.createdRange),
      ServerOrder.upvoteCount => result.orderBy(
        'upvoteCount',
        descending: true,
      ),
      ServerOrder.titleLower =>
        result
            .where('titleLower', isGreaterThanOrEqualTo: query.titlePrefix)
            .where('titleLower', isLessThan: '${query.titlePrefix}')
            .orderBy('titleLower'),
    };
    return result.limit(limit);
  }

  Query<Map<String, dynamic>> _orderByNewest(
    Query<Map<String, dynamic>> query,
    CreatedRange? range,
  ) {
    final ranged = range == null
        ? query
        : query
              .where(
                'createdAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(range.first),
              )
              .where(
                'createdAt',
                isLessThan: Timestamp.fromDate(range.endExclusive),
              );
    return ranged.orderBy('createdAt', descending: true);
  }

  Future<List<String>> _uploadAll(
    List<PickedPhoto> photos, {
    required String reporterId,
    required String reportId,
    UploadProgress? onProgress,
  }) async {
    final uploaded = <String>[];
    onProgress?.call(0, photos.length);
    try {
      for (final photo in photos) {
        final path = PhotoPaths.newPath(
          reporterId: reporterId,
          reportId: reportId,
        );
        await _photos.upload(path, photo.bytes);
        uploaded.add(path);
        onProgress?.call(uploaded.length, photos.length);
      }
    } on ReportException {
      await _discardQuietly(uploaded);
      rethrow;
    }
    return uploaded;
  }

  /// Commits [batch]. If the server refuses it, removes [discardOnFailure]
  /// photos. A timeout leaves them: the write may still land and need them.
  Future<void> _commit(
    WriteBatch batch, {
    Iterable<String> discardOnFailure = const [],
  }) async {
    try {
      await batch.commit().timeout(_timeout);
    } on TimeoutException {
      throw const ReportException(ReportFailure.network);
    } on FirebaseException catch (error) {
      await _discardQuietly(discardOnFailure);
      throw ReportException(_failureFor(error.code));
    }
  }

  /// Photo cleanup must never turn a finished write into a failure.
  Future<void> _discardQuietly(Iterable<String> paths) async {
    final list = paths.toList();
    if (list.isEmpty) return;
    try {
      await _photos.delete(list);
    } on ReportException catch (error, stackTrace) {
      log(
        'Leftover photos not removed',
        name: 'FirestoreReportRepository',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Stream<T> _translateErrors<T>(Stream<T> source) => source.transform(
    StreamTransformer.fromHandlers(
      handleError: (error, stackTrace, sink) => sink.addError(
        error is FirebaseException
            ? ReportException(_failureFor(error.code))
            : error,
        stackTrace,
      ),
    ),
  );

  ReportFailure _failureFor(String code) => switch (code) {
    'permission-denied' => ReportFailure.changed,
    'not-found' => ReportFailure.notFound,
    'unavailable' || 'deadline-exceeded' => ReportFailure.network,
    _ => ReportFailure.unknown,
  };
}
