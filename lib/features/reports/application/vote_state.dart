import 'package:equatable/equatable.dart';

import '../domain/report_failure.dart';

enum VoteStatus { loading, idle, saving, failed }

class VoteState extends Equatable {
  const VoteState({
    this.status = VoteStatus.loading,
    this.hasVoted = false,
    this.failure,
  });

  final VoteStatus status;
  final bool hasVoted;

  /// Set when [status] is [VoteStatus.failed].
  final ReportFailure? failure;

  bool get canToggle =>
      status == VoteStatus.idle || status == VoteStatus.failed;

  VoteState copyWith({
    VoteStatus? status,
    bool? hasVoted,
    ReportFailure? Function()? failure,
  }) => VoteState(
    status: status ?? this.status,
    hasVoted: hasVoted ?? this.hasVoted,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [status, hasVoted, failure];
}
