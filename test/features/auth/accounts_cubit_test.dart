import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero/features/auth/application/accounts_cubit.dart';
import 'package:hero/features/auth/application/accounts_state.dart';
import 'package:hero/features/auth/domain/auth_failure.dart';

import 'fakes.dart';

void main() {
  late FakeAccountSessions sessions;

  setUp(() => sessions = FakeAccountSessions());

  blocTest<AccountsCubit, AccountsState>(
    'load emits the accounts and whether another can be added',
    build: () => AccountsCubit(sessions),
    act: (cubit) => cubit.load(),
    expect: () => [AccountsLoaded(accounts: sessions.list, canAdd: true)],
  );

  blocTest<AccountsCubit, AccountsState>(
    'load failure emits a failed state',
    build: () {
      sessions.error = Exception('storage unavailable');
      return AccountsCubit(sessions);
    },
    act: (cubit) => cubit.load(),
    expect: () => [const AccountsFailed(AuthFailure.unknown)],
  );

  blocTest<AccountsCubit, AccountsState>(
    'switchTo activates the chosen slot',
    build: () => AccountsCubit(sessions),
    act: (cubit) => cubit.switchTo('account1'),
    verify: (_) => expect(sessions.activated, ['account1']),
  );

  blocTest<AccountsCubit, AccountsState>(
    'a second tap while switching is ignored',
    build: () => AccountsCubit(sessions),
    act: (cubit) =>
        Future.wait([cubit.switchTo('account1'), cubit.switchTo('account2')]),
    verify: (_) => expect(sessions.activated, ['account1']),
  );

  blocTest<AccountsCubit, AccountsState>(
    'addAccount asks for an empty slot',
    build: () => AccountsCubit(sessions),
    act: (cubit) => cubit.addAccount(),
    verify: (_) => expect(sessions.activated, ['add']),
  );

  blocTest<AccountsCubit, AccountsState>(
    'a failed switch emits a failed state',
    build: () {
      sessions.error = Exception('storage unavailable');
      return AccountsCubit(sessions);
    },
    act: (cubit) => cubit.switchTo('account1'),
    expect: () => [const AccountsFailed(AuthFailure.unknown)],
  );

  test('hasOtherAccounts is false with only the current account', () {
    final current = sessions.list.where((account) => account.isActive).toList();

    expect(
      AccountsLoaded(accounts: current, canAdd: true).hasOtherAccounts,
      isFalse,
    );
    expect(
      AccountsLoaded(accounts: sessions.list, canAdd: true).hasOtherAccounts,
      isTrue,
    );
  });
}
