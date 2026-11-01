enum Building {
  learningCommons('Learning Commons'),
  enterpriseCommons('Enterprise Commons'),
  socialCommons('Social Commons'),
  parking('Parking'),
  garden('Garden'),
  hostels('Hostels');

  const Building(this.label);
  final String label;

  String get key => name;

  static Building fromKey(String key) => values.byName(key);
}
