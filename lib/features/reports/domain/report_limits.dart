/// Limits shared by the form validators and the Firestore rules / Supabase bucket.
abstract final class ReportLimits {
  static const minTitleLength = 5;
  static const maxTitleLength = 80;
  static const minDescriptionLength = 10;
  static const maxDescriptionLength = 1000;
  static const maxRoomLength = 40;
  static const maxPhotos = 5;
  static const maxPhotoBytes = 5 * 1024 * 1024;
}
