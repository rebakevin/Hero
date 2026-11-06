import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../application/accounts_cubit.dart';
import '../application/accounts_state.dart';
import '../domain/account_sessions.dart';
import 'accounts_screen.dart';

/// A way back to the accounts already signed in, for screens shown before a
/// session opens. Takes no space when there are none.
class SwitchAccountLink extends StatelessWidget {
  const SwitchAccountLink({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AccountsCubit(context.read<AccountSessions>())..load(),
      child: BlocBuilder<AccountsCubit, AccountsState>(
        builder: (context, state) => switch (state) {
          AccountsLoaded(hasOtherAccounts: true) => Center(
            child: TextButton(
              onPressed: () =>
                  Navigator.of(context).push(AccountsScreen.route()),
              child: const Text('Use a signed-in account'),
            ),
          ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}
