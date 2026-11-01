import 'package:hero/features/auth/auth.dart';

/// "Me too" votes (W6). Both writes touch the vote document and the report's counter in one batch.
abstract interface class VoteRepository {
  /// Whether [voter] has voted on the report, live.
  Stream<bool> watchHasVoted({
    required String reportId,
    required AppUser voter,
  });

  Future<void> vote({required String reportId, required AppUser voter});

  Future<void> removeVote({required String reportId, required AppUser voter});
}
