import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero/features/auth/application/auth_form_cubit.dart';
import 'package:hero/features/auth/application/auth_form_state.dart';
import 'package:hero/features/auth/domain/auth_failure.dart';

import 'fakes.dart';

void main() {
  late FakeAuthRepository auth;

  setUp(() => auth = FakeAuthRepository());

  blocTest<AuthFormCubit, AuthFormState>(
    'signIn submits then returns to idle on success',
    build: () => AuthFormCubit(auth),
    act: (cubit) => cubit.signIn(email: 'a@alustudent.com', password: 'x'),
    expect: () => [const AuthFormSubmitting(), const AuthFormIdle()],
    verify: (_) => expect(auth.calls, ['signIn:a@alustudent.com']),
  );

  blocTest<AuthFormCubit, AuthFormState>(
    'signIn reports the failure on bad credentials',
    build: () {
      auth.failWith = AuthFailure.invalidCredentials;
      return AuthFormCubit(auth);
    },
    act: (cubit) => cubit.signIn(email: 'a@alustudent.com', password: 'x'),
    expect: () => [
      const AuthFormSubmitting(),
      const AuthFormFailed(AuthFailure.invalidCredentials),
    ],
  );

  blocTest<AuthFormCubit, AuthFormState>(
    'register reports an email already in use',
    build: () {
      auth.failWith = AuthFailure.emailInUse;
      return AuthFormCubit(auth);
    },
    act: (cubit) => cubit.register(
      displayName: 'Amina',
      email: 'a@alustudent.com',
      password: 'hunter22',
    ),
    expect: () => [
      const AuthFormSubmitting(),
      const AuthFormFailed(AuthFailure.emailInUse),
    ],
  );

  blocTest<AuthFormCubit, AuthFormState>(
    'sendPasswordReset reports that the link was sent',
    build: () => AuthFormCubit(auth),
    act: (cubit) => cubit.sendPasswordReset('a@alustudent.com'),
    expect: () => [
      const AuthFormSubmitting(),
      const AuthFormSucceeded(AuthFormOutcome.passwordResetSent),
    ],
  );

  blocTest<AuthFormCubit, AuthFormState>(
    'checkEmailVerified says not yet while the user is still unverified',
    build: () {
      auth.reloadResult = unverifiedAuthUser;
      return AuthFormCubit(auth);
    },
    act: (cubit) => cubit.checkEmailVerified(),
    expect: () => [
      const AuthFormSubmitting(),
      const AuthFormSucceeded(AuthFormOutcome.emailNotVerifiedYet),
    ],
  );

  blocTest<AuthFormCubit, AuthFormState>(
    'checkEmailVerified goes quiet once verified so the gate can move on',
    build: () {
      auth.reloadResult = studentAuthUser;
      return AuthFormCubit(auth);
    },
    act: (cubit) => cubit.checkEmailVerified(),
    expect: () => [const AuthFormSubmitting(), const AuthFormIdle()],
  );

  blocTest<AuthFormCubit, AuthFormState>(
    'ignores a second submit while one is running',
    build: () => AuthFormCubit(auth),
    act: (cubit) async {
      final first = cubit.signIn(email: 'a@alustudent.com', password: 'x');
      await cubit.signIn(email: 'a@alustudent.com', password: 'x');
      await first;
    },
    verify: (_) => expect(auth.calls, hasLength(1)),
  );
}
