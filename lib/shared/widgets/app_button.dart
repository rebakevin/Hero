import 'package:flutter/material.dart';

enum AppButtonStyle { primary, tonal, outlined }

/// Full-width pill button. Shows a spinner and ignores taps while [isLoading].
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = AppButtonStyle.primary,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final onTap = isLoading ? null : onPressed;
    final child = isLoading
        ? const SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          )
        : Text(label);

    return switch (style) {
      AppButtonStyle.primary => FilledButton(onPressed: onTap, child: child),
      AppButtonStyle.tonal => FilledButton.tonal(
        onPressed: onTap,
        child: child,
      ),
      AppButtonStyle.outlined => OutlinedButton(onPressed: onTap, child: child),
    };
  }
}
