import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hero/features/auth/auth.dart';

import '../domain/report.dart';
import '../domain/report_failure.dart';
import '../domain/report_repository.dart';
import 'report_detail_state.dart';

/// One report, kept live, with the owner's delete action.
class ReportDetailCubit extends Cubit<ReportDetailState> {
  ReportDetailCubit({
    required this._repository,
    required this._user,
    required this._reportId,
    Report? initial,
  }) : super(
         initial == null
             ? const ReportDetailLoading()
             : ReportDetailLoaded(initial),
       ) {
    _subscribe();
  }

  final ReportRepository _repository;
  final AppUser _user;
  final String _reportId;
  StreamSubscription<Report?>? _subscription;

  void retry() {
    emit(const ReportDetailLoading());
    _subscribe();
  }

  Future<void> delete() async {
    final current = state;
    if (current is! ReportDetailShown || current is ReportDetailDeleting) {
      return;
    }
    emit(ReportDetailDeleting(current.report));
    try {
      await _repository.deleteReport(report: current.report, owner: _user);
      if (!isClosed) emit(const ReportDetailDeleted());
    } on ReportException catch (error) {
      if (!isClosed) {
        emit(ReportDetailDeleteFailed(current.report, error.failure));
      }
    } catch (error, stackTrace) {
      log(
        'Deleting report failed',
        name: 'ReportDetailCubit',
        error: error,
        stackTrace: stackTrace,
      );
      if (!isClosed) {
        emit(ReportDetailDeleteFailed(current.report, ReportFailure.unknown));
      }
    }
  }

  void _subscribe() {
    unawaited(_subscription?.cancel());
    _subscription = _repository
        .watchReport(_reportId)
        .listen(_onReport, onError: _onError);
  }

  void _onReport(Report? report) {
    // Our own delete removes the report from the stream before it completes.
    if (state is ReportDetailDeleting || state is ReportDetailDeleted) return;
    emit(
      report == null ? const ReportDetailMissing() : ReportDetailLoaded(report),
    );
  }

  void _onError(Object error, StackTrace stackTrace) {
    if (state is ReportDetailDeleting || state is ReportDetailDeleted) return;
    if (error is ReportException) {
      emit(ReportDetailFailure(error.failure));
      return;
    }
    log(
      'Watching report failed',
      name: 'ReportDetailCubit',
      error: error,
      stackTrace: stackTrace,
    );
    emit(const ReportDetailFailure(ReportFailure.unknown));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
