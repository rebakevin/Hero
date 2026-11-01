import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/report.dart';
import '../domain/report_failure.dart';
import '../domain/report_query.dart';
import '../domain/report_repository.dart';
import 'reports_state.dart';

/// A live, filterable list of reports: the home feed, or one student's own reports
/// when the initial query carries a `reporterId`.
class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit({
    required this._repository,
    ReportQuery query = const ReportQuery(),
  }) : _query = query,
       super(ReportsLoading(query)) {
    _subscribe();
  }

  static const pageSize = 20;

  final ReportRepository _repository;
  ReportQuery _query;
  int _limit = pageSize;
  StreamSubscription<List<Report>>? _subscription;

  /// Replaces the filters and search; the fixed `reporterId` is kept.
  void applyQuery(ReportQuery query) {
    _query = query;
    _limit = pageSize;
    emit(ReportsLoading(_query));
    _subscribe();
  }

  void retry() {
    emit(ReportsLoading(_query));
    _subscribe();
  }

  void loadMore() {
    final current = state;
    if (current is! ReportsLoaded || !current.hasMore) return;
    _limit += pageSize;
    _subscribe();
  }

  void _subscribe() {
    unawaited(_subscription?.cancel());
    _subscription = _repository
        .watchReports(_query, limit: _limit)
        .listen(_onReports, onError: _onError);
  }

  void _onReports(List<Report> reports) {
    final hasMore = reports.length >= _limit;
    final refined = _query.refine(reports);
    if (refined.isEmpty && hasMore) {
      // The client-side filter dropped everything loaded so far; look further.
      loadMore();
      return;
    }
    emit(
      refined.isEmpty
          ? ReportsEmpty(_query)
          : ReportsLoaded(_query, reports: refined, hasMore: hasMore),
    );
  }

  void _onError(Object error, StackTrace stackTrace) {
    if (error is ReportException) {
      emit(ReportsFailure(_query, error.failure));
      return;
    }
    log(
      'Watching reports failed',
      name: 'ReportsCubit',
      error: error,
      stackTrace: stackTrace,
    );
    emit(ReportsFailure(_query, ReportFailure.unknown));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
