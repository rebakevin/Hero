import 'package:equatable/equatable.dart';

import '../domain/report_failure.dart';
import '../domain/report_status.dart';

sealed class StatusCountsState extends Equatable {
  const StatusCountsState();

  @override
  List<Object?> get props => [];
}

final class StatusCountsLoading extends StatusCountsState {
  const StatusCountsLoading();
}

final class StatusCountsLoaded extends StatusCountsState {
  const StatusCountsLoaded(this.counts);

  final Map<ReportStatus, int> counts;

  @override
  List<Object?> get props => [counts];
}

final class StatusCountsFailure extends StatusCountsState {
  const StatusCountsFailure(this.failure);

  final ReportFailure failure;

  @override
  List<Object?> get props => [failure];
}
