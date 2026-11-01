import 'dart:math';

/// Builds Supabase object paths: `reportPhotos/{uid}/{reportId}/{randomId}.jpg`.
abstract final class PhotoPaths {
  static const root = 'reportPhotos';
  static const _alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
  static const _idLength = 24;
  static final _random = Random.secure();

  static String newPath({
    required String reporterId,
    required String reportId,
  }) {
    final id = String.fromCharCodes(
      Iterable.generate(
        _idLength,
        (_) => _alphabet.codeUnitAt(_random.nextInt(_alphabet.length)),
      ),
    );
    return '$root/$reporterId/$reportId/$id.jpg';
  }
}
