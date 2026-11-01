import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../application/reports_cubit.dart';
import '../../application/reports_state.dart';
import '../../application/status_counts_cubit.dart';
import '../../application/status_counts_state.dart';
import '../../domain/report_repository.dart';
import '../../domain/report_status.dart';

/// Staff: how many reports are in each status, refreshed whenever the list below changes.
class StatusCountsHeader extends StatelessWidget {
  const StatusCountsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StatusCountsCubit(context.read<ReportRepository>()),
      child: BlocListener<ReportsCubit, ReportsState>(
        listenWhen: (previous, current) =>
            current is ReportsLoaded || current is ReportsEmpty,
        listener: (context, _) => context.read<StatusCountsCubit>().refresh(),
        child: BlocBuilder<StatusCountsCubit, StatusCountsState>(
          builder: (context, state) => Row(
            children: [
              for (final status in ReportStatus.values) ...[
                Expanded(
                  child: _CountTile(
                    label: status.label,
                    count: switch (state) {
                      StatusCountsLoaded(:final counts) => counts[status],
                      StatusCountsLoading() || StatusCountsFailure() => null,
                    },
                  ),
                ),
                if (status != ReportStatus.values.last)
                  const SizedBox(width: AppSpacing.sm),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CountTile extends StatelessWidget {
  const _CountTile({required this.label, required this.count});

  final String label;

  /// Null while loading or when counting failed.
  final int? count;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Text(count?.toString() ?? '–', style: textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
