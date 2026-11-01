import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/photo_url_resolver.dart';

/// A stored report photo with a placeholder while it loads and a marker if it fails.
class ReportPhoto extends StatelessWidget {
  const ReportPhoto(this.path, {super.key, this.fit = BoxFit.cover});

  final String path;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final url = context.read<PhotoUrlResolver>().urlFor(path);
    return Image.network(
      url,
      fit: fit,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : const _Placeholder(),
      errorBuilder: (context, error, stackTrace) =>
          const _Placeholder(icon: Icons.broken_image_rounded),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({this.icon = Icons.image_rounded});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.stone,
      child: Center(child: Icon(icon, color: AppColors.muted)),
    );
  }
}
