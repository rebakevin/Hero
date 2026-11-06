import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_view.dart';
import '../application/accounts_cubit.dart';
import '../application/accounts_state.dart';
import '../domain/account_sessions.dart';
import '../domain/device_account.dart';
import 'auth_failure_message.dart';

/// Every account signed in on this device, one tap away.
class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const AccountsScreen());

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AccountsCubit(context.read<AccountSessions>())..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Accounts')),
        body: SafeArea(
          child: BlocBuilder<AccountsCubit, AccountsState>(
            builder: (context, state) => switch (state) {
              AccountsLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              AccountsFailed(:final failure) => ErrorView(
                message: failure.message,
                onRetry: context.read<AccountsCubit>().load,
              ),
              AccountsLoaded(accounts: []) => const EmptyState(
                icon: Icons.person_off_rounded,
                title: 'No accounts',
                message: 'Accounts you log in to on this device appear here.',
              ),
              AccountsLoaded(:final accounts, :final canAdd) => _AccountList(
                accounts: accounts,
                canAdd: canAdd,
              ),
            },
          ),
        ),
      ),
    );
  }
}

class _AccountList extends StatelessWidget {
  const _AccountList({required this.accounts, required this.canAdd});

  final List<DeviceAccount> accounts;
  final bool canAdd;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AccountsCubit>();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        for (final account in accounts) ...[
          _AccountTile(
            account: account,
            onTap: account.isActive ? null : () => cubit.switchTo(account.slot),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        const SizedBox(height: AppSpacing.md),
        if (canAdd)
          AppButton(
            label: 'Add another account',
            style: AppButtonStyle.tonal,
            onPressed: cubit.addAccount,
          )
        else if (accounts.length >= DeviceAccount.maxPerDevice)
          Text(
            'You can keep up to ${DeviceAccount.maxPerDevice} accounts on '
            'this device. Log out of one to add another.',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.muted),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.account, required this.onTap});

  final DeviceAccount account;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final name = account.displayName?.trim();
    final title = (name == null || name.isEmpty) ? account.email : name;
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.mint,
          foregroundColor: AppColors.deepGreen,
          child: Text(title[0].toUpperCase()),
        ),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          account.email,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: account.isActive
            ? Text(
                'Current',
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: AppColors.deepGreen),
              )
            : const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
