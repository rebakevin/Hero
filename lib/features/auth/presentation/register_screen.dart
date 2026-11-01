import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/error_banner.dart';
import '../../../shared/widgets/password_field.dart';
import '../application/auth_form_cubit.dart';
import '../application/auth_form_state.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_validators.dart';
import 'auth_failure_message.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const RegisterScreen());

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthFormCubit(context.read<AuthRepository>()),
      child: const _RegisterForm(),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  const _RegisterForm();

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthFormCubit>().register(
      displayName: _name.text.trim(),
      email: _email.text.trim().toLowerCase(),
      password: _password.text,
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
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create your account',
                        style: textTheme.headlineLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'For ALU students. Use your $studentEmailDomain email.',
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
                        label: 'Full name',
                        controller: _name,
                        enabled: !submitting,
                        validator: AuthValidators.displayName,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppTextField(
                        label: 'Email',
                        hint: 'name$studentEmailDomain',
                        controller: _email,
                        enabled: !submitting,
                        validator: AuthValidators.registerEmail,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      PasswordField(
                        controller: _password,
                        hint: 'At least 8 characters, with a number',
                        enabled: !submitting,
                        validator: AuthValidators.newPassword,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      PasswordField(
                        controller: _confirmPassword,
                        label: 'Confirm password',
                        enabled: !submitting,
                        validator: (value) => AuthValidators.confirmPassword(
                          value,
                          _password.text,
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppButton(
                        label: 'Create account',
                        isLoading: submitting,
                        onPressed: _submit,
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
