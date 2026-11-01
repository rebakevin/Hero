import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hero/features/auth/auth.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/error_banner.dart';
import '../../application/status_update_cubit.dart';
import '../../application/status_update_state.dart';
import '../../domain/priority.dart';
import '../../domain/report.dart';
import '../../domain/report_repository.dart';
import '../../domain/report_status.dart';
import '../../domain/report_validators.dart';
import '../report_failure_message.dart';

/// Staff pick a status and priority and explain the change (W5).
class UpdateStatusSheet extends StatelessWidget {
  const UpdateStatusSheet({
    super.key,
    required this.report,
    required this.staff,
  });

  final Report report;
  final AppUser staff;

  static Future<void> show(
    BuildContext context, {
    required Report report,
    required AppUser staff,
  }) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.paper,
    builder: (_) => UpdateStatusSheet(report: report, staff: staff),
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StatusUpdateCubit(
        repository: context.read<ReportRepository>(),
        staff: staff,
        report: report,
      ),
      child: _UpdateStatusForm(report: report),
    );
  }
}

class _UpdateStatusForm extends StatefulWidget {
  const _UpdateStatusForm({required this.report});

  final Report report;

  @override
  State<_UpdateStatusForm> createState() => _UpdateStatusFormState();
}

class _UpdateStatusFormState extends State<_UpdateStatusForm> {
  final _formKey = GlobalKey<FormState>();
  final _note = TextEditingController();
  late ReportStatus _status = widget.report.status;
  late Priority? _priority = widget.report.priority;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<StatusUpdateCubit>().submit(
      status: _status,
      priority: _priority,
      note: _note.text,
    );
  }

  void _onStateChanged(BuildContext context, StatusUpdateState state) {
    if (state.status != StatusUpdateStatus.succeeded) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Report updated')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BlocConsumer<StatusUpdateCubit, StatusUpdateState>(
      listener: _onStateChanged,
      builder: (context, state) {
        final enabled = !state.isSubmitting;
        final failure = state.failure;
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screen,
              0,
              AppSpacing.screen,
              AppSpacing.screen + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Update report', style: textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.lg),
                  if (failure != null) ...[
                    ErrorBanner(failure.message),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  Text('Status', style: textTheme.labelMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: [
                      for (final status in ReportStatus.values)
                        ChoiceChip(
                          label: Text(status.label),
                          selected: _status == status,
                          onSelected: enabled
                              ? (_) => setState(() => _status = status)
                              : null,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Priority', style: textTheme.labelMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: [
                      ChoiceChip(
                        label: const Text('None'),
                        selected: _priority == null,
                        onSelected: enabled
                            ? (_) => setState(() => _priority = null)
                            : null,
                      ),
                      for (final priority in Priority.values)
                        ChoiceChip(
                          label: Text(priority.label),
                          selected: _priority == priority,
                          onSelected: enabled
                              ? (_) => setState(() => _priority = priority)
                              : null,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: 'Note for the reporter',
                    hint: 'What changed, and why?',
                    controller: _note,
                    enabled: enabled,
                    validator: ReportValidators.statusNote,
                    minLines: 2,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: 'Save update',
                    isLoading: state.isSubmitting,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
