import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import '../domain/photo_picker.dart';
import '../domain/photo_source.dart';
import '../domain/picked_photo.dart';
import '../domain/report_failure.dart';
import '../domain/report_limits.dart';

/// Camera and gallery through `image_picker`, re-encoded as JPEG under the size limit.
class DevicePhotoPicker implements PhotoPicker {
  DevicePhotoPicker(this._picker);

  /// Tried in order until the JPEG fits [ReportLimits.maxPhotoBytes].
  static const _qualities = [80, 60, 40];
  static const _maxEdge = 1600;

  final ImagePicker _picker;

  @override
  Future<List<PickedPhoto>> pick(
    PhotoSource source, {
    required int limit,
  }) async {
    if (limit <= 0) return const [];
    final files = await _choose(source, limit);
    final photos = <PickedPhoto>[];
    for (final file in files) {
      photos.add(PickedPhoto(await _compress(file.path)));
    }
    return photos;
  }

  Future<List<XFile>> _choose(PhotoSource source, int limit) async {
    try {
      return switch (source) {
        PhotoSource.camera => [
          ?await _picker.pickImage(source: ImageSource.camera),
        ],
        // pickMultiImage rejects a limit below 2.
        PhotoSource.gallery when limit == 1 => [
          ?await _picker.pickImage(source: ImageSource.gallery),
        ],
        PhotoSource.gallery => await _picker.pickMultiImage(limit: limit),
      };
    } on Exception {
      throw const ReportException(ReportFailure.photoUnreadable);
    }
  }

  Future<Uint8List> _compress(String path) async {
    for (final quality in _qualities) {
      final bytes = await FlutterImageCompress.compressWithFile(
        path,
        minWidth: _maxEdge,
        minHeight: _maxEdge,
        quality: quality,
        format: CompressFormat.jpeg,
      );
      if (bytes == null) {
        throw const ReportException(ReportFailure.photoUnreadable);
      }
      if (bytes.length <= ReportLimits.maxPhotoBytes) return bytes;
    }
    throw const ReportException(ReportFailure.photoTooLarge);
  }
}
