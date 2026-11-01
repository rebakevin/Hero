import 'package:flutter_test/flutter_test.dart';
import 'package:hero/features/auth/auth.dart';
import 'package:hero/features/profile/application/profile_cubit.dart';
import 'package:hero/features/profile/application/profile_state.dart';

import '../auth/fakes.dart';

void main() {
  late FakeUserRepository users;
  late ProfileCubit cubit;

  setUp(() {
    users = FakeUserRepository();
    cubit = ProfileCubit(users: users, uid: 'student-1');
  });

  test('a valid name is saved trimmed', () async {
    await cubit.rename('  Amina H.  ');
    expect(cubit.state, const ProfileRenamed('Amina H.'));
    expect(users.renames, ['student-1:Amina H.']);
  });

  test('a name that is too short never reaches the repository', () async {
    await cubit.rename('A');
    expect(cubit.state, isA<ProfileFailed>());
    expect(users.renames, isEmpty);
  });

  test('a refused rename reports the failure', () async {
    users.error = const AuthException(AuthFailure.network);
    await cubit.rename('Amina H.');
    expect(cubit.state, const ProfileFailed(AuthFailure.network));
  });
}
