import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hero/features/auth/auth.dart';
import 'package:hero/features/reports/reports.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_view.dart';
import '../application/notifications_cubit.dart';
import '../application/notifications_state.dart';
import '../domain/app_notification.dart';
import '../domain/notifications_failure.dart';

/// Status and priority changes to the student's reports. Tapping one opens the report.
class NotificationsTab extends StatelessWidget {
  const NotificationsTab({super.key, required this.user});

  final AppUser user;

  void _open(BuildContext context, AppNotification notification) {
    context.read<NotificationsCubit>().markRead(notification);
    Navigator.of(context).push(
      ReportDetailScreen.route(reportId: notification.reportId, user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Text(
            'Alerts',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        Expanded(
          child: BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) => switch (state) {
              NotificationsLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              NotificationsEmpty() => const EmptyState(
                icon: Icons.notifications_rounded,
                title: 'No alerts',
                message: 'Updates on your reports will appear here.',
              ),
              NotificationsFailed(:final failure) => ErrorView(
                message: switch (failure) {
                  NotificationsFailure.network =>
                    'No connection. Check your internet and try again.',
                  NotificationsFailure.unknown =>
                    'Something went wrong. Please try again.',
                },
                onRetry: context.read<NotificationsCubit>().retry,
              ),
              NotificationsLoaded(:final notifications) => ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  0,
                  AppSpacing.screen,
                  AppSpacing.screen,
                ),
                itemCount: notifications.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) => _NotificationTile(
                  notification: notifications[index],
                  onTap: () => _open(context, notifications[index]),
                ),
              ),
            },
          ),
        ),
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final unread = !notification.isRead;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: unread ? AppColors.mint : AppColors.surface,
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
              Icon(
                unread
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_none_rounded,
                color: unread ? AppColors.deepGreen : AppColors.muted,
                semanticLabel: unread ? 'Unread' : 'Read',
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.message,
                      style: unread
                          ? textTheme.titleSmall
                          : textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      notification.reportTitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.muted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      ReportDates.relative(notification.createdAt),
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
