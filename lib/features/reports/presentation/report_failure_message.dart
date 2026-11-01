import '../domain/report_failure.dart';
import '../domain/report_limits.dart';

extension ReportFailureMessage on ReportFailure {
  String get message => switch (this) {
    ReportFailure.network =>
      'No connection. Check your internet and try again.',
    ReportFailure.changed =>
      'This report changed in the meantime. Go back and open it again.',
    ReportFailure.notFound => 'This report no longer exists.',
    ReportFailure.invalidInput =>
      'Some details are missing or too long. Check the form and try again.',
    ReportFailure.photoUploadFailed =>
      "A photo couldn't be uploaded. Please try again.",
    ReportFailure.photoTooLarge =>
      'That photo is still over ${ReportLimits.maxPhotoBytes ~/ (1024 * 1024)} MB '
          'after compression. Choose a smaller one.',
    ReportFailure.photoUnreadable =>
      "We couldn't read that photo. Try another one.",
    ReportFailure.unknown => 'Something went wrong. Please try again.',
  };
}
