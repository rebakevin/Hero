import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero/features/reports/data/history_mapper.dart';
import 'package:hero/features/reports/data/report_mapper.dart';
import 'package:hero/features/reports/domain/building.dart';
import 'package:hero/features/reports/domain/category.dart';
import 'package:hero/features/reports/domain/priority.dart';
import 'package:hero/features/reports/domain/report_draft.dart';
import 'package:hero/features/reports/domain/report_status.dart';

import '../fakes.dart';

void main() {
  const reportKeys = {
    'title',
    'titleLower',
    'description',
    'category',
    'building',
    'room',
    'photoPaths',
    'status',
    'priority',
    'lastHistoryId',
    'reporterId',
    'reporterName',
    'upvoteCount',
    'createdAt',
    'updatedAt',
  };

  final draft = ReportDraft(
    title: 'Broken Tap',
    description: 'The tap on the second floor leaks.',
    category: Category.water,
    building: Building.hostels,
    room: '',
  );

  Map<String, dynamic> storedMap({Object? priority}) => {
    ...ReportMapper.newReportMap(
      draft: draft,
      photoPaths: ['reportPhotos/student-1/r/a.jpg'],
      reporter: aUser(),
    ),
    'priority': priority,
    'createdAt': Timestamp.fromDate(DateTime(2026, 11, 1)),
    'updatedAt': Timestamp.fromDate(DateTime(2026, 11, 2)),
  };

  group('newReportMap', () {
    final map = ReportMapper.newReportMap(
      draft: draft,
      photoPaths: const [],
      reporter: aUser(),
    );

    test('has exactly the 15 keys the rules require', () {
      expect(map.keys.toSet(), reportKeys);
    });

    test('starts submitted with no priority and no votes', () {
      expect(map['status'], 'submitted');
      expect(map['priority'], isNull);
      expect(map['upvoteCount'], 0);
      expect(map['lastHistoryId'], 'initial');
    });

    test('stores the lowercase title and server timestamps', () {
      expect(map['titleLower'], 'broken tap');
      expect(map['createdAt'], isA<FieldValue>());
      expect(map['updatedAt'], isA<FieldValue>());
    });
  });

  test('editMap carries only fields an owner may change', () {
    final map = ReportMapper.editMap(draft: draft, photoPaths: const ['p']);
    expect(map.keys.toSet(), {
      'title',
      'titleLower',
      'description',
      'category',
      'building',
      'room',
      'photoPaths',
      'updatedAt',
    });
  });

  group('fromMap', () {
    test('reads a stored report', () {
      final report = ReportMapper.fromMap('r1', storedMap());
      expect(report.id, 'r1');
      expect(report.category, Category.water);
      expect(report.status, ReportStatus.submitted);
      expect(report.priority, isNull);
      expect(report.createdAt, DateTime(2026, 11, 1));
      expect(report.photoPaths, ['reportPhotos/student-1/r/a.jpg']);
    });

    test('reads a set priority', () {
      final report = ReportMapper.fromMap('r1', storedMap(priority: 'urgent'));
      expect(report.priority, Priority.urgent);
    });

    test('an unknown status key is an error', () {
      final map = storedMap()..['status'] = 'archived';
      expect(() => ReportMapper.fromMap('r1', map), throwsArgumentError);
    });

    test('a missing required field is an error', () {
      final map = storedMap()..remove('title');
      expect(() => ReportMapper.fromMap('r1', map), throwsA(isA<TypeError>()));
    });
  });

  test('initial history entry has the 9 keys the rules require', () {
    final map = HistoryMapper.initialMap(aUser());
    expect(map.keys.toSet(), {
      'actorId',
      'actorName',
      'actorRole',
      'fromStatus',
      'toStatus',
      'fromPriority',
      'toPriority',
      'note',
      'createdAt',
    });
    expect(map['actorRole'], 'student');
    expect(map['fromStatus'], isNull);
    expect(map['note'], 'Report submitted');
  });

  test('history entry round-trips', () {
    final entry = HistoryMapper.fromMap('initial', {
      ...HistoryMapper.initialMap(aUser()),
      'createdAt': Timestamp.fromDate(DateTime(2026, 11, 1)),
    });
    expect(entry.id, 'initial');
    expect(entry.toStatus, ReportStatus.submitted);
    expect(entry.fromStatus, isNull);
  });
}
