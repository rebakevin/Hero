enum Role {
  student('Student'),
  staff('Staff');

  const Role(this.label);
  final String label;

  static Role fromKey(String key) => values.byName(key);
}
