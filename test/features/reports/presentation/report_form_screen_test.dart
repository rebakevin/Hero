import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero/features/reports/domain/building.dart';
import 'package:hero/features/reports/domain/category.dart';
import 'package:hero/features/reports/domain/photo_picker.dart';
import 'package:hero/features/reports/domain/report_repository.dart';
import 'package:hero/features/reports/domain/vote_repository.dart';
import 'package:hero/features/reports/presentation/report_form_screen.dart';

import '../fakes.dart';

void main() {
  late FakeReportRepository repository;

  setUp(() => repository = FakeReportRepository());

  Future<void> pumpForm(WidgetTester tester) => tester.pumpWidget(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ReportRepository>.value(value: repository),
        RepositoryProvider<VoteRepository>.value(value: FakeVoteRepository()),
        RepositoryProvider<PhotoPicker>.value(value: FakePhotoPicker()),
      ],
      child: MaterialApp(home: ReportFormScreen(user: aUser())),
    ),
  );

  Future<void> choose<T>(WidgetTester tester, String option) async {
    final dropdown = find.byType(DropdownButtonFormField<T>);
    await tester.ensureVisible(dropdown);
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text(option).last);
    await tester.pumpAndSettle();
  }

  Finder submitButton() => find.text('Submit report');

  testWidgets('shows an error for every required field and does not submit', (
    tester,
  ) async {
    await pumpForm(tester);

    await tester.ensureVisible(submitButton());
    await tester.tap(submitButton());
    await tester.pump();

    expect(find.text('Choose a category.'), findsOneWidget);
    expect(find.text('Enter a title.'), findsOneWidget);
    expect(find.text('Describe what happened.'), findsOneWidget);
    expect(find.text('Choose a building.'), findsOneWidget);
    expect(repository.created, isEmpty);
  });

  testWidgets('rejects a title and description that are too short', (
    tester,
  ) async {
    await pumpForm(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'Leak');
    await tester.enterText(find.byType(TextFormField).at(1), 'too short');
    await tester.ensureVisible(submitButton());
    await tester.tap(submitButton());
    await tester.pump();

    expect(find.textContaining('between 5 and 80'), findsOneWidget);
    expect(find.textContaining('between 10 and 1000'), findsOneWidget);
    expect(repository.created, isEmpty);
  });

  testWidgets('submits a trimmed draft once the form is valid', (tester) async {
    await pumpForm(tester);

    await choose<Category>(tester, 'Water shortage');
    await tester.enterText(find.byType(TextFormField).at(0), '  Broken tap  ');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'The tap on the second floor leaks all day.',
    );
    await choose<Building>(tester, 'Hostels');
    await tester.ensureVisible(submitButton());
    await tester.tap(submitButton());
    await tester.pump();

    expect(repository.created, hasLength(1));
    expect(repository.created.single.title, 'Broken tap');
    expect(repository.created.single.room, isEmpty);
  });

  testWidgets('keeps what was typed when saving fails', (tester) async {
    repository.writeError = StateError('boom');
    await pumpForm(tester);

    await choose<Category>(tester, 'Safety');
    await tester.enterText(find.byType(TextFormField).at(0), 'Loose railing');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'The stair railing near the library wobbles.',
    );
    await choose<Building>(tester, 'Garden');
    await tester.ensureVisible(submitButton());
    await tester.tap(submitButton());
    await tester.pump();
    await tester.pump();

    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Loose railing'), findsOneWidget);
    expect(find.text('Safety'), findsOneWidget);
  });
}
