import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../auth/auth.dart';
import '../application/profile_cubit.dart';
import '../application/profile_state.dart';

/// Account details, display name editing (students), switching account and log out.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProfileCubit(users: context.read<UserRepository>(), uid: user.uid),
      child: _ProfileView(user: user),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({required this.user});

  final AppUser user;

  Future<void> _editName(BuildContext context) async {
    final cubit = context.read<ProfileCubit>();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _RenameDialog(initialName: user.displayName),
    );
    if (name != null && name != user.displayName) await cubit.rename(name);
  }

  void _onStateChanged(BuildContext context, ProfileState state) {
    final messenger = ScaffoldMessenger.of(context);
    switch (state) {
      case ProfileRenamed(:final displayName):
        context.read<AuthCubit>().applyRename(displayName);
        messenger.showSnackBar(const SnackBar(content: Text('Name updated')));
      case ProfileFailed(:final failure):
        messenger.showSnackBar(SnackBar(content: Text(failure.message)));
      case ProfileIdle() || ProfileSaving():
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BlocListener<ProfileCubit, ProfileState>(
      listener: _onStateChanged,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          children: [
            Text('Profile', style: textTheme.headlineLarge),
            const SizedBox(height: AppSpacing.xl),
            Center(child: _Avatar(name: user.displayName)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              user.displayName,
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              user.email,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Center(child: _RoleChip(label: user.role.label)),
            const SizedBox(height: AppSpacing.xl),
            if (!user.isStaff) ...[
              BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) => AppButton(
                  label: 'Change name',
                  style: AppButtonStyle.tonal,
                  isLoading: state is ProfileSaving,
                  onPressed: () => _editName(context),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            AppButton(
              label: 'Switch account',
              style: AppButtonStyle.tonal,
              onPressed: () =>
                  Navigator.of(context).push(AccountsScreen.route()),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Log out',
              style: AppButtonStyle.outlined,
              onPressed: context.read<AuthCubit>().signOut,
            ),
          ],
        ),
      ),
    );
  }
}

class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.initialName});

  final String initialName;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_name.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change your name'),
      content: Form(
        key: _formKey,
        child: AppTextField(
          label: 'Full name',
          controller: _name,
          validator: AuthValidators.displayName,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _save(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final hue = (name.codeUnitAt(0) * 37) % 360.0;
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .take(2)
        .map((word) => word[0].toUpperCase())
        .join();
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: HSLColor.fromAHSL(1, hue, 0.45, 0.86).toColor(),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: Theme.of(context).textTheme.titleLarge
            ?.copyWith(color: HSLColor.fromAHSL(1, hue, 0.55, 0.25).toColor()),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Center(
        widthFactor: 1,
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: AppColors.deepGreen),
        ),
      ),
    );
  }
}
