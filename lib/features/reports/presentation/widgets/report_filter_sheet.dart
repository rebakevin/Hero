import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/category.dart';
import '../../domain/created_range.dart';
import '../../domain/report_query.dart';
import '../../domain/report_sort.dart';
import '../../domain/report_status.dart';
import '../report_dates.dart';

/// Lets the user pick status, category, date range and sort. Pops the new query.
class ReportFilterSheet extends StatefulWidget {
  const ReportFilterSheet({super.key, required this.query});

  final ReportQuery query;

  static Future<ReportQuery?> show(BuildContext context, ReportQuery query) =>
      showModalBottomSheet<ReportQuery>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        backgroundColor: AppColors.paper,
        builder: (_) => ReportFilterSheet(query: query),
      );

  @override
  State<ReportFilterSheet> createState() => _ReportFilterSheetState();
}

class _ReportFilterSheetState extends State<ReportFilterSheet> {
  late ReportQuery _query = widget.query;

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final current = _query.createdRange;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDateRange: current == null
          ? null
          : DateTimeRange(
              start: current.first,
              end: current.endExclusive.subtract(const Duration(days: 1)),
            ),
    );
    if (picked == null || !mounted) return;
    setState(
      () => _query = _query.copyWith(
        createdRange: () => CreatedRange(first: picked.start, last: picked.end),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final range = _query.createdRange;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screen,
          0,
          AppSpacing.screen,
          AppSpacing.screen + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter reports', style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.lg),
            _Section(
              title: 'Status',
              child: _ChoiceChips<ReportStatus>(
                values: ReportStatus.values,
                selected: _query.status,
                label: (status) => status.label,
                onSelected: (status) => setState(
                  () => _query = _query.copyWith(status: () => status),
                ),
              ),
            ),
            _Section(
              title: 'Category',
              child: _ChoiceChips<Category>(
                values: Category.values,
                selected: _query.category,
                label: (category) => category.label,
                onSelected: (category) => setState(
                  () => _query = _query.copyWith(category: () => category),
                ),
              ),
            ),
            _Section(
              title: 'Reported between',
              child: Wrap(
                spacing: AppSpacing.sm,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.date_range_rounded, size: 18),
                    label: Text(
                      range == null
                          ? 'Any date'
                          : '${ReportDates.day(range.first)} – '
                                '${ReportDates.day(range.endExclusive.subtract(const Duration(days: 1)))}',
                    ),
                    onPressed: _pickRange,
                  ),
                  if (range != null)
                    ActionChip(
                      label: const Text('Clear'),
                      onPressed: () => setState(
                        () =>
                            _query = _query.copyWith(createdRange: () => null),
                      ),
                    ),
                ],
              ),
            ),
            _Section(
              title: 'Sort by',
              child: Wrap(
                spacing: AppSpacing.sm,
                children: [
                  for (final sort in ReportSort.values)
                    ChoiceChip(
                      label: Text(sort.label),
                      selected: _query.sort == sort,
                      onSelected: (_) =>
                          setState(() => _query = _query.copyWith(sort: sort)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Show reports',
              onPressed: () => Navigator.of(context).pop(_query),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: 'Reset filters',
              style: AppButtonStyle.outlined,
              onPressed: () => Navigator.of(context).pop(
                ReportQuery(
                  reporterId: _query.reporterId,
                  titleSearch: _query.titleSearch,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

/// An "All" chip followed by one chip per value; tapping the chosen one again clears it.
class _ChoiceChips<T> extends StatelessWidget {
  const _ChoiceChips({
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelected,
  });

  final List<T> values;
  final T? selected;
  final String Function(T value) label;
  final ValueChanged<T?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        ChoiceChip(
          label: const Text('All'),
          selected: selected == null,
          onSelected: (_) => onSelected(null),
        ),
        for (final value in values)
          ChoiceChip(
            label: Text(label(value)),
            selected: selected == value,
            onSelected: (_) => onSelected(selected == value ? null : value),
          ),
      ],
    );
  }
}
