import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hero/features/auth/auth.dart';

import '../domain/priority.dart';
import '../domain/report.dart';
import '../domain/report_failure.dart';
import '../domain/report_repository.dart';
import '../domain/report_status.dart';
import '../domain/status_change.dart';
import 'status_update_state.dart';

/// Staff change a report's status and priority with a note (W5).
class StatusUpdateCubit extends Cubit<StatusUpdateState> {
  StatusUpdateCubit({
    required this._repository,
    required this._staff,
    required this._report,
  }) : super(const StatusUpdateState());

  final ReportRepository _repository;
  final AppUser _staff;
  final Report _report;

  Future<void> submit({
    required ReportStatus status,
    required Priority? priority,
    required String note,
  }) async {
    if (state.isSubmitting) return;
    final change = StatusChange(status: status, priority: priority, note: note);
    if (!change.isValidFor(_report)) {
      emit(
        const StatusUpdateState(
          status: StatusUpdateStatus.failed,
          failure: ReportFailure.invalidInput,
        ),
      );
      return;
    }
    emit(const StatusUpdateState(status: StatusUpdateStatus.submitting));
    try {
      await _repository.updateStatus(
        report: _report,
        change: change,
        staff: _staff,
      );
      if (!isClosed) {
        emit(const StatusUpdateState(status: StatusUpdateStatus.succeeded));
      }
    } on ReportException catch (error) {
      if (!isClosed) _fail(error.failure);
    } catch (error, stackTrace) {
      log(
        'Updating status failed',
        name: 'StatusUpdateCubit',
        error: error,
        stackTrace: stackTrace,
      );
      if (!isClosed) _fail(ReportFailure.unknown);
    }
  }

  void _fail(ReportFailure failure) => emit(
    StatusUpdateState(status: StatusUpdateStatus.failed, failure: failure),
  );
}
