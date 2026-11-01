import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hero/features/auth/auth.dart';

import '../domain/building.dart';
import '../domain/category.dart';
import '../domain/photo_picker.dart';
import '../domain/photo_source.dart';
import '../domain/report.dart';
import '../domain/report_draft.dart';
import '../domain/report_failure.dart';
import '../domain/report_limits.dart';
import '../domain/report_repository.dart';
import 'report_form_state.dart';

/// Creates a report, or edits [editing] while it is still submitted.
class ReportFormCubit extends Cubit<ReportFormState> {
  ReportFormCubit({
    required ReportRepository repository,
    required this._picker,
    required this._user,
    Report? editing,
  }) : _repository = repository,
       _editing = editing,
       reportId = editing?.id ?? repository.newReportId(),
       super(
         ReportFormState(existingPhotoPaths: editing?.photoPaths ?? const []),
       );

  final ReportRepository _repository;
  final PhotoPicker _picker;
  final AppUser _user;
  final Report? _editing;

  /// Stable for the life of the form, so a retried create writes the same document.
  final String reportId;

  bool get isEditing => _editing != null;

  Future<void> addPhotos(PhotoSource source) async {
    if (state.isSubmitting) return;
    final room = ReportLimits.maxPhotos - state.photoCount;
    if (room <= 0) return;
    try {
      final picked = await _picker.pick(source, limit: room);
      if (isClosed || picked.isEmpty) return;
      emit(
        state.copyWith(
          status: ReportFormStatus.editing,
          newPhotos: [...state.newPhotos, ...picked.take(room)],
          failure: () => null,
        ),
      );
    } on ReportException catch (error) {
      if (!isClosed) _fail(error.failure);
    }
  }

  void removeExistingPhoto(String path) => emit(
    state.copyWith(
      existingPhotoPaths: [
        for (final existing in state.existingPhotoPaths)
          if (existing != path) existing,
      ],
    ),
  );

  void removeNewPhoto(int index) => emit(
    state.copyWith(
      newPhotos: [
        for (var i = 0; i < state.newPhotos.length; i++)
          if (i != index) state.newPhotos[i],
      ],
    ),
  );

  Future<void> submit({
    required String title,
    required String description,
    required Category category,
    required Building building,
    required String room,
  }) async {
    if (state.isSubmitting) return;
    final draft = ReportDraft(
      title: title,
      description: description,
      category: category,
      building: building,
      room: room,
      keptPhotoPaths: state.existingPhotoPaths,
      newPhotos: state.newPhotos,
    );
    if (!draft.isValid) {
      _fail(ReportFailure.invalidInput);
      return;
    }

    emit(
      state.copyWith(
        status: ReportFormStatus.submitting,
        failure: () => null,
        uploaded: 0,
        uploadTotal: state.newPhotos.length,
      ),
    );
    try {
      final original = _editing;
      if (original == null) {
        await _repository.createReport(
          reportId: reportId,
          draft: draft,
          reporter: _user,
          onUploadProgress: _onUploadProgress,
        );
      } else {
        await _repository.updateReport(
          original: original,
          draft: draft,
          editor: _user,
          onUploadProgress: _onUploadProgress,
        );
      }
      if (!isClosed) emit(state.copyWith(status: ReportFormStatus.succeeded));
    } on ReportException catch (error) {
      if (!isClosed) _fail(error.failure);
    } catch (error, stackTrace) {
      log(
        'Saving report failed',
        name: 'ReportFormCubit',
        error: error,
        stackTrace: stackTrace,
      );
      if (!isClosed) _fail(ReportFailure.unknown);
    }
  }

  void _onUploadProgress(int uploaded, int total) {
    if (isClosed) return;
    emit(state.copyWith(uploaded: uploaded, uploadTotal: total));
  }

  void _fail(ReportFailure failure) => emit(
    state.copyWith(status: ReportFormStatus.failed, failure: () => failure),
  );
}
