import 'package:flutter_test/flutter_test.dart';
import 'package:hero/features/reports/application/status_counts_cubit.dart';
import 'package:hero/features/reports/application/status_counts_state.dart';
import 'package:hero/features/reports/domain/report_failure.dart';
import 'package:hero/features/reports/domain/report_status.dart';

import '../fakes.dart';

void main() {
  late FakeReportRepository repository;

  setUp(() => repository = FakeReportRepository());

  test('loads the counts on creation', () async {
    repository.counts = {...repository.counts, ReportStatus.submitted: 4};
    final cubit = StatusCountsCubit(repository);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state, StatusCountsLoaded(repository.counts));
  });

  test('refresh reads the counts again', () async {
    final cubit = StatusCountsCubit(repository);
    await Future<void>.delayed(Duration.zero);
    repository.counts = {...repository.counts, ReportStatus.resolved: 2};
    await cubit.refresh();
    expect(
      (cubit.state as StatusCountsLoaded).counts[ReportStatus.resolved],
      2,
    );
  });

  test('a failure is shown', () async {
    repository.countError = const ReportException(ReportFailure.network);
    final cubit = StatusCountsCubit(repository);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state, const StatusCountsFailure(ReportFailure.network));
  });
}
