import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/building.dart';
import '../domain/category.dart';
import '../domain/report.dart';
import '../domain/report_repository.dart';
import '../domain/similar_reports.dart';
import 'similar_reports_state.dart';

/// The "vote instead of duplicating" hint on the report form.
class SimilarReportsCubit extends Cubit<SimilarReportsState> {
  SimilarReportsCubit(this._repository) : super(const SimilarReportsState());

  final ReportRepository _repository;
  ({Category category, Building building})? _loadedFor;
  List<Report> _candidates = const [];

  /// Call whenever the title, category or building changes.
  Future<void> update({
    required String title,
    required Category? category,
    required Building? building,
  }) async {
    if (category == null || building == null) {
      emit(const SimilarReportsState());
      return;
    }
    final place = (category: category, building: building);
    if (_loadedFor != place) {
      _loadedFor = place;
      _candidates = const [];
      try {
        final found = await _repository.findOpenIn(
          category: category,
          building: building,
        );
        if (isClosed || _loadedFor != place) return;
        _candidates = found;
      } catch (error, stackTrace) {
        // The hint is a convenience; the form works without it.
        log(
          'Finding similar reports failed',
          name: 'SimilarReportsCubit',
          error: error,
          stackTrace: stackTrace,
        );
        _loadedFor = null;
        return;
      }
    }
    if (isClosed) return;
    emit(SimilarReportsState(SimilarReports.matching(title, _candidates)));
  }
}
