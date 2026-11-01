import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/error_banner.dart';
import '../application/auth_form_cubit.dart';
import '../application/auth_form_state.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_validators.dart';
import 'auth_failure_message.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthFormCubit(context.read<AuthRepository>()),
      child: const _ForgotPasswordForm(),
    );
  }
}

class _ForgotPasswordForm extends StatefulWidget {
  const _ForgotPasswordForm();

  @override
  State<_ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<_ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthFormCubit>().sendPasswordReset(
      _email.text.trim().toLowerCase(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: BlocBuilder<AuthFormCubit, AuthFormState>(
          builder: (context, state) {
            if (state is AuthFormSucceeded) {
              return _ResetSent(email: _email.text.trim().toLowerCase());
            }
            final submitting = state is AuthFormSubmitting;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.form,
                0,
                AppSpacing.form,
                AppSpacing.form,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reset your password', style: textTheme.headlineLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Enter your ALU email and we will send you a reset link.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                    if (state case AuthFormFailed(:final failure)) ...[
                      const SizedBox(height: AppSpacing.lg),
                      ErrorBanner(failure.message),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'Email',
                      controller: _email,
                      enabled: !submitting,
                      validator: AuthValidators.loginEmail,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      label: 'Send reset link',
                      isLoading: submitting,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ResetSent extends StatelessWidget {
  const _ResetSent({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.form),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.mint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_read_rounded,
                size: 44,
                color: AppColors.green,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Check your inbox',
            style: textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'If an account exists for $email, we sent a link to reset your password.',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'Back to log in',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
