import 'package:flutter_test/flutter_test.dart';
import 'package:hero/features/reports/domain/created_range.dart';
import 'package:hero/features/reports/domain/report_query.dart';
import 'package:hero/features/reports/domain/report_sort.dart';

import '../fakes.dart';

void main() {
  final range = CreatedRange(
    first: DateTime(2026, 11, 1),
    last: DateTime(2026, 11, 2),
  );

  group('serverOrder', () {
    test('newest without search orders by createdAt', () {
      expect(const ReportQuery().serverOrder, ServerOrder.createdAt);
    });
    test('most votes orders by upvoteCount', () {
      expect(
        const ReportQuery(sort: ReportSort.mostVotes).serverOrder,
        ServerOrder.upvoteCount,
      );
    });
    test('a search term orders by titleLower, whatever the sort', () {
      expect(
        const ReportQuery(
          titleSearch: ' Tap ',
          sort: ReportSort.mostVotes,
        ).serverOrder,
        ServerOrder.titleLower,
      );
    });
    test('the title prefix is trimmed and lowercased', () {
      expect(const ReportQuery(titleSearch: ' Tap ').titlePrefix, 'tap');
    });
  });

  group('CreatedRange', () {
    test('includes both end days entirely', () {
      expect(range.contains(DateTime(2026, 11, 1, 0, 0)), isTrue);
      expect(range.contains(DateTime(2026, 11, 2, 23, 59)), isTrue);
      expect(range.contains(DateTime(2026, 11, 3)), isFalse);
      expect(range.contains(DateTime(2026, 10, 31, 23, 59)), isFalse);
    });
  });

  group('refine', () {
    final inside = aReport(id: 'a', createdAt: DateTime(2026, 11, 1, 10));
    final outside = aReport(id: 'b', createdAt: DateTime(2026, 11, 9));

    test('leaves date filtering to the server when ordering by createdAt', () {
      final query = ReportQuery(createdRange: range);
      expect(query.refine([inside, outside]), [inside, outside]);
    });

    test('applies the date range itself when sorting by votes', () {
      final query = ReportQuery(
        createdRange: range,
        sort: ReportSort.mostVotes,
      );
      expect(query.refine([inside, outside]), [inside]);
    });

    test('applies the date range itself while searching', () {
      final query = ReportQuery(createdRange: range, titleSearch: 'broken');
      expect(query.refine([inside, outside]), [inside]);
    });

    test('a search with the newest sort lists newest first', () {
      final older = aReport(id: 'old', createdAt: DateTime(2026, 10, 1));
      final newer = aReport(id: 'new', createdAt: DateTime(2026, 10, 5));
      const query = ReportQuery(titleSearch: 'broken');
      expect(query.refine([older, newer]), [newer, older]);
    });

    test('a search with most votes lists most votes first', () {
      final few = aReport(id: 'few', upvoteCount: 1);
      final many = aReport(id: 'many', upvoteCount: 9);
      const query = ReportQuery(
        titleSearch: 'broken',
        sort: ReportSort.mostVotes,
      );
      expect(query.refine([few, many]), [many, few]);
    });
  });

  test('activeFilterCount counts status, category, range and sort', () {
    final query = ReportQuery(createdRange: range, sort: ReportSort.mostVotes);
    expect(query.activeFilterCount, 2);
    expect(const ReportQuery().activeFilterCount, 0);
  });
}
