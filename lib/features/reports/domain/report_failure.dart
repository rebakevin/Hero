enum ReportFailure {
  network,

  /// The server refused the write: the report changed or was removed meanwhile.
  changed,
  notFound,
  invalidInput,
  photoUploadFailed,
  photoTooLarge,
  photoUnreadable,
  unknown,
}

/// Thrown by repositories and adapters so nothing above the data layer sees SDK exceptions.
class ReportException implements Exception {
  const ReportException(this.failure);

  final ReportFailure failure;

  @override
  String toString() => 'ReportException($failure)';
}
