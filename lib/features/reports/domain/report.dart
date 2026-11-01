import 'package:equatable/equatable.dart';
import 'package:hero/features/auth/auth.dart';

import 'building.dart';
import 'category.dart';
import 'priority.dart';
import 'report_status.dart';

/// A `reports/{reportId}` document. Photos are object paths, never URLs.
class Report extends Equatable {
  const Report({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.building,
    required this.room,
    required this.photoPaths,
    required this.status,
    required this.priority,
    required this.reporterId,
    required this.reporterName,
    required this.upvoteCount,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final Category category;
  final Building building;
  final String room;
  final List<String> photoPaths;
  final ReportStatus status;
  final Priority? priority;
  final String reporterId;
  final String reporterName;
  final int upvoteCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isSafety => category == Category.safety;

  bool get hasPhotos => photoPaths.isNotEmpty;

  bool isOwnedBy(AppUser user) => reporterId == user.uid;

  /// Owners may edit or delete only while staff have not touched the report.
  bool canBeEditedBy(AppUser user) =>
      isOwnedBy(user) && status == ReportStatus.submitted;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    category,
    building,
    room,
    photoPaths,
    status,
    priority,
    reporterId,
    reporterName,
    upvoteCount,
    createdAt,
    updatedAt,
  ];
}
