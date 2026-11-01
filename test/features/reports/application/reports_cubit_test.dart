import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero/features/reports/application/reports_cubit.dart';
import 'package:hero/features/reports/application/reports_state.dart';
import 'package:hero/features/reports/domain/created_range.dart';
import 'package:hero/features/reports/domain/report_failure.dart';
import 'package:hero/features/reports/domain/report_query.dart';
import 'package:hero/features/reports/domain/report_sort.dart';
import 'package:hero/features/reports/domain/report_status.dart';

import '../fakes.dart';

void main() {
  late FakeReportRepository repository;

  setUp(() => repository = FakeReportRepository());

  ReportsCubit build([ReportQuery query = const ReportQuery()]) =>
      ReportsCubit(repository: repository, query: query);

  test('starts loading and subscribes with the first page', () {
    final cubit = build();
    expect(cubit.state, isA<ReportsLoading>());
    expect(repository.limits, [ReportsCubit.pageSize]);
  });

  blocTest<ReportsCubit, ReportsState>(
    'emits loaded when reports arrive',
    build: build,
    act: (_) => repository.latestFeed.add([aReport()]),
    expect: () => [
      ReportsLoaded(const ReportQuery(), reports: [aReport()], hasMore: false),
    ],
  );

  blocTest<ReportsCubit, ReportsState>(
    'emits empty when nothing matches',
    build: build,
    act: (_) => repository.latestFeed.add([]),
    expect: () => [const ReportsEmpty(ReportQuery())],
  );

  blocTest<ReportsCubit, ReportsState>(
    'emits a failure with the repository failure',
    build: build,
    act: (_) => repository.latestFeed.addError(
      const ReportException(ReportFailure.network),
    ),
    expect: () => [const ReportsFailure(ReportQuery(), ReportFailure.network)],
  );

  blocTest<ReportsCubit, ReportsState>(
    'reports an unexpected error as unknown',
    build: build,
    act: (_) => repository.latestFeed.addError(StateError('boom')),
    expect: () => [const ReportsFailure(ReportQuery(), ReportFailure.unknown)],
  );

  blocTest<ReportsCubit, ReportsState>(
    'a full page offers more, and loadMore asks for a bigger page',
    build: build,
    act: (cubit) {
      repository.latestFeed.add([
        for (var i = 0; i < ReportsCubit.pageSize; i++) aReport(id: 'r$i'),
      ]);
    },
    wait: Duration.zero,
    verify: (cubit) {
      expect((cubit.state as ReportsLoaded).hasMore, isTrue);
      cubit.loadMore();
      expect(repository.limits.last, ReportsCubit.pageSize * 2);
    },
  );

  blocTest<ReportsCubit, ReportsState>(
    'applyQuery shows loading and resubscribes with the new query',
    build: build,
    act: (cubit) =>
        cubit.applyQuery(const ReportQuery(status: ReportStatus.resolved)),
    expect: () => [
      const ReportsLoading(ReportQuery(status: ReportStatus.resolved)),
    ],
    verify: (_) =>
        expect(repository.queries.last.status, ReportStatus.resolved),
  );

  test(
    'keeps looking when the client-side filter drops a whole page',
    () async {
      final range = CreatedRange(
        first: DateTime(2026, 11, 1),
        last: DateTime(2026, 11, 1),
      );
      final cubit = build(
        ReportQuery(createdRange: range, sort: ReportSort.mostVotes),
      );
      repository.latestFeed.add([
        for (var i = 0; i < ReportsCubit.pageSize; i++)
          aReport(id: 'old$i', createdAt: DateTime(2026, 10, 1)),
      ]);
      await Future<void>.delayed(Duration.zero);
      expect(repository.limits, [
        ReportsCubit.pageSize,
        ReportsCubit.pageSize * 2,
      ]);
      expect(cubit.state, isA<ReportsLoading>());

      repository.latestFeed.add([
        aReport(id: 'new', createdAt: DateTime(2026, 11, 1, 8)),
      ]);
      await Future<void>.delayed(Duration.zero);
      expect((cubit.state as ReportsLoaded).reports.single.id, 'new');
    },
  );

  test('close cancels the repository subscription', () async {
    final cubit = build();
    await cubit.close();
    expect(repository.latestFeed.hasListener, isFalse);
  });
}
