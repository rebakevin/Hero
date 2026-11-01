enum Priority {
  low('Low'),
  medium('Medium'),
  high('High'),
  urgent('Urgent');

  const Priority(this.label);
  final String label;

  String get key => name;

  static Priority fromKey(String key) => values.byName(key);
}
