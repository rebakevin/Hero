import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/account_sessions.dart';
import '../domain/auth_failure.dart';
import 'accounts_state.dart';

/// Lists the accounts signed in on this device and switches between them. A
/// successful switch rebuilds the app, which closes this Cubit with its screen.
class AccountsCubit extends Cubit<AccountsState> {
  AccountsCubit(this._sessions) : super(const AccountsLoading());

  final AccountSessions _sessions;
  bool _switching = false;

  Future<void> load() => _attempt('Loading accounts', () async {
    if (state is! AccountsLoading) emit(const AccountsLoading());
    final accounts = await _sessions.accounts();
    if (!isClosed) {
      emit(AccountsLoaded(accounts: accounts, canAdd: _sessions.canAddAccount));
    }
  });

  Future<void> switchTo(String slot) =>
      _change('Switching account', () => _sessions.switchTo(slot));

  Future<void> addAccount() => _change('Adding account', _sessions.addAccount);

  Future<void> _change(String label, Future<void> Function() action) async {
    if (_switching) return;
    _switching = true;
    await _attempt(label, action);
    _switching = false;
  }

  Future<void> _attempt(String label, Future<void> Function() action) async {
    try {
      await action();
    } catch (error, stackTrace) {
      log(label, name: 'AccountsCubit', error: error, stackTrace: stackTrace);
      if (!isClosed) emit(const AccountsFailed(AuthFailure.unknown));
    }
  }
}
