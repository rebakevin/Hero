import 'package:flutter_test/flutter_test.dart';
import 'package:hero/features/reports/application/similar_reports_cubit.dart';
import 'package:hero/features/reports/domain/building.dart';
import 'package:hero/features/reports/domain/category.dart';

import '../fakes.dart';

void main() {
  late FakeReportRepository repository;
  late SimilarReportsCubit cubit;
  final leak = aReport(id: 'a', title: 'Water leaking in hostel corridor');

  setUp(() {
    repository = FakeReportRepository()..openReports = [leak];
    cubit = SimilarReportsCubit(repository);
  });

  test('suggests nothing until category and building are chosen', () async {
    await cubit.update(title: 'leaking tap', category: null, building: null);
    expect(cubit.state.reports, isEmpty);
    expect(repository.findCalls, isEmpty);
  });

  test('suggests open reports sharing a word with the title', () async {
    await cubit.update(
      title: 'leaking tap',
      category: Category.water,
      building: Building.hostels,
    );
    expect(cubit.state.reports, [leak]);
  });

  test('typing more only re-filters; the place is fetched once', () async {
    for (final title in ['leak', 'leaking', 'leaking tap']) {
      await cubit.update(
        title: title,
        category: Category.water,
        building: Building.hostels,
      );
    }
    expect(repository.findCalls, hasLength(1));
  });

  test('changing the building fetches again', () async {
    await cubit.update(
      title: 'leaking',
      category: Category.water,
      building: Building.hostels,
    );
    await cubit.update(
      title: 'leaking',
      category: Category.water,
      building: Building.garden,
    );
    expect(repository.findCalls, hasLength(2));
  });

  test(
    'a failed lookup leaves the form unaffected and is retried later',
    () async {
      repository.findError = StateError('offline');
      await cubit.update(
        title: 'leaking',
        category: Category.water,
        building: Building.hostels,
      );
      expect(cubit.state.reports, isEmpty);
      repository.findError = null;
      await cubit.update(
        title: 'leaking',
        category: Category.water,
        building: Building.hostels,
      );
      expect(cubit.state.reports, [leak]);
    },
  );
}
