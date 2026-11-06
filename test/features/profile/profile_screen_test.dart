import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero/features/auth/application/auth_cubit.dart';
import 'package:hero/features/auth/domain/auth_repository.dart';
import 'package:hero/features/auth/domain/auth_user.dart';
import 'package:hero/features/auth/domain/user_repository.dart';
import 'package:hero/features/profile/presentation/profile_screen.dart';

import '../auth/fakes.dart';

void main() {
  late FakeAuthRepository auth;
  late FakeUserRepository users;

  setUp(() {
    auth = FakeAuthRepository();
    users = FakeUserRepository();
  });

  Future<void> pumpProfile(WidgetTester tester, AuthUser session) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AuthRepository>.value(value: auth),
          RepositoryProvider<UserRepository>.value(value: users),
        ],
        child: BlocProvider(
          create: (_) => AuthCubit(authRepository: auth, userRepository: users),
          child: MaterialApp(
            home: Scaffold(body: ProfileScreen(user: studentProfile)),
          ),
        ),
      ),
    );
    auth.session.add(session);
    await tester.pumpAndSettle();
  }

  testWidgets('an unverified student can open verification and leave it', (
    tester,
  ) async {
    await pumpProfile(tester, unverifiedAuthUser);

    await tester.tap(find.text('Verify email'));
    await tester.pumpAndSettle();
    expect(find.text('Verify your email'), findsOneWidget);

    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(find.text('Verify your email'), findsNothing);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('a verified student sees no verify button', (tester) async {
    await pumpProfile(tester, studentAuthUser);

    expect(find.text('Verify email'), findsNothing);
  });
}
