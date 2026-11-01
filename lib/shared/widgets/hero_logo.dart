import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// The Hero mark: the white logo on a green rounded square.
class HeroLogo extends StatelessWidget {
  const HeroLogo({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      padding: EdgeInsets.all(size * 0.14),
      child: Image.asset(
        'assets/images/hero_logo.png',
        color: Colors.white,
        colorBlendMode: BlendMode.srcIn,
        semanticLabel: 'Hero',
      ),
    );
  }
}
