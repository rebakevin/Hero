import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hero/features/auth/auth.dart';

import '../domain/report_failure.dart';
import '../domain/vote_repository.dart';
import 'firestore_failure.dart';

class FirestoreVoteRepository implements VoteRepository {
  FirestoreVoteRepository(this._firestore);

  static const _timeout = Duration(seconds: 30);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _report(String reportId) =>
      _firestore.collection('reports').doc(reportId);

  DocumentReference<Map<String, dynamic>> _vote(
    String reportId,
    AppUser voter,
  ) => _report(reportId).collection('upvotes').doc(voter.uid);

  @override
  Stream<bool> watchHasVoted({
    required String reportId,
    required AppUser voter,
  }) => _vote(reportId, voter)
      .snapshots()
      .map((snapshot) => snapshot.exists)
      .transform(
        StreamTransformer.fromHandlers(
          handleError: (error, stackTrace, sink) => sink.addError(
            error is FirebaseException
                ? ReportException(FirestoreFailure.fromCode(error.code))
                : error,
            stackTrace,
          ),
        ),
      );

  @override
  Future<void> vote({required String reportId, required AppUser voter}) {
    final batch = _firestore.batch()
      ..set(_vote(reportId, voter), {'createdAt': FieldValue.serverTimestamp()})
      ..update(_report(reportId), {'upvoteCount': FieldValue.increment(1)});
    return _commit(batch);
  }

  @override
  Future<void> removeVote({required String reportId, required AppUser voter}) {
    final batch = _firestore.batch()
      ..delete(_vote(reportId, voter))
      ..update(_report(reportId), {'upvoteCount': FieldValue.increment(-1)});
    return _commit(batch);
  }

  Future<void> _commit(WriteBatch batch) async {
    try {
      await batch.commit().timeout(_timeout);
    } on TimeoutException {
      throw const ReportException(ReportFailure.network);
    } on FirebaseException catch (error) {
      throw ReportException(FirestoreFailure.fromCode(error.code));
    }
  }
}
