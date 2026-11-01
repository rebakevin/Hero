import 'package:flutter_test/flutter_test.dart';
import 'package:hero/features/auth/auth.dart';
import 'package:hero/features/reports/domain/report_status.dart';

import '../fakes.dart';

void main() {
  group('canBeEditedBy', () {
    test('owner may edit a submitted report', () {
      expect(aReport().canBeEditedBy(aUser()), isTrue);
    });

    test('owner may not edit once staff changed the status', () {
      final report = aReport(status: ReportStatus.inProgress);
      expect(report.canBeEditedBy(aUser()), isFalse);
    });

    test('another student may not edit', () {
      expect(aReport().canBeEditedBy(aUser(uid: 'student-2')), isFalse);
    });

    test('staff may not edit', () {
      final staff = aUser(uid: 'staff-1', role: Role.staff);
      expect(aReport().canBeEditedBy(staff), isFalse);
    });
  });
}
