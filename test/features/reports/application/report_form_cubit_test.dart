import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero/features/reports/application/report_form_cubit.dart';
import 'package:hero/features/reports/application/report_form_state.dart';
import 'package:hero/features/reports/domain/building.dart';
import 'package:hero/features/reports/domain/category.dart';
import 'package:hero/features/reports/domain/photo_source.dart';
import 'package:hero/features/reports/domain/report_failure.dart';
import 'package:hero/features/reports/domain/report_limits.dart';

import '../fakes.dart';

void main() {
  late FakeReportRepository repository;
  late FakePhotoPicker picker;

  setUp(() {
    repository = FakeReportRepository();
    picker = FakePhotoPicker();
  });

  ReportFormCubit build({bool editing = false}) => ReportFormCubit(
    repository: repository,
    picker: picker,
    user: aUser(),
    editing: editing ? aReport(photoPaths: ['old-1', 'old-2']) : null,
  );

  Future<void> submit(ReportFormCubit cubit, {String title = 'Broken tap'}) =>
      cubit.submit(
        title: title,
        description: 'The tap on the second floor leaks.',
        category: Category.water,
        building: Building.hostels,
        room: '',
      );

  test('a new form uses the repository-generated report id', () {
    expect(build().reportId, 'new-report');
  });

  test('an edit form keeps the report id and its photos', () {
    final cubit = build(editing: true);
    expect(cubit.reportId, 'report-1');
    expect(cubit.state.existingPhotoPaths, ['old-1', 'old-2']);
  });

  group('photos', () {
    test('picked photos are added', () async {
      picker.next = [aPhoto(1), aPhoto(2)];
      final cubit = build();
      await cubit.addPhotos(PhotoSource.gallery);
      expect(cubit.state.newPhotos, hasLength(2));
      expect(picker.requestedLimits, [ReportLimits.maxPhotos]);
    });

    test('the picker is only asked for the remaining room', () async {
      final cubit = build(editing: true);
      await cubit.addPhotos(PhotoSource.camera);
      expect(picker.requestedLimits, [ReportLimits.maxPhotos - 2]);
    });

    test('a full form does not open the picker', () async {
      picker.next = [for (var i = 0; i < 5; i++) aPhoto(i)];
      final cubit = build();
      await cubit.addPhotos(PhotoSource.gallery);
      await cubit.addPhotos(PhotoSource.gallery);
      expect(picker.requestedLimits, hasLength(1));
      expect(cubit.state.canAddPhoto, isFalse);
    });

    test('a picker failure is shown and keeps the photos', () async {
      picker.next = [aPhoto(1)];
      final cubit = build();
      await cubit.addPhotos(PhotoSource.gallery);
      picker.failWith = ReportFailure.photoTooLarge;
      await cubit.addPhotos(PhotoSource.gallery);
      expect(cubit.state.status, ReportFormStatus.failed);
      expect(cubit.state.failure, ReportFailure.photoTooLarge);
      expect(cubit.state.newPhotos, hasLength(1));
    });

    test('photos can be removed', () async {
      picker.next = [aPhoto(1), aPhoto(2)];
      final cubit = build(editing: true);
      await cubit.addPhotos(PhotoSource.gallery);
      cubit.removeNewPhoto(0);
      cubit.removeExistingPhoto('old-1');
      expect(cubit.state.newPhotos, [aPhoto(2)]);
      expect(cubit.state.existingPhotoPaths, ['old-2']);
    });
  });

  group('submit', () {
    blocTest<ReportFormCubit, ReportFormState>(
      'creates the report and succeeds',
      build: build,
      act: submit,
      expect: () => [
        isA<ReportFormState>().having(
          (s) => s.status,
          'status',
          ReportFormStatus.submitting,
        ),
        isA<ReportFormState>().having(
          (s) => s.status,
          'status',
          ReportFormStatus.succeeded,
        ),
      ],
      verify: (_) {
        expect(repository.created.single.title, 'Broken tap');
        expect(repository.updated, isEmpty);
      },
    );

    blocTest<ReportFormCubit, ReportFormState>(
      'an edit updates instead of creating',
      build: () => build(editing: true),
      act: submit,
      verify: (_) {
        expect(repository.updated.single.keptPhotoPaths, ['old-1', 'old-2']);
        expect(repository.created, isEmpty);
      },
    );

    test('an invalid draft never reaches the repository', () async {
      final cubit = build();
      await submit(cubit, title: 'Hi');
      expect(cubit.state.status, ReportFormStatus.failed);
      expect(cubit.state.failure, ReportFailure.invalidInput);
      expect(repository.created, isEmpty);
    });

    test('a failed write keeps the photos so the user can retry', () async {
      picker.next = [aPhoto(1)];
      repository.writeError = const ReportException(ReportFailure.network);
      final cubit = build();
      await cubit.addPhotos(PhotoSource.gallery);
      await submit(cubit);
      expect(cubit.state.status, ReportFormStatus.failed);
      expect(cubit.state.failure, ReportFailure.network);
      expect(cubit.state.newPhotos, hasLength(1));
    });

    test('an unexpected error becomes an unknown failure', () async {
      repository.writeError = StateError('boom');
      final cubit = build();
      await submit(cubit);
      expect(cubit.state.failure, ReportFailure.unknown);
    });

    test('a second submit while one runs is ignored', () async {
      repository.writeGate = Completer();
      final cubit = build();
      final first = submit(cubit);
      await submit(cubit);
      repository.writeGate!.complete();
      await first;
      expect(repository.created, hasLength(1));
    });

    test('a retry after failure reuses the same report id', () async {
      repository.writeError = const ReportException(ReportFailure.network);
      final cubit = build();
      final id = cubit.reportId;
      await submit(cubit);
      repository.writeError = null;
      await submit(cubit);
      expect(cubit.reportId, id);
      expect(cubit.state.status, ReportFormStatus.succeeded);
    });
  });
}
