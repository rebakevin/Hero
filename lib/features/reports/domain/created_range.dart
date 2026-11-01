import 'package:equatable/equatable.dart';

/// A span of calendar days, both ends included.
class CreatedRange extends Equatable {
  CreatedRange({required DateTime first, required DateTime last})
    : first = DateTime(first.year, first.month, first.day),
      endExclusive = DateTime(last.year, last.month, last.day + 1);

  final DateTime first;
  final DateTime endExclusive;

  bool contains(DateTime moment) =>
      !moment.isBefore(first) && moment.isBefore(endExclusive);

  @override
  List<Object?> get props => [first, endExclusive];
}
