import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../auth/auth.dart';

/// Account details and log out. Name editing arrives in a later phase.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
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
          AppButton(
            label: 'Log out',
            style: AppButtonStyle.outlined,
            onPressed: context.read<AuthCubit>().signOut,
          ),
        ],
      ),
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
