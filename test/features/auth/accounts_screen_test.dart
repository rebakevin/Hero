import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero/features/auth/domain/account_sessions.dart';
import 'package:hero/features/auth/domain/device_account.dart';
import 'package:hero/features/auth/presentation/accounts_screen.dart';
import 'package:hero/features/auth/presentation/switch_account_link.dart';

import 'fakes.dart';

void main() {
  late FakeAccountSessions sessions;

  setUp(() => sessions = FakeAccountSessions());

  Future<void> pump(WidgetTester tester, Widget home) async {
    await tester.pumpWidget(
      RepositoryProvider<AccountSessions>.value(
        value: sessions,
        child: MaterialApp(home: Scaffold(body: home)),
      ),
    );
    await tester.pump();
  }

  testWidgets('lists every account and marks the current one', (tester) async {
    await pump(tester, const AccountsScreen());

    expect(find.text('Amina Hassan'), findsOneWidget);
    expect(find.text('amina@alustudent.com'), findsOneWidget);
    expect(find.text('kevin@alueducation.com'), findsNWidgets(2));
    expect(find.text('Current'), findsOneWidget);
  });

  testWidgets('tapping another account switches to it', (tester) async {
    await pump(tester, const AccountsScreen());

    await tester.tap(find.text('kevin@alueducation.com').first);
    await tester.pump();

    expect(sessions.activated, ['account1']);
  });

  testWidgets('tapping the current account does nothing', (tester) async {
    await pump(tester, const AccountsScreen());

    await tester.tap(find.text('Amina Hassan'));
    await tester.pump();

    expect(sessions.activated, isEmpty);
  });

  testWidgets('add button opens an empty slot', (tester) async {
    await pump(tester, const AccountsScreen());

    await tester.tap(find.text('Add another account'));
    await tester.pump();

    expect(sessions.activated, ['add']);
  });

  testWidgets('explains the limit when every slot is taken', (tester) async {
    sessions
      ..canAdd = false
      ..list = [
        for (var slot = 0; slot < DeviceAccount.maxPerDevice; slot++)
          DeviceAccount(
            slot: 'account$slot',
            email: 'student$slot@alustudent.com',
            isActive: slot == 0,
          ),
      ];
    await pump(tester, const AccountsScreen());

    expect(find.text('Add another account'), findsNothing);
    expect(find.textContaining('up to 5 accounts'), findsOneWidget);
  });

  testWidgets('offers another try when the accounts cannot load', (
    tester,
  ) async {
    sessions.error = Exception('storage unavailable');
    await pump(tester, const AccountsScreen());

    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('link appears only when another account is signed in', (
    tester,
  ) async {
    await pump(tester, const SwitchAccountLink());
    expect(find.text('Use a signed-in account'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    sessions.list = [sessions.list.first];
    await pump(tester, const SwitchAccountLink());
    expect(find.text('Use a signed-in account'), findsNothing);
  });
}
