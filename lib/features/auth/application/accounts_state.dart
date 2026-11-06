import 'package:equatable/equatable.dart';

import '../domain/auth_failure.dart';
import '../domain/device_account.dart';

sealed class AccountsState extends Equatable {
  const AccountsState();

  @override
  List<Object?> get props => [];
}

final class AccountsLoading extends AccountsState {
  const AccountsLoading();
}

final class AccountsLoaded extends AccountsState {
  const AccountsLoaded({required this.accounts, required this.canAdd});

  final List<DeviceAccount> accounts;
  final bool canAdd;

  bool get hasOtherAccounts => accounts.any((account) => !account.isActive);

  @override
  List<Object?> get props => [accounts, canAdd];
}

final class AccountsFailed extends AccountsState {
  const AccountsFailed(this.failure);

  final AuthFailure failure;

  @override
  List<Object?> get props => [failure];
}
