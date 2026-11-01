import 'package:equatable/equatable.dart';

import '../domain/report_failure.dart';

enum StatusUpdateStatus { editing, submitting, succeeded, failed }

class StatusUpdateState extends Equatable {
  const StatusUpdateState({
    this.status = StatusUpdateStatus.editing,
    this.failure,
  });

  final StatusUpdateStatus status;

  /// Set when [status] is [StatusUpdateStatus.failed].
  final ReportFailure? failure;

  bool get isSubmitting => status == StatusUpdateStatus.submitting;

  @override
  List<Object?> get props => [status, failure];
}
