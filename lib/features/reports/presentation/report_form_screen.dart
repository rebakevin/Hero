import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hero/features/auth/auth.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_dropdown_field.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/error_banner.dart';
import '../application/report_form_cubit.dart';
import '../application/report_form_state.dart';
import '../application/similar_reports_cubit.dart';
import '../domain/building.dart';
import '../domain/category.dart';
import '../domain/photo_picker.dart';
import '../domain/report.dart';
import '../domain/report_repository.dart';
import '../domain/report_validators.dart';
import 'report_detail_screen.dart';
import 'report_failure_message.dart';
import 'widgets/photo_picker_field.dart';
import 'widgets/similar_reports_hint.dart';

/// Create a report, or edit [editing] while it is still submitted.
class ReportFormScreen extends StatelessWidget {
  const ReportFormScreen({super.key, required this.user, this.editing});

  final AppUser user;
  final Report? editing;

  static Route<void> route({required AppUser user, Report? editing}) =>
      MaterialPageRoute(
        builder: (_) => ReportFormScreen(user: user, editing: editing),
      );

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ReportFormCubit(
            repository: context.read<ReportRepository>(),
            picker: context.read<PhotoPicker>(),
            user: user,
            editing: editing,
          ),
        ),
        BlocProvider(
          create: (context) =>
              SimilarReportsCubit(context.read<ReportRepository>()),
        ),
      ],
      child: _ReportForm(user: user, editing: editing),
    );
  }
}

class _ReportForm extends StatefulWidget {
  const _ReportForm({required this.user, required this.editing});

  final AppUser user;
  final Report? editing;

  @override
  State<_ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<_ReportForm> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.editing?.title);
  late final _description = TextEditingController(
    text: widget.editing?.description,
  );
  late final _room = TextEditingController(text: widget.editing?.room);
  late Category? _category = widget.editing?.category;
  late Building? _building = widget.editing?.building;

  static const _hintDelay = Duration(milliseconds: 400);
  Timer? _hintDebounce;

  /// New reports only: an edit is already filed, so there is nothing to duplicate.
  void _refreshSimilarHint() {
    if (widget.editing != null) return;
    _hintDebounce?.cancel();
    _hintDebounce = Timer(_hintDelay, () {
      if (!mounted) return;
      context.read<SimilarReportsCubit>().update(
        title: _title.text,
        category: _category,
        building: _building,
      );
    });
  }

  @override
  void dispose() {
    _hintDebounce?.cancel();
    _title.dispose();
    _description.dispose();
    _room.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final category = _category;
    final building = _building;
    if (category == null || building == null) return;
    context.read<ReportFormCubit>().submit(
      title: _title.text,
      description: _description.text,
      category: category,
      building: building,
      room: _room.text,
    );
  }

  void _onStateChanged(BuildContext context, ReportFormState state) {
    if (state.status != ReportFormStatus.succeeded) return;
    final cubit = context.read<ReportFormCubit>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (cubit.isEditing) {
      messenger.showSnackBar(const SnackBar(content: Text('Report updated')));
      navigator.pop();
    } else {
      messenger.showSnackBar(const SnackBar(content: Text('Report submitted')));
      navigator.pushReplacement(
        ReportDetailScreen.route(reportId: cubit.reportId, user: widget.user),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editing != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit report' : 'New report')),
      body: SafeArea(
        child: BlocConsumer<ReportFormCubit, ReportFormState>(
          listener: _onStateChanged,
          builder: (context, state) {
            final enabled = !state.isSubmitting;
            final cubit = context.read<ReportFormCubit>();
            final failure = state.failure;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screen),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (failure != null) ...[
                      ErrorBanner(failure.message),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    AppDropdownField<Category>(
                      label: 'Category',
                      hint: 'What kind of problem is it?',
                      items: Category.values,
                      itemLabel: (category) => category.label,
                      value: _category,
                      enabled: enabled,
                      validator: ReportValidators.category,
                      onChanged: (value) {
                        setState(() => _category = value);
                        _refreshSimilarHint();
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'Title',
                      hint: 'A short summary',
                      controller: _title,
                      enabled: enabled,
                      validator: ReportValidators.title,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => _refreshSimilarHint(),
                    ),
                    if (!isEditing) SimilarReportsHint(user: widget.user),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'Description',
                      hint: 'What happened, and what is affected?',
                      controller: _description,
                      enabled: enabled,
                      validator: ReportValidators.description,
                      minLines: 4,
                      maxLines: 8,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppDropdownField<Building>(
                      label: 'Building',
                      hint: 'Where is it?',
                      items: Building.values,
                      itemLabel: (building) => building.label,
                      value: _building,
                      enabled: enabled,
                      validator: ReportValidators.building,
                      onChanged: (value) {
                        setState(() => _building = value);
                        _refreshSimilarHint();
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'Room or detail (optional)',
                      hint: 'e.g. Room 204, near the stairs',
                      controller: _room,
                      enabled: enabled,
                      validator: ReportValidators.room,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    PhotoPickerField(
                      existingPaths: state.existingPhotoPaths,
                      newPhotos: state.newPhotos,
                      canAdd: state.canAddPhoto,
                      enabled: enabled,
                      onAdd: cubit.addPhotos,
                      onRemoveExisting: cubit.removeExistingPhoto,
                      onRemoveNew: cubit.removeNewPhoto,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      label: isEditing ? 'Save changes' : 'Submit report',
                      isLoading: state.isSubmitting,
                      onPressed: _submit,
                    ),
                    if (state.isSubmitting && state.uploadTotal > 0) ...[
                      const SizedBox(height: AppSpacing.md),
                      LinearProgressIndicator(
                        value: state.uploaded / state.uploadTotal,
                        color: AppColors.green,
                        backgroundColor: AppColors.mint,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Uploading photos ${state.uploaded} of ${state.uploadTotal}',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
