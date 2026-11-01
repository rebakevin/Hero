import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/auth_failure.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';
import '../domain/user_repository.dart';
import 'auth_state.dart';

/// App-wide session state. Follows the auth provider's user stream and, for a
/// verified user, loads the profile that holds the role.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _auth = authRepository,
       _users = userRepository,
       super(const AuthChecking()) {
    _subscription = _auth.sessionChanges().listen(_onSessionChanged);
  }

  final AuthRepository _auth;
  final UserRepository _users;
  late final StreamSubscription<AuthUser?> _subscription;
  AuthUser? _sessionUser;
  int _generation = 0;

  Future<void> signOut() => _auth.signOut();

  /// Reflects a display name change already saved by the profile screen.
  void applyRename(String displayName) {
    final current = state;
    if (current is Authenticated) {
      emit(Authenticated(current.user.copyWith(displayName: displayName)));
    }
  }

  Future<void> retry() async {
    final user = _sessionUser;
    if (user != null && user.emailVerified) await _loadProfile(user);
  }

  Future<void> _onSessionChanged(AuthUser? user) async {
    _sessionUser = user;
    if (user == null) {
      _generation++;
      emit(const Unauthenticated());
    } else if (!user.emailVerified) {
      _generation++;
      emit(EmailUnverified(user.email));
    } else {
      await _loadProfile(user);
    }
  }

  Future<void> _loadProfile(AuthUser user) async {
    final current = state;
    // Token refreshes re-emit the same user; nothing to reload.
    if (current is Authenticated && current.user.uid == user.uid) return;

    final generation = ++_generation;
    if (state is! AuthChecking) emit(const AuthChecking());
    try {
      final profile = await _users.loadOrCreateStudent(user);
      if (_isStale(generation)) return;
      emit(Authenticated(profile));
    } on AuthException catch (error) {
      if (_isStale(generation)) return;
      emit(AuthProfileFailed(error.failure));
    } catch (error, stackTrace) {
      log(
        'Loading profile failed',
        name: 'AuthCubit',
        error: error,
        stackTrace: stackTrace,
      );
      if (_isStale(generation)) return;
      emit(const AuthProfileFailed(AuthFailure.unknown));
    }
  }

  bool _isStale(int generation) => isClosed || generation != _generation;

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
