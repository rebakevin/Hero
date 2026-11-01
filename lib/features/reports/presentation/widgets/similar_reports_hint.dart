import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hero/features/auth/auth.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../application/similar_reports_cubit.dart';
import '../../application/similar_reports_state.dart';
import '../report_detail_screen.dart';
import 'report_chips.dart';

/// Open reports that look like the one being typed: vote on one instead of duplicating it.
class SimilarReportsHint extends StatelessWidget {
  const SimilarReportsHint({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BlocBuilder<SimilarReportsCubit, SimilarReportsState>(
      builder: (context, state) {
        if (state.reports.isEmpty) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(top: AppSpacing.lg),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.warningSurface,
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Already reported?',
                style: textTheme.titleSmall?.copyWith(
                  color: AppColors.onWarningSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Open one of these and tap "Me too" instead of filing a duplicate.',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.onWarningSurface,
                ),
              ),
              for (final report in state.reports)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    report.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Align(
                    alignment: Alignment.centerLeft,
                    child: StatusChip(report.status),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    ReportDetailScreen.route(
                      reportId: report.id,
                      user: user,
                      initial: report,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
