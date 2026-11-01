import 'package:equatable/equatable.dart';

import '../domain/history_entry.dart';
import '../domain/report_failure.dart';

sealed class ReportHistoryState extends Equatable {
  const ReportHistoryState();

  @override
  List<Object?> get props => [];
}

final class ReportHistoryLoading extends ReportHistoryState {
  const ReportHistoryLoading();
}

final class ReportHistoryLoaded extends ReportHistoryState {
  const ReportHistoryLoaded(this.entries);

  final List<HistoryEntry> entries;

  @override
  List<Object?> get props => [entries];
}

final class ReportHistoryFailure extends ReportHistoryState {
  const ReportHistoryFailure(this.failure);

  final ReportFailure failure;

  @override
  List<Object?> get props => [failure];
}
