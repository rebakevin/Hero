import 'package:equatable/equatable.dart';

import 'building.dart';
import 'category.dart';
import 'picked_photo.dart';
import 'report_limits.dart';
import 'report_validators.dart';

/// What the form hands over to create or edit a report: no id, no timestamps, no votes.
class ReportDraft extends Equatable {
  ReportDraft({
    required String title,
    required String description,
    required this.category,
    required this.building,
    required String room,
    this.keptPhotoPaths = const [],
    this.newPhotos = const [],
  }) : title = title.trim(),
       description = description.trim(),
       room = room.trim();

  final String title;
  final String description;
  final Category category;
  final Building building;
  final String room;

  /// Photos already stored for the report (edit only).
  final List<String> keptPhotoPaths;

  /// Photos still to upload.
  final List<PickedPhoto> newPhotos;

  String get titleLower => title.toLowerCase();

  int get photoCount => keptPhotoPaths.length + newPhotos.length;

  bool get isValid =>
      ReportValidators.title(title) == null &&
      ReportValidators.description(description) == null &&
      ReportValidators.room(room) == null &&
      photoCount <= ReportLimits.maxPhotos &&
      newPhotos.every(
        (photo) => photo.bytes.length <= ReportLimits.maxPhotoBytes,
      );

  @override
  List<Object?> get props => [
    title,
    description,
    category,
    building,
    room,
    keptPhotoPaths,
    newPhotos,
  ];
}
