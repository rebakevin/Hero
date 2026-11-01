import 'package:equatable/equatable.dart';

import '../domain/report.dart';

/// Open reports that look like the one being typed. Empty when there is nothing to suggest.
class SimilarReportsState extends Equatable {
  const SimilarReportsState([this.reports = const []]);

  final List<Report> reports;

  @override
  List<Object?> get props => [reports];
}
