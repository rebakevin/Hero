import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/report_failure.dart';
import '../domain/report_repository.dart';
import 'status_counts_state.dart';

/// The staff header: how many reports sit in each status. Aggregate queries are
/// one-shot, so the screen calls [refresh] whenever the list changes.
class StatusCountsCubit extends Cubit<StatusCountsState> {
  StatusCountsCubit(this._repository) : super(const StatusCountsLoading()) {
    refresh();
  }

  final ReportRepository _repository;
  int _generation = 0;

  Future<void> refresh() async {
    final generation = ++_generation;
    try {
      final counts = await _repository.countByStatus();
      if (!isClosed && generation == _generation) {
        emit(StatusCountsLoaded(counts));
      }
    } on ReportException catch (error) {
      if (!isClosed && generation == _generation) {
        emit(StatusCountsFailure(error.failure));
      }
    } catch (error, stackTrace) {
      log(
        'Counting reports failed',
        name: 'StatusCountsCubit',
        error: error,
        stackTrace: stackTrace,
      );
      if (!isClosed && generation == _generation) {
        emit(const StatusCountsFailure(ReportFailure.unknown));
      }
    }
  }
}
