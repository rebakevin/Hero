import 'report.dart';

/// Picks the open reports that look like the one being typed, so the student can
/// vote on one instead of filing a duplicate.
abstract final class SimilarReports {
  static const minTitleLength = 3;
  static const minWordLength = 4;
  static const maxShown = 3;

  static final _separators = RegExp(r'[^a-z0-9]+');

  static List<Report> matching(String title, Iterable<Report> candidates) {
    final typed = _words(title);
    if (title.trim().length < minTitleLength || typed.isEmpty) return const [];
    return candidates
        .where((report) => _words(report.title).any(typed.contains))
        .take(maxShown)
        .toList();
  }

  static Set<String> _words(String text) => text
      .toLowerCase()
      .split(_separators)
      .where((word) => word.length >= minWordLength)
      .toSet();
}
