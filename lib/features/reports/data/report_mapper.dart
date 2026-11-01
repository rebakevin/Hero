import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hero/features/auth/auth.dart';

import '../domain/building.dart';
import '../domain/category.dart';
import '../domain/history_entry.dart';
import '../domain/priority.dart';
import '../domain/report.dart';
import '../domain/report_draft.dart';
import '../domain/report_status.dart';

/// Maps between [Report] and the exact key set the Firestore rules require.
abstract final class ReportMapper {
  static Report fromMap(String id, Map<String, dynamic> map) {
    final priority = map['priority'] as String?;
    return Report(
      id: id,
      title: map['title'] as String,
      description: map['description'] as String,
      category: Category.fromKey(map['category'] as String),
      building: Building.fromKey(map['building'] as String),
      room: map['room'] as String,
      photoPaths: List<String>.unmodifiable(map['photoPaths'] as List),
      status: ReportStatus.fromKey(map['status'] as String),
      priority: priority == null ? null : Priority.fromKey(priority),
      reporterId: map['reporterId'] as String,
      reporterName: map['reporterName'] as String,
      upvoteCount: map['upvoteCount'] as int,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// All 15 keys of a new report (W2).
  static Map<String, dynamic> newReportMap({
    required ReportDraft draft,
    required List<String> photoPaths,
    required AppUser reporter,
  }) => {
    ..._contentMap(draft, photoPaths),
    'status': ReportStatus.submitted.key,
    'priority': null,
    'lastHistoryId': HistoryEntry.initialId,
    'reporterId': reporter.uid,
    'reporterName': reporter.displayName,
    'upvoteCount': 0,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  /// Only the fields an owner may change while the report is submitted (W3).
  static Map<String, dynamic> editMap({
    required ReportDraft draft,
    required List<String> photoPaths,
  }) => {
    ..._contentMap(draft, photoPaths),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  static Map<String, dynamic> _contentMap(
    ReportDraft draft,
    List<String> photoPaths,
  ) => {
    'title': draft.title,
    'titleLower': draft.titleLower,
    'description': draft.description,
    'category': draft.category.key,
    'building': draft.building.key,
    'room': draft.room,
    'photoPaths': photoPaths,
  };
}
