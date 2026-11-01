import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../../shared/widgets/hero_logo.dart';
import '../../../shared/widgets/password_field.dart';
import '../application/auth_form_cubit.dart';
import '../application/auth_form_state.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_validators.dart';
import 'auth_failure_message.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthFormCubit(context.read<AuthRepository>()),
      child: const _LoginForm(),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthFormCubit>().signIn(
      email: _email.text.trim().toLowerCase(),
      password: _password.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<AuthFormCubit, AuthFormState>(
          builder: (context, state) {
            final submitting = state is AuthFormSubmitting;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.form),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const HeroLogo(),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Hero',
                            style: textTheme.titleLarge?.copyWith(fontSize: 22),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Welcome back',
                        style: textTheme.headlineLarge?.copyWith(fontSize: 40),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Log in with your ALU email.',
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
                        hint: 'name@alustudent.com',
                        controller: _email,
                        enabled: !submitting,
                        validator: AuthValidators.loginEmail,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      PasswordField(
                        controller: _password,
                        hint: 'Your password',
                        enabled: !submitting,
                        validator: AuthValidators.loginPassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onSubmitted: (_) => _submit(),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: submitting
                              ? null
                              : () =>
                                    Navigator.of(context)
                                        .push(ForgotPasswordScreen.route()),
                          child: const Text('Forgot password?'),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppButton(
                        label: 'Log in',
                        isLoading: submitting,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('New student?', style: textTheme.bodyMedium),
                          TextButton(
                            onPressed: submitting
                                ? null
                                : () =>
                                      Navigator.of(context)
                                          .push(RegisterScreen.route()),
                            child: const Text('Register'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
