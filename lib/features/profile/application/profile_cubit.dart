import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hero/features/auth/auth.dart';

import 'profile_state.dart';

/// Lets a student change their display name (W8).
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required this._users, required this._uid})
    : super(const ProfileIdle());

  final UserRepository _users;
  final String _uid;

  Future<void> rename(String displayName) async {
    if (state is ProfileSaving) return;
    final name = displayName.trim();
    if (AuthValidators.displayName(name) != null) {
      emit(const ProfileFailed(AuthFailure.unknown));
      return;
    }
    emit(const ProfileSaving());
    try {
      await _users.rename(uid: _uid, displayName: name);
      if (!isClosed) emit(ProfileRenamed(name));
    } on AuthException catch (error) {
      if (!isClosed) emit(ProfileFailed(error.failure));
    } catch (error, stackTrace) {
      log(
        'Renaming failed',
        name: 'ProfileCubit',
        error: error,
        stackTrace: stackTrace,
      );
      if (!isClosed) emit(const ProfileFailed(AuthFailure.unknown));
    }
  }
}
