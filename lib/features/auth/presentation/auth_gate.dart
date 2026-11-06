import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/widgets/error_view.dart';
import '../application/auth_cubit.dart';
import '../application/auth_state.dart';
import '../domain/app_user.dart';
import 'auth_failure_message.dart';
import 'login_screen.dart';
import 'switch_account_link.dart';
import 'verify_email_screen.dart';

/// Chooses the root screen from the session state. Screens pushed over the
/// gate (register, reset password) are closed whenever the session changes.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.authenticatedBuilder});

  final Widget Function(BuildContext context, AppUser user)
  authenticatedBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) =>
          Navigator.of(context).popUntil((route) => route.isFirst),
      builder: (context, state) => switch (state) {
        AuthChecking() => const _Splash(),
        Unauthenticated() => const LoginScreen(footer: SwitchAccountLink()),
        EmailUnverified(:final email) => VerifyEmailScreen(
          email: email,
          footer: const SwitchAccountLink(),
        ),
        Authenticated(:final user) => authenticatedBuilder(context, user),
        AuthProfileFailed(:final failure) => Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ErrorView(
                    title: "We couldn't open your account",
                    message: failure.message,
                    onRetry: context.read<AuthCubit>().retry,
                  ),
                ),
                TextButton(
                  onPressed: context.read<AuthCubit>().signOut,
                  child: const Text('Log out'),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.green,
      body: Center(
        child: SizedBox.square(
          dimension: 40,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
        ),
      ),
    );
  }
}
