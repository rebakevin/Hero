enum Category {
  facilities('Facilities'),
  water('Water shortage'),
  electricity('Electricity outage'),
  furniture('Damaged furniture'),
  sanitation('Sanitation'),
  safety('Safety');

  const Category(this.label);
  final String label;

  String get key => name;

  static Category fromKey(String key) => values.byName(key);
}
