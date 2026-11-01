import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/report.dart';
import '../report_dates.dart';
import 'report_chips.dart';
import 'report_photo.dart';

class ReportCard extends StatelessWidget {
  const ReportCard({super.key, required this.report, required this.onTap});

  final Report report;
  final VoidCallback onTap;

  static const _thumbnailSize = 72.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final priority = report.priority;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        if (report.isSafety) const SafetyBadge(),
                        StatusChip(report.status),
                        if (priority != null) PriorityChip(priority),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      report.title,
                      style: textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${report.category.label} · ${report.building.label}',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.muted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        const Icon(
                          Icons.thumb_up_alt_outlined,
                          size: 16,
                          color: AppColors.muted,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '${report.upvoteCount}',
                          style: textTheme.labelMedium?.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Flexible(
                          child: Text(
                            ReportDates.relative(report.createdAt),
                            style: textTheme.labelMedium?.copyWith(
                              color: AppColors.muted,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (report.hasPhotos) ...[
                const SizedBox(width: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  child: SizedBox.square(
                    dimension: _thumbnailSize,
                    child: ReportPhoto(report.photoPaths.first),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
