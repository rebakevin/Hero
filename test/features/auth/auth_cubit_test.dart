import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero/features/auth/application/auth_cubit.dart';
import 'package:hero/features/auth/application/auth_state.dart';
import 'package:hero/features/auth/domain/auth_failure.dart';

import 'fakes.dart';

void main() {
  late FakeAuthRepository auth;
  late FakeUserRepository users;

  setUp(() {
    auth = FakeAuthRepository();
    users = FakeUserRepository();
  });

  AuthCubit buildCubit() =>
      AuthCubit(authRepository: auth, userRepository: users);

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  blocTest<AuthCubit, AuthState>(
    'starts checking, then reports signed out when there is no session',
    build: buildCubit,
    act: (_) => auth.session.add(null),
    expect: () => [const Unauthenticated()],
  );

  blocTest<AuthCubit, AuthState>(
    'holds an unverified user at the verification step without loading a profile',
    build: buildCubit,
    act: (_) => auth.session.add(unverifiedAuthUser),
    expect: () => [const EmailUnverified('amina@alustudent.com')],
    verify: (_) => expect(users.loads, 0),
  );

  blocTest<AuthCubit, AuthState>(
    'loads the profile for a verified user',
    build: buildCubit,
    act: (_) => auth.session.add(studentAuthUser),
    expect: () => [Authenticated(studentProfile)],
  );

  blocTest<AuthCubit, AuthState>(
    'moves from unverified to authenticated once the user verifies',
    build: buildCubit,
    act: (_) async {
      auth.session.add(unverifiedAuthUser);
      await settle();
      auth.session.add(studentAuthUser);
    },
    expect: () => [
      const EmailUnverified('amina@alustudent.com'),
      const AuthChecking(),
      Authenticated(studentProfile),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'does not reload the profile when a token refresh re-emits the same user',
    build: buildCubit,
    act: (_) async {
      auth.session.add(studentAuthUser);
      await settle();
      auth.session.add(studentAuthUser);
    },
    expect: () => [Authenticated(studentProfile)],
    verify: (_) => expect(users.loads, 1),
  );

  blocTest<AuthCubit, AuthState>(
    'reports a profile failure when the account cannot be provisioned',
    build: () {
      users.error = const AuthException(AuthFailure.accountNotProvisioned);
      return buildCubit();
    },
    act: (_) => auth.session.add(studentAuthUser),
    expect: () => [const AuthProfileFailed(AuthFailure.accountNotProvisioned)],
  );

  blocTest<AuthCubit, AuthState>(
    'reports an unknown failure for unexpected errors',
    build: () {
      users.error = StateError('boom');
      return buildCubit();
    },
    act: (_) => auth.session.add(studentAuthUser),
    expect: () => [const AuthProfileFailed(AuthFailure.unknown)],
  );

  blocTest<AuthCubit, AuthState>(
    'retry loads the profile again after a failure',
    build: () {
      users.error = const AuthException(AuthFailure.network);
      return buildCubit();
    },
    act: (cubit) async {
      auth.session.add(studentAuthUser);
      await settle();
      users.error = null;
      await cubit.retry();
    },
    expect: () => [
      const AuthProfileFailed(AuthFailure.network),
      const AuthChecking(),
      Authenticated(studentProfile),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'signing out returns to unauthenticated',
    build: buildCubit,
    act: (cubit) async {
      auth.session.add(studentAuthUser);
      await settle();
      await cubit.signOut();
      auth.session.add(null);
    },
    expect: () => [Authenticated(studentProfile), const Unauthenticated()],
    verify: (_) => expect(auth.calls, contains('signOut')),
  );
}
