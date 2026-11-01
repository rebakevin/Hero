import 'package:flutter_test/flutter_test.dart';
import 'package:hero/features/auth/auth.dart';
import 'package:hero/features/reports/data/status_change_mapper.dart';
import 'package:hero/features/reports/domain/change_kind.dart';
import 'package:hero/features/reports/domain/priority.dart';
import 'package:hero/features/reports/domain/report_status.dart';
import 'package:hero/features/reports/domain/status_change.dart';

import '../fakes.dart';

void main() {
  final report = aReport(priority: Priority.low);
  final staff = aUser(uid: 'staff-1', role: Role.staff);
  final change = StatusChange(
    status: ReportStatus.inProgress,
    priority: Priority.high,
    note: 'Plumber booked',
  );

  test('report update carries only staff-writable keys', () {
    final map = StatusChangeMapper.reportUpdate(change, 'h1');
    expect(map.keys.toSet(), {
      'status',
      'priority',
      'lastHistoryId',
      'updatedAt',
    });
    expect(map['status'], 'inProgress');
    expect(map['priority'], 'high');
    expect(map['lastHistoryId'], 'h1');
  });

  test('history entry holds before and after values and the note', () {
    final map = StatusChangeMapper.historyEntry(
      report: report,
      change: change,
      staff: staff,
    );
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
    expect(map['actorRole'], 'staff');
    expect(map['fromStatus'], 'submitted');
    expect(map['toStatus'], 'inProgress');
    expect(map['fromPriority'], 'low');
    expect(map['toPriority'], 'high');
    expect(map['note'], 'Plumber booked');
  });

  test('notification has the 8 keys, starts unread and names the change', () {
    final map = StatusChangeMapper.notification(
      report: report,
      change: change,
      kind: ChangeKind.both,
    );
    expect(map.keys.toSet(), {
      'reportId',
      'reportTitle',
      'type',
      'status',
      'priority',
      'message',
      'read',
      'createdAt',
    });
    expect(map['type'], 'both');
    expect(map['read'], false);
    expect(map['reportTitle'], report.title);
  });

  test('a cleared priority is stored as an explicit null', () {
    final cleared = StatusChange(
      status: ReportStatus.resolved,
      priority: null,
      note: 'All fixed',
    );
    expect(StatusChangeMapper.reportUpdate(cleared, 'h')['priority'], isNull);
  });
}
