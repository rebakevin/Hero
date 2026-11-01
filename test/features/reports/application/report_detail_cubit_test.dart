import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero/features/reports/application/report_detail_cubit.dart';
import 'package:hero/features/reports/application/report_detail_state.dart';
import 'package:hero/features/reports/domain/report_failure.dart';

import '../fakes.dart';

void main() {
  late FakeReportRepository repository;
  final report = aReport();

  setUp(() => repository = FakeReportRepository());

  ReportDetailCubit build({bool withInitial = true}) => ReportDetailCubit(
    repository: repository,
    user: aUser(),
    reportId: report.id,
    initial: withInitial ? report : null,
  );

  blocTest<ReportDetailCubit, ReportDetailState>(
    'shows the passed report at once and follows live updates',
    build: build,
    act: (_) => repository.detail.add(aReport(upvoteCount: 3)),
    expect: () => [ReportDetailLoaded(aReport(upvoteCount: 3))],
  );

  blocTest<ReportDetailCubit, ReportDetailState>(
    'a report that disappears is missing',
    build: () => build(withInitial: false),
    act: (_) => repository.detail.add(null),
    expect: () => [const ReportDetailMissing()],
  );

  blocTest<ReportDetailCubit, ReportDetailState>(
    'delete goes through deleting to deleted',
    build: build,
    act: (cubit) => cubit.delete(),
    expect: () => [ReportDetailDeleting(report), const ReportDetailDeleted()],
    verify: (_) => expect(repository.deleted, [report.id]),
  );

  blocTest<ReportDetailCubit, ReportDetailState>(
    'the report vanishing from the stream during delete is not "missing"',
    build: build,
    setUp: () => repository.writeGate = null,
    act: (cubit) async {
      final done = cubit.delete();
      repository.detail.add(null);
      await done;
    },
    expect: () => [ReportDetailDeleting(report), const ReportDetailDeleted()],
  );

  blocTest<ReportDetailCubit, ReportDetailState>(
    'a refused delete returns to the report with the failure',
    build: build,
    setUp: () =>
        repository.writeError = const ReportException(ReportFailure.changed),
    act: (cubit) => cubit.delete(),
    expect: () => [
      ReportDetailDeleting(report),
      ReportDetailDeleteFailed(report, ReportFailure.changed),
    ],
  );

  test('a second delete while one runs is ignored', () async {
    final cubit = build();
    repository.writeGate = Completer();
    final first = cubit.delete();
    await cubit.delete();
    repository.writeGate!.complete();
    await first;
    expect(repository.deleted, hasLength(1));
  });
}
