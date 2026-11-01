import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hero/features/auth/auth.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_view.dart';
import '../application/report_detail_cubit.dart';
import '../application/report_history_cubit.dart';
import '../application/report_detail_state.dart';
import '../domain/report.dart';
import '../domain/report_repository.dart';
import 'report_dates.dart';
import 'report_failure_message.dart';
import 'report_form_screen.dart';
import 'widgets/history_timeline.dart';
import 'widgets/photo_gallery.dart';
import 'widgets/report_chips.dart';
import 'widgets/update_status_sheet.dart';
import 'widgets/vote_section.dart';

class ReportDetailScreen extends StatelessWidget {
  const ReportDetailScreen({
    super.key,
    required this.reportId,
    required this.user,
    this.initial,
  });

  final String reportId;
  final AppUser user;

  /// Shown immediately while the live copy loads.
  final Report? initial;

  static Route<void> route({
    required String reportId,
    required AppUser user,
    Report? initial,
  }) => MaterialPageRoute(
    builder: (_) =>
        ReportDetailScreen(reportId: reportId, user: user, initial: initial),
  );

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ReportDetailCubit(
            repository: context.read<ReportRepository>(),
            user: user,
            reportId: reportId,
            initial: initial,
          ),
        ),
        BlocProvider(
          create: (context) => ReportHistoryCubit(
            repository: context.read<ReportRepository>(),
            reportId: reportId,
          ),
        ),
      ],
      child: _ReportDetailView(user: user),
    );
  }
}

class _ReportDetailView extends StatelessWidget {
  const _ReportDetailView({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReportDetailCubit, ReportDetailState>(
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        switch (state) {
          case ReportDetailDeleted():
            messenger.showSnackBar(
              const SnackBar(content: Text('Report deleted')),
            );
            Navigator.of(context).pop();
          case ReportDetailDeleteFailed(:final failure):
            messenger.showSnackBar(SnackBar(content: Text(failure.message)));
          case ReportDetailLoading() ||
              ReportDetailLoaded() ||
              ReportDetailDeleting() ||
              ReportDetailMissing() ||
              ReportDetailFailure():
        }
      },
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Report')),
        body: SafeArea(
          child: switch (state) {
            ReportDetailLoading() || ReportDetailDeleted() => const Center(
              child: CircularProgressIndicator(),
            ),
            ReportDetailMissing() => const EmptyState(
              icon: Icons.search_off_rounded,
              title: 'Report not found',
              message: 'It may have been deleted by its owner.',
            ),
            ReportDetailFailure(:final failure) => ErrorView(
              message: failure.message,
              onRetry: context.read<ReportDetailCubit>().retry,
            ),
            ReportDetailShown(:final report) => _ReportBody(
              report: report,
              user: user,
              isDeleting: state is ReportDetailDeleting,
            ),
          },
        ),
      ),
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({
    required this.report,
    required this.user,
    required this.isDeleting,
  });

  final Report report;
  final AppUser user;
  final bool isDeleting;

  Future<void> _confirmDelete(BuildContext context) async {
    final cubit = context.read<ReportDetailCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this report?'),
        content: const Text(
          'The report, its photos and its votes will be removed. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) await cubit.delete();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final priority = report.priority;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        if (report.hasPhotos) ...[
          PhotoGallery(photoPaths: report.photoPaths),
          const SizedBox(height: AppSpacing.lg),
        ],
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
        Text(report.title, style: textTheme.titleLarge),
        const SizedBox(height: AppSpacing.lg),
        Text(report.description, style: textTheme.bodyLarge),
        const SizedBox(height: AppSpacing.xl),
        _DetailRow(
          icon: Icons.category_rounded,
          label: 'Category',
          value: report.category.label,
        ),
        _DetailRow(
          icon: Icons.place_rounded,
          label: 'Location',
          value: report.room.isEmpty
              ? report.building.label
              : '${report.building.label}, ${report.room}',
        ),
        _DetailRow(
          icon: Icons.person_rounded,
          label: 'Reported by',
          value: report.reporterName,
        ),
        _DetailRow(
          icon: Icons.schedule_rounded,
          label: 'Reported',
          value: ReportDates.full(report.createdAt),
        ),
        _DetailRow(
          icon: Icons.update_rounded,
          label: 'Last updated',
          value: ReportDates.full(report.updatedAt),
        ),
        _DetailRow(
          icon: Icons.thumb_up_alt_outlined,
          label: '"Me too"',
          value: '${report.upvoteCount}',
        ),
        if (report.canBeVotedBy(user)) ...[
          const SizedBox(height: AppSpacing.md),
          VoteSection(report: report, user: user),
        ],
        if (report.canBeUpdatedBy(user)) ...[
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Update status',
            onPressed: () =>
                UpdateStatusSheet.show(context, report: report, staff: user),
          ),
        ],
        if (report.canBeEditedBy(user)) ...[
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'Edit report',
            style: AppButtonStyle.outlined,
            onPressed: isDeleting
                ? null
                : () => Navigator.of(
                    context,
                  ).push(ReportFormScreen.route(user: user, editing: report)),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: isDeleting ? null : () => _confirmDelete(context),
            child: isDeleting
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Delete report'),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        Text('History', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        const HistoryTimeline(),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.muted),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(color: AppColors.muted),
                ),
                Text(value, style: textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
