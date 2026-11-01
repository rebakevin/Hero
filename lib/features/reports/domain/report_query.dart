import 'package:equatable/equatable.dart';

import 'category.dart';
import 'created_range.dart';
import 'report.dart';
import 'report_sort.dart';
import 'report_status.dart';

/// Which field Firestore orders (and therefore indexes) a query by.
enum ServerOrder { createdAt, upvoteCount, titleLower }

/// Filters, search and sort for a list of reports.
///
/// Firestore cannot combine a date range with a vote sort or a title search, so
/// [refine] applies whatever the server could not.
class ReportQuery extends Equatable {
  const ReportQuery({
    this.status,
    this.category,
    this.reporterId,
    this.restrictToStatuses,
    this.createdRange,
    this.titleSearch = '',
    this.sort = ReportSort.newest,
  });

  final ReportStatus? status;
  final Category? category;
  final String? reporterId;

  /// A fixed scope (staff "Needs action"); [status] can narrow it further.
  final List<ReportStatus>? restrictToStatuses;
  final CreatedRange? createdRange;
  final String titleSearch;
  final ReportSort sort;

  String get titlePrefix => titleSearch.trim().toLowerCase();

  List<ReportStatus> get statusChoices =>
      restrictToStatuses ?? ReportStatus.values;

  bool get isSearching => titlePrefix.isNotEmpty;

  /// Filters the user can change, not counting the fixed [reporterId].
  int get activeFilterCount =>
      [status, category, createdRange].nonNulls.length +
      (sort == ReportSort.newest ? 0 : 1);

  ServerOrder get serverOrder {
    if (isSearching) return ServerOrder.titleLower;
    return switch (sort) {
      ReportSort.newest => ServerOrder.createdAt,
      ReportSort.mostVotes => ServerOrder.upvoteCount,
    };
  }

  bool get filtersDateOnServer => serverOrder == ServerOrder.createdAt;

  ReportQuery copyWith({
    ReportStatus? Function()? status,
    Category? Function()? category,
    CreatedRange? Function()? createdRange,
    String? titleSearch,
    ReportSort? sort,
  }) => ReportQuery(
    status: status != null ? status() : this.status,
    category: category != null ? category() : this.category,
    reporterId: reporterId,
    restrictToStatuses: restrictToStatuses,
    createdRange: createdRange != null ? createdRange() : this.createdRange,
    titleSearch: titleSearch ?? this.titleSearch,
    sort: sort ?? this.sort,
  );

  /// Keeps the filter and order the server could not apply.
  List<Report> refine(List<Report> reports) {
    final range = createdRange;
    final inRange = (range == null || filtersDateOnServer)
        ? reports
        : reports.where((report) => range.contains(report.createdAt));
    if (serverOrder != ServerOrder.titleLower) return inRange.toList();
    return inRange.toList()..sort(_comparator);
  }

  int _comparator(Report a, Report b) {
    if (sort == ReportSort.mostVotes) {
      final byVotes = b.upvoteCount.compareTo(a.upvoteCount);
      if (byVotes != 0) return byVotes;
    }
    return b.createdAt.compareTo(a.createdAt);
  }

  @override
  List<Object?> get props => [
    status,
    category,
    reporterId,
    restrictToStatuses,
    createdRange,
    titleSearch,
    sort,
  ];
}
