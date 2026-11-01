import 'package:flutter_test/flutter_test.dart';
import 'package:hero/features/auth/auth.dart';
import 'package:hero/features/reports/domain/change_kind.dart';
import 'package:hero/features/reports/domain/priority.dart';
import 'package:hero/features/reports/domain/report_status.dart';
import 'package:hero/features/reports/domain/similar_reports.dart';
import 'package:hero/features/reports/domain/status_change.dart';

import '../fakes.dart';

void main() {
  final report = aReport();

  StatusChange change({
    ReportStatus status = ReportStatus.submitted,
    Priority? priority,
    String note = 'Looking into it',
  }) => StatusChange(status: status, priority: priority, note: note);

  group('kindFor', () {
    test('nothing changed is null', () {
      expect(change().kindFor(report), isNull);
    });
    test('only the status changed', () {
      expect(
        change(status: ReportStatus.inProgress).kindFor(report),
        ChangeKind.statusChange,
      );
    });
    test('only the priority changed', () {
      expect(
        change(priority: Priority.high).kindFor(report),
        ChangeKind.priorityChange,
      );
    });
    test('clearing a priority counts as a change', () {
      final prioritised = aReport(priority: Priority.low);
      expect(change().kindFor(prioritised), ChangeKind.priorityChange);
    });
    test('both changed', () {
      expect(
        change(
          status: ReportStatus.resolved,
          priority: Priority.low,
        ).kindFor(report),
        ChangeKind.both,
      );
    });
  });

  group('isValidFor', () {
    test('needs a change', () {
      expect(change().isValidFor(report), isFalse);
    });
    test('needs a note of at least 3 characters', () {
      final moved = ReportStatus.inProgress;
      expect(change(status: moved, note: ' ok ').isValidFor(report), isFalse);
      expect(change(status: moved, note: 'ok!').isValidFor(report), isTrue);
    });
    test('note over 300 characters is rejected', () {
      expect(
        change(
          status: ReportStatus.inProgress,
          note: 'a' * 301,
        ).isValidFor(report),
        isFalse,
      );
    });
  });

  group('messageFor', () {
    test('status change', () {
      expect(
        change(status: ReportStatus.inProgress).messageFor(report),
        'Your report moved to In Progress',
      );
    });
    test('priority change', () {
      expect(
        change(priority: Priority.urgent).messageFor(report),
        'Priority set to Urgent on your report',
      );
    });
    test('both', () {
      expect(
        change(
          status: ReportStatus.resolved,
          priority: Priority.low,
        ).messageFor(report),
        'Your report moved to Resolved with low priority',
      );
    });
  });

  group('report permissions', () {
    final staff = aUser(uid: 'staff-1', role: Role.staff);
    test('only staff update status', () {
      expect(report.canBeUpdatedBy(staff), isTrue);
      expect(report.canBeUpdatedBy(aUser()), isFalse);
    });
    test('only other students vote', () {
      expect(report.canBeVotedBy(aUser(uid: 'student-2')), isTrue);
      expect(report.canBeVotedBy(aUser()), isFalse);
      expect(report.canBeVotedBy(staff), isFalse);
    });
  });

  group('SimilarReports', () {
    final leak = aReport(id: 'a', title: 'Water leaking in hostel corridor');
    final power = aReport(id: 'b', title: 'Power outage in library');

    test('a short title suggests nothing', () {
      expect(SimilarReports.matching('wa', [leak]), isEmpty);
    });
    test('keeps reports sharing a meaningful word', () {
      expect(SimilarReports.matching('Hostel water problem', [leak, power]), [
        leak,
      ]);
    });
    test('ignores short words and case', () {
      expect(SimilarReports.matching('IN the OUT', [leak, power]), isEmpty);
      expect(SimilarReports.matching('LEAKING tap', [leak]), [leak]);
    });
    test('shows at most three', () {
      final many = [
        for (var i = 0; i < 5; i++) aReport(id: '$i', title: 'Broken tap $i'),
      ];
      expect(SimilarReports.matching('broken', many), hasLength(3));
    });
  });
}
