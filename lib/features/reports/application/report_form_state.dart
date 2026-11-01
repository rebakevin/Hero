import 'package:equatable/equatable.dart';

import '../domain/picked_photo.dart';
import '../domain/report_failure.dart';
import '../domain/report_limits.dart';

enum ReportFormStatus { editing, submitting, succeeded, failed }

class ReportFormState extends Equatable {
  const ReportFormState({
    this.status = ReportFormStatus.editing,
    this.existingPhotoPaths = const [],
    this.newPhotos = const [],
    this.failure,
    this.uploaded = 0,
    this.uploadTotal = 0,
  });

  final ReportFormStatus status;

  /// Photos already stored for the report being edited.
  final List<String> existingPhotoPaths;
  final List<PickedPhoto> newPhotos;

  /// Set when [status] is [ReportFormStatus.failed].
  final ReportFailure? failure;
  final int uploaded;
  final int uploadTotal;

  int get photoCount => existingPhotoPaths.length + newPhotos.length;

  bool get canAddPhoto => photoCount < ReportLimits.maxPhotos;

  bool get isSubmitting => status == ReportFormStatus.submitting;

  ReportFormState copyWith({
    ReportFormStatus? status,
    List<String>? existingPhotoPaths,
    List<PickedPhoto>? newPhotos,
    ReportFailure? Function()? failure,
    int? uploaded,
    int? uploadTotal,
  }) => ReportFormState(
    status: status ?? this.status,
    existingPhotoPaths: existingPhotoPaths ?? this.existingPhotoPaths,
    newPhotos: newPhotos ?? this.newPhotos,
    failure: failure != null ? failure() : this.failure,
    uploaded: uploaded ?? this.uploaded,
    uploadTotal: uploadTotal ?? this.uploadTotal,
  );

  @override
  List<Object?> get props => [
    status,
    existingPhotoPaths,
    newPhotos,
    failure,
    uploaded,
    uploadTotal,
  ];
}
