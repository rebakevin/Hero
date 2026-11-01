import 'package:equatable/equatable.dart';

import '../domain/report.dart';
import '../domain/report_failure.dart';

sealed class ReportDetailState extends Equatable {
  const ReportDetailState();

  @override
  List<Object?> get props => [];
}

final class ReportDetailLoading extends ReportDetailState {
  const ReportDetailLoading();
}

/// A report is on screen; the subclasses say what is happening to it.
sealed class ReportDetailShown extends ReportDetailState {
  const ReportDetailShown(this.report);

  final Report report;

  @override
  List<Object?> get props => [report];
}

final class ReportDetailLoaded extends ReportDetailShown {
  const ReportDetailLoaded(super.report);
}

final class ReportDetailDeleting extends ReportDetailShown {
  const ReportDetailDeleting(super.report);
}

final class ReportDetailDeleteFailed extends ReportDetailShown {
  const ReportDetailDeleteFailed(super.report, this.failure);

  final ReportFailure failure;

  @override
  List<Object?> get props => [...super.props, failure];
}

final class ReportDetailDeleted extends ReportDetailState {
  const ReportDetailDeleted();
}

/// The report was removed (by its owner on another device, for example).
final class ReportDetailMissing extends ReportDetailState {
  const ReportDetailMissing();
}

final class ReportDetailFailure extends ReportDetailState {
  const ReportDetailFailure(this.failure);

  final ReportFailure failure;

  @override
  List<Object?> get props => [failure];
}
