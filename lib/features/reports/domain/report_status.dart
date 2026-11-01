enum ReportStatus {
  submitted('Submitted'),
  inProgress('In Progress'),
  resolved('Resolved'),
  rejected('Rejected');

  const ReportStatus(this.label);
  final String label;

  String get key => name;

  static ReportStatus fromKey(String key) => values.byName(key);
}
