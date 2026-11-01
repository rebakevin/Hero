import 'package:flutter_test/flutter_test.dart';
import 'package:hero/features/reports/application/report_history_cubit.dart';
import 'package:hero/features/reports/application/report_history_state.dart';
import 'package:hero/features/reports/domain/report_failure.dart';

import '../fakes.dart';

void main() {
  test('follows the live history and reports failures', () async {
    final repository = FakeReportRepository();
    final cubit = ReportHistoryCubit(
      repository: repository,
      reportId: 'report-1',
    );
    expect(cubit.state, isA<ReportHistoryLoading>());

    repository.history.add(const []);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state, const ReportHistoryLoaded([]));

    repository.history.addError(const ReportException(ReportFailure.network));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state, const ReportHistoryFailure(ReportFailure.network));
  });
}
