/// What a staff update changed. The key is the notification `type` on the wire.
enum ChangeKind {
  statusChange,
  priorityChange,
  both;

  String get key => name;
}
