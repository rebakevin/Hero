import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import 'report_photo.dart';

/// Swipeable photos with a "2 / 4" counter.
class PhotoGallery extends StatefulWidget {
  const PhotoGallery({super.key, required this.photoPaths});

  final List<String> photoPaths;

  static const _height = 240.0;

  @override
  State<PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: SizedBox(
        height: PhotoGallery._height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              itemCount: widget.photoPaths.length,
              onPageChanged: (page) => setState(() => _page = page),
              itemBuilder: (context, index) =>
                  ReportPhoto(widget.photoPaths[index]),
            ),
            if (widget.photoPaths.length > 1)
              Positioned(
                right: AppSpacing.md,
                bottom: AppSpacing.md,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.ink.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(AppRadius.small),
                  ),
                  child: Text(
                    '${_page + 1} / ${widget.photoPaths.length}',
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
