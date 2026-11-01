import 'package:equatable/equatable.dart';

import '../domain/report.dart';
import '../domain/report_failure.dart';
import '../domain/report_query.dart';

sealed class ReportsState extends Equatable {
  const ReportsState(this.query);

  final ReportQuery query;

  @override
  List<Object?> get props => [query];
}

final class ReportsLoading extends ReportsState {
  const ReportsLoading(super.query);
}

final class ReportsLoaded extends ReportsState {
  const ReportsLoaded(
    super.query, {
    required this.reports,
    required this.hasMore,
  });

  final List<Report> reports;

  /// True when the server may hold more reports than are loaded.
  final bool hasMore;

  @override
  List<Object?> get props => [...super.props, reports, hasMore];
}

/// Nothing matches [query].
final class ReportsEmpty extends ReportsState {
  const ReportsEmpty(super.query);
}

final class ReportsFailure extends ReportsState {
  const ReportsFailure(super.query, this.failure);

  final ReportFailure failure;

  @override
  List<Object?> get props => [...super.props, failure];
}
