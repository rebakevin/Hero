enum NotificationType {
  statusChange,
  priorityChange,
  both;

  String get key => name;

  static NotificationType fromKey(String key) => values.byName(key);
}
