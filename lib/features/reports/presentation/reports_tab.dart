import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hero/features/auth/auth.dart';

import '../../../core/theme/app_dimensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_view.dart';
import '../application/reports_cubit.dart';
import '../application/reports_state.dart';
import '../domain/report_query.dart';
import '../domain/report_repository.dart';
import 'report_detail_screen.dart';
import 'report_failure_message.dart';
import 'report_form_screen.dart';
import 'report_list_scope.dart';
import 'widgets/report_card.dart';
import 'widgets/report_filter_sheet.dart';

/// A searchable, filterable, live list of reports, as a home tab.
class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key, required this.user, required this.scope});

  final AppUser user;
  final ReportListScope scope;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReportsCubit(
        repository: context.read<ReportRepository>(),
        query: ReportQuery(
          reporterId: scope == ReportListScope.mine ? user.uid : null,
        ),
      ),
      child: _ReportsView(user: user, scope: scope),
    );
  }
}

class _ReportsView extends StatefulWidget {
  const _ReportsView({required this.user, required this.scope});

  final AppUser user;
  final ReportListScope scope;

  @override
  State<_ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<_ReportsView> {
  static const _searchDelay = Duration(milliseconds: 350);

  final _search = TextEditingController();
  Timer? _debounce;

  bool get _canReport =>
      widget.user.role == Role.student &&
      widget.scope == ReportListScope.everyone;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(_searchDelay, () {
      if (!mounted) return;
      final cubit = context.read<ReportsCubit>();
      cubit.applyQuery(cubit.state.query.copyWith(titleSearch: text));
    });
  }

  Future<void> _openFilters() async {
    final cubit = context.read<ReportsCubit>();
    final picked = await ReportFilterSheet.show(context, cubit.state.query);
    if (picked != null) cubit.applyQuery(picked);
  }

  void _open(String reportId, ReportsState state) {
    Navigator.of(context).push(
      ReportDetailScreen.route(
        reportId: reportId,
        user: widget.user,
        initial: switch (state) {
          ReportsLoaded(:final reports) => reports.firstWhere(
            (report) => report.id == reportId,
          ),
          _ => null,
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final title = widget.scope == ReportListScope.mine
        ? 'My reports'
        : 'Campus reports';
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _canReport
          ? FloatingActionButton.extended(
              onPressed: () =>
                  Navigator.of(context)
                      .push(ReportFormScreen.route(user: widget.user)),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Report'),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.screen,
              AppSpacing.screen,
              AppSpacing.md,
            ),
            child: Text(title, style: textTheme.headlineLarge),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    onChanged: _onSearchChanged,
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      hintText: 'Search by title',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                BlocSelector<ReportsCubit, ReportsState, int>(
                  selector: (state) => state.query.activeFilterCount,
                  builder: (context, count) => IconButton.filledTonal(
                    tooltip: 'Filters',
                    onPressed: _openFilters,
                    icon: Badge(
                      isLabelVisible: count > 0,
                      label: Text('$count'),
                      child: const Icon(Icons.tune_rounded),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: BlocBuilder<ReportsCubit, ReportsState>(
              builder: (context, state) => switch (state) {
                ReportsLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                ReportsFailure(:final failure) => ErrorView(
                  message: failure.message,
                  onRetry: context.read<ReportsCubit>().retry,
                ),
                ReportsEmpty() => _EmptyReports(
                  filtered:
                      state.query.isSearching ||
                      state.query.activeFilterCount > 0,
                  scope: widget.scope,
                ),
                ReportsLoaded(:final reports, :final hasMore) =>
                  ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.screen,
                      0,
                      AppSpacing.screen,
                      _canReport ? AppSizes.fabClearance : AppSpacing.screen,
                    ),
                    itemCount: reports.length + (hasMore ? 1 : 0),
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      if (index == reports.length) {
                        return AppButton(
                          label: 'Load more',
                          style: AppButtonStyle.outlined,
                          onPressed: context.read<ReportsCubit>().loadMore,
                        );
                      }
                      final report = reports[index];
                      return ReportCard(
                        report: report,
                        onTap: () => _open(report.id, state),
                      );
                    },
                  ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyReports extends StatelessWidget {
  const _EmptyReports({required this.filtered, required this.scope});

  final bool filtered;
  final ReportListScope scope;

  @override
  Widget build(BuildContext context) {
    if (filtered) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No matching reports',
        message: 'Try a different search or clear the filters.',
      );
    }
    return switch (scope) {
      ReportListScope.mine => const EmptyState(
        icon: Icons.assignment_rounded,
        title: 'You have not reported anything',
        message: 'Tap Report on the Home tab to file your first one.',
      ),
      ReportListScope.everyone => const EmptyState(
        icon: Icons.inbox_rounded,
        title: 'No reports yet',
        message: 'Campus reports will appear here.',
      ),
    };
  }
}
