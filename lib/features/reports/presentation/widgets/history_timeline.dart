import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../application/report_history_cubit.dart';
import '../../application/report_history_state.dart';
import '../../domain/history_entry.dart';
import '../history_entry_text.dart';
import '../report_dates.dart';
import '../report_failure_message.dart';

/// Who changed the report, when, and why. Oldest entry first.
class HistoryTimeline extends StatelessWidget {
  const HistoryTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportHistoryCubit, ReportHistoryState>(
      builder: (context, state) => switch (state) {
        ReportHistoryLoading() => const Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Center(child: CircularProgressIndicator()),
        ),
        ReportHistoryFailure(:final failure) => Row(
          children: [
            Expanded(child: Text(failure.message)),
            TextButton(
              onPressed: context.read<ReportHistoryCubit>().retry,
              child: const Text('Retry'),
            ),
          ],
        ),
        ReportHistoryLoaded(:final entries) => Column(
          children: [
            for (var i = 0; i < entries.length; i++)
              _TimelineRow(entry: entries[i], isLast: i == entries.length - 1),
          ],
        ),
      },
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.entry, required this.isLast});

  final HistoryEntry entry;
  final bool isLast;

  static const _dot = 12.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xs),
                Container(
                  width: _dot,
                  height: _dot,
                  decoration: const BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  const Expanded(
                    child: VerticalDivider(width: 2, thickness: 2),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.headline, style: textTheme.titleSmall),
                  if (entry.fromStatus != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(entry.note, style: textTheme.bodyMedium),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${entry.actorName} (${entry.actorRole.label}) · '
                    '${ReportDates.full(entry.createdAt)}',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
