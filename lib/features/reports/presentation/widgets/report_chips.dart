import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/category.dart';
import '../../domain/priority.dart';
import '../../domain/report_status.dart';

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 26),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});

  final ReportStatus status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (status) {
      ReportStatus.submitted => (
        AppColors.infoSurface,
        AppColors.onInfoSurface,
      ),
      ReportStatus.inProgress => (
        AppColors.warningSurface,
        AppColors.onWarningSurface,
      ),
      ReportStatus.resolved => (AppColors.mint, AppColors.deepGreen),
      ReportStatus.rejected => (AppColors.stone, AppColors.muted),
    };
    return _Chip(
      label: status.label,
      background: background,
      foreground: foreground,
    );
  }
}

class PriorityChip extends StatelessWidget {
  const PriorityChip(this.priority, {super.key});

  final Priority priority;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (priority) {
      Priority.low => (AppColors.stone, AppColors.muted),
      Priority.medium => (AppColors.infoSurface, AppColors.onInfoSurface),
      Priority.high => (AppColors.highSurface, AppColors.onHighSurface),
      Priority.urgent => (AppColors.danger, Colors.white),
    };
    return _Chip(
      label: '${priority.label} priority',
      background: background,
      foreground: foreground,
    );
  }
}

/// Makes safety reports stand out in lists.
class SafetyBadge extends StatelessWidget {
  const SafetyBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return _Chip(
      label: Category.safety.label,
      background: AppColors.danger,
      foreground: Colors.white,
      icon: Icons.warning_amber_rounded,
    );
  }
}
