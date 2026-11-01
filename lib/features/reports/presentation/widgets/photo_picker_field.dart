import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/photo_source.dart';
import '../../domain/picked_photo.dart';
import '../../domain/report_limits.dart';
import 'report_photo.dart';

/// Thumbnails of the photos on a report, with add and remove controls.
class PhotoPickerField extends StatelessWidget {
  const PhotoPickerField({
    super.key,
    required this.existingPaths,
    required this.newPhotos,
    required this.canAdd,
    required this.enabled,
    required this.onAdd,
    required this.onRemoveExisting,
    required this.onRemoveNew,
  });

  final List<String> existingPaths;
  final List<PickedPhoto> newPhotos;
  final bool canAdd;
  final bool enabled;
  final ValueChanged<PhotoSource> onAdd;
  final ValueChanged<String> onRemoveExisting;
  final ValueChanged<int> onRemoveNew;

  static const _tile = 88.0;

  Future<void> _chooseSource(BuildContext context) async {
    final source = await showModalBottomSheet<PhotoSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: const Text('Take a photo'),
              onTap: () => Navigator.of(context).pop(PhotoSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(context).pop(PhotoSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null) onAdd(source);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final count = existingPaths.length + newPhotos.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos ($count/${ReportLimits.maxPhotos})',
          style: textTheme.labelMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Optional. Please avoid showing people\'s faces.',
          style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (final path in existingPaths)
              _Thumbnail(
                onRemove: enabled ? () => onRemoveExisting(path) : null,
                child: ReportPhoto(path),
              ),
            for (var i = 0; i < newPhotos.length; i++)
              _Thumbnail(
                onRemove: enabled ? () => onRemoveNew(i) : null,
                child: Image.memory(newPhotos[i].bytes, fit: BoxFit.cover),
              ),
            if (canAdd)
              InkWell(
                onTap: enabled ? () => _chooseSource(context) : null,
                borderRadius: BorderRadius.circular(AppRadius.input),
                child: Container(
                  width: _tile,
                  height: _tile,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    border: Border.all(color: AppColors.green, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.add_a_photo_rounded,
                    color: AppColors.green,
                    semanticLabel: 'Add photo',
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.child, required this.onRemove});

  final Widget child;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: PhotoPickerField._tile,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.input),
            child: child,
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton.filled(
              tooltip: 'Remove photo',
              onPressed: onRemove,
              iconSize: 16,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.ink.withValues(alpha: 0.75),
                foregroundColor: Colors.white,
                minimumSize: const Size.square(32),
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        ],
      ),
    );
  }
}
