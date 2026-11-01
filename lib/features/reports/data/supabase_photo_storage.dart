import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/photo_storage.dart';
import '../domain/report_failure.dart';

/// Report photos in a public Supabase bucket, standing in for Firebase Storage.
class SupabasePhotoStorage implements PhotoStorage {
  SupabasePhotoStorage({required SupabaseClient client, required String bucket})
    : _bucket = client.storage.from(bucket);

  static const _timeout = Duration(seconds: 30);
  static const _jpeg = 'image/jpeg';

  final StorageFileApi _bucket;

  @override
  Future<void> upload(String path, Uint8List bytes) async {
    try {
      await _bucket
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(contentType: _jpeg),
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw const ReportException(ReportFailure.network);
    } on StorageException catch (error, stackTrace) {
      log(
        'Photo upload failed',
        name: 'SupabasePhotoStorage',
        error: error,
        stackTrace: stackTrace,
      );
      throw const ReportException(ReportFailure.photoUploadFailed);
    }
  }

  @override
  Future<void> delete(List<String> paths) async {
    if (paths.isEmpty) return;
    try {
      await _bucket.remove(paths).timeout(_timeout);
    } on TimeoutException {
      throw const ReportException(ReportFailure.network);
    } on StorageException catch (error, stackTrace) {
      log(
        'Photo delete failed',
        name: 'SupabasePhotoStorage',
        error: error,
        stackTrace: stackTrace,
      );
      throw const ReportException(ReportFailure.photoUploadFailed);
    }
  }

  @override
  String urlFor(String path) => _bucket.getPublicUrl(path);
}
