import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hero/features/auth/auth.dart';
import 'package:hero/features/reports/application/status_update_cubit.dart';
import 'package:hero/features/reports/application/status_update_state.dart';
import 'package:hero/features/reports/domain/report_failure.dart';
import 'package:hero/features/reports/domain/report_status.dart';

import '../fakes.dart';

void main() {
  late FakeReportRepository repository;

  setUp(() => repository = FakeReportRepository());

  StatusUpdateCubit build() => StatusUpdateCubit(
    repository: repository,
    staff: aUser(uid: 'staff-1', role: Role.staff),
    report: aReport(),
  );

  Future<void> submit(StatusUpdateCubit cubit, {String note = 'On it now'}) =>
      cubit.submit(status: ReportStatus.inProgress, priority: null, note: note);

  test('a valid change is written and succeeds', () async {
    final cubit = build();
    await submit(cubit);
    expect(cubit.state.status, StatusUpdateStatus.succeeded);
    expect(repository.statusChanges.single.status, ReportStatus.inProgress);
  });

  test('no change never reaches the repository', () async {
    final cubit = build();
    await cubit.submit(
      status: ReportStatus.submitted,
      priority: null,
      note: 'Nothing',
    );
    expect(cubit.state.failure, ReportFailure.invalidInput);
    expect(repository.statusChanges, isEmpty);
  });

  test('a missing note never reaches the repository', () async {
    final cubit = build();
    await submit(cubit, note: ' ');
    expect(cubit.state.failure, ReportFailure.invalidInput);
    expect(repository.statusChanges, isEmpty);
  });

  test('a lost race shows as changed so the sheet can be retried', () async {
    repository.writeError = const ReportException(ReportFailure.changed);
    final cubit = build();
    await submit(cubit);
    expect(cubit.state.status, StatusUpdateStatus.failed);
    expect(cubit.state.failure, ReportFailure.changed);
  });

  test('a second submit while one runs is ignored', () async {
    repository.writeGate = Completer();
    final cubit = build();
    final first = submit(cubit);
    await submit(cubit);
    repository.writeGate!.complete();
    await first;
    expect(repository.statusChanges, hasLength(1));
  });
}
