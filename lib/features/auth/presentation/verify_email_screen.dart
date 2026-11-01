import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/error_banner.dart';
import '../application/auth_cubit.dart';
import '../application/auth_form_cubit.dart';
import '../application/auth_form_state.dart';
import '../domain/auth_repository.dart';
import 'auth_failure_message.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthFormCubit(context.read<AuthRepository>()),
      child: _VerifyEmailView(email: email),
    );
  }
}

class _VerifyEmailView extends StatelessWidget {
  const _VerifyEmailView({required this.email});

  final String email;

  String? _messageFor(AuthFormOutcome outcome) => switch (outcome) {
    AuthFormOutcome.verificationEmailSent => 'Verification email sent.',
    AuthFormOutcome.emailNotVerifiedYet =>
      'Not verified yet. Open the link in the email, then try again.',
    AuthFormOutcome.passwordResetSent => null,
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthFormCubit, AuthFormState>(
          listener: (context, state) {
            if (state case AuthFormSucceeded(:final outcome)) {
              final message = _messageFor(outcome);
              if (message != null) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(message)));
              }
            }
          },
          builder: (context, state) {
            final cubit = context.read<AuthFormCubit>();
            final submitting = state is AuthFormSubmitting;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.form),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: AppColors.mint,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mail_rounded,
                        size: 56,
                        color: AppColors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Verify your email',
                    style: textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'We sent a verification link to $email. Open it, then come back and tap the button below.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.muted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (state case AuthFormFailed(:final failure)) ...[
                    const SizedBox(height: AppSpacing.lg),
                    ErrorBanner(failure.message),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: "I've verified",
                    isLoading: submitting,
                    onPressed: cubit.checkEmailVerified,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: 'Resend email',
                    style: AppButtonStyle.outlined,
                    onPressed: submitting
                        ? null
                        : cubit.resendVerificationEmail,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: submitting
                        ? null
                        : context.read<AuthCubit>().signOut,
                    child: const Text('Log out'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
