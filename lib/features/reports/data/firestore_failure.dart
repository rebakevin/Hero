import '../domain/report_failure.dart';

abstract final class FirestoreFailure {
  static ReportFailure fromCode(String code) => switch (code) {
    'permission-denied' => ReportFailure.changed,
    'not-found' => ReportFailure.notFound,
    'unavailable' || 'deadline-exceeded' => ReportFailure.network,
    _ => ReportFailure.unknown,
  };
}
