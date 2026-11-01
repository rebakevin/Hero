import 'photo_source.dart';
import 'picked_photo.dart';

/// Lets the user choose photos and returns them compressed to JPEG.
abstract interface class PhotoPicker {
  /// Throws [ReportException] with [ReportFailure.photoTooLarge] or
  /// [ReportFailure.photoUnreadable]. Returns an empty list when the user cancels.
  Future<List<PickedPhoto>> pick(PhotoSource source, {required int limit});
}
