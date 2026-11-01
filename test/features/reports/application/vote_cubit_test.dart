import 'package:flutter_test/flutter_test.dart';
import 'package:hero/features/reports/application/vote_cubit.dart';
import 'package:hero/features/reports/application/vote_state.dart';
import 'package:hero/features/reports/domain/report_failure.dart';

import '../fakes.dart';

void main() {
  late FakeVoteRepository repository;

  setUp(() => repository = FakeVoteRepository());

  VoteCubit build() => VoteCubit(
    repository: repository,
    voter: aUser(uid: 'student-2'),
    reportId: 'report-1',
  );

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('starts loading until the vote state arrives', () async {
    final cubit = build();
    expect(cubit.state.status, VoteStatus.loading);
    repository.votes.add(false);
    await settle();
    expect(cubit.state.status, VoteStatus.idle);
    expect(cubit.state.hasVoted, isFalse);
  });

  test('toggle votes when not yet voted', () async {
    final cubit = build();
    repository.votes.add(false);
    await settle();
    await cubit.toggle();
    expect(repository.calls, ['vote']);
    expect(cubit.state.status, VoteStatus.idle);
  });

  test('toggle removes an existing vote', () async {
    final cubit = build();
    repository.votes.add(true);
    await settle();
    await cubit.toggle();
    expect(repository.calls, ['removeVote']);
  });

  test('toggle is ignored before the vote state is known', () async {
    final cubit = build();
    await cubit.toggle();
    expect(repository.calls, isEmpty);
  });

  test('a refused vote reports the failure and can be retried', () async {
    final cubit = build();
    repository.votes.add(false);
    await settle();
    repository.writeError = const ReportException(ReportFailure.changed);
    await cubit.toggle();
    expect(cubit.state.status, VoteStatus.failed);
    expect(cubit.state.failure, ReportFailure.changed);
    expect(cubit.state.canToggle, isTrue);
  });

  test('close cancels the vote subscription', () async {
    final cubit = build();
    await cubit.close();
    expect(repository.votes.hasListener, isFalse);
  });
}
