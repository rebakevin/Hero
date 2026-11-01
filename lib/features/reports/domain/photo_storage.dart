import 'dart:typed_data';

import 'photo_url_resolver.dart';

/// Where report photos live (Supabase Storage).
abstract interface class PhotoStorage implements PhotoUrlResolver {
  /// Stores JPEG [bytes] at [path]. Throws [ReportException] on failure.
  Future<void> upload(String path, Uint8List bytes);

  /// Removes files; paths that no longer exist are ignored.
  Future<void> delete(List<String> paths);
}
