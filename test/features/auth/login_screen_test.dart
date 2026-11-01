import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero/features/auth/domain/auth_failure.dart';
import 'package:hero/features/auth/domain/auth_repository.dart';
import 'package:hero/features/auth/presentation/login_screen.dart';

import 'fakes.dart';

void main() {
  late FakeAuthRepository auth;

  setUp(() => auth = FakeAuthRepository());

  Future<void> pumpScreen(WidgetTester tester) => tester.pumpWidget(
    RepositoryProvider<AuthRepository>.value(
      value: auth,
      child: const MaterialApp(home: LoginScreen()),
    ),
  );

  testWidgets('shows field errors and does not submit when empty', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Log in').last);
    await tester.pump();

    expect(find.text('Enter your email.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
    expect(auth.calls, isEmpty);
  });

  testWidgets('rejects a non-ALU email', (tester) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextFormField).first, 'amina@gmail.com');
    await tester.tap(find.text('Log in').last);
    await tester.pump();

    expect(find.textContaining('@alustudent.com'), findsWidgets);
    expect(auth.calls, isEmpty);
  });

  testWidgets('submits a normalised email once the form is valid', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.enterText(
      find.byType(TextFormField).first,
      '  Amina@AluStudent.com ',
    );
    await tester.enterText(find.byType(TextFormField).last, 'hunter22');
    await tester.tap(find.text('Log in').last);
    await tester.pump();

    expect(auth.calls, ['signIn:amina@alustudent.com']);
  });

  testWidgets('shows the failure message from a rejected sign-in', (
    tester,
  ) async {
    auth.failWith = AuthFailure.invalidCredentials;
    await pumpScreen(tester);

    await tester.enterText(
      find.byType(TextFormField).first,
      'amina@alustudent.com',
    );
    await tester.enterText(find.byType(TextFormField).last, 'wrongpass1');
    await tester.tap(find.text('Log in').last);
    await tester.pump();
    await tester.pump();

    expect(
      find.text('Email or password is incorrect. Please try again.'),
      findsOneWidget,
    );
  });
}
