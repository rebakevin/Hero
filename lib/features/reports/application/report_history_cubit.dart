import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/history_entry.dart';
import '../domain/report_failure.dart';
import '../domain/report_repository.dart';
import 'report_history_state.dart';

/// A report's status timeline, kept live.
class ReportHistoryCubit extends Cubit<ReportHistoryState> {
  ReportHistoryCubit({required this._repository, required this._reportId})
    : super(const ReportHistoryLoading()) {
    _subscribe();
  }

  final ReportRepository _repository;
  final String _reportId;
  StreamSubscription<List<HistoryEntry>>? _subscription;

  void retry() {
    emit(const ReportHistoryLoading());
    _subscribe();
  }

  void _subscribe() {
    unawaited(_subscription?.cancel());
    _subscription = _repository
        .watchHistory(_reportId)
        .listen(
          (entries) => emit(ReportHistoryLoaded(entries)),
          onError: _onError,
        );
  }

  void _onError(Object error, StackTrace stackTrace) {
    if (error is ReportException) {
      emit(ReportHistoryFailure(error.failure));
      return;
    }
    log(
      'Watching history failed',
      name: 'ReportHistoryCubit',
      error: error,
      stackTrace: stackTrace,
    );
    emit(const ReportHistoryFailure(ReportFailure.unknown));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
