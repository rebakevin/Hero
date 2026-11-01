import 'package:flutter_test/flutter_test.dart';
import 'package:hero/features/reports/domain/building.dart';
import 'package:hero/features/reports/domain/category.dart';
import 'package:hero/features/reports/domain/report_draft.dart';
import 'package:hero/features/reports/domain/report_validators.dart';

import '../fakes.dart';

void main() {
  group('title', () {
    test('empty is rejected', () {
      expect(ReportValidators.title('  '), isNotNull);
    });
    test('under 5 characters is rejected', () {
      expect(ReportValidators.title('Leak'), isNotNull);
    });
    test('over 80 characters is rejected', () {
      expect(ReportValidators.title('a' * 81), isNotNull);
    });
    test('5 to 80 characters, trimmed, is accepted', () {
      expect(ReportValidators.title('  Leak!  '), isNull);
      expect(ReportValidators.title('a' * 80), isNull);
    });
  });

  group('description', () {
    test('under 10 characters is rejected', () {
      expect(ReportValidators.description('too short'), isNotNull);
    });
    test('over 1000 characters is rejected', () {
      expect(ReportValidators.description('a' * 1001), isNotNull);
    });
    test('10 to 1000 characters is accepted', () {
      expect(ReportValidators.description('a' * 10), isNull);
      expect(ReportValidators.description('a' * 1000), isNull);
    });
  });

  group('room', () {
    test('empty is accepted', () {
      expect(ReportValidators.room(''), isNull);
    });
    test('over 40 characters is rejected', () {
      expect(ReportValidators.room('a' * 41), isNotNull);
    });
  });

  test('category and building are required', () {
    expect(ReportValidators.category(null), isNotNull);
    expect(ReportValidators.category(Category.water), isNull);
    expect(ReportValidators.building(null), isNotNull);
    expect(ReportValidators.building(Building.garden), isNull);
  });

  group('ReportDraft', () {
    ReportDraft draft({
      String title = '  Broken tap  ',
      List<String> kept = const [],
      int newPhotos = 0,
    }) => ReportDraft(
      title: title,
      description: 'The tap leaks all day long.',
      category: Category.water,
      building: Building.hostels,
      room: ' 2B ',
      keptPhotoPaths: kept,
      newPhotos: [for (var i = 0; i < newPhotos; i++) aPhoto(i)],
    );

    test('trims text and derives the lowercase title', () {
      final value = draft();
      expect(value.title, 'Broken tap');
      expect(value.titleLower, 'broken tap');
      expect(value.room, '2B');
    });

    test('is valid with up to 5 photos in total', () {
      expect(draft(kept: ['a', 'b'], newPhotos: 3).isValid, isTrue);
    });

    test('is invalid with a sixth photo', () {
      expect(draft(kept: ['a', 'b'], newPhotos: 4).isValid, isFalse);
    });

    test('is invalid with a short title', () {
      expect(draft(title: 'Leak').isValid, isFalse);
    });
  });
}
