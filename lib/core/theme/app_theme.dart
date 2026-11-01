import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.green).copyWith(
    primary: AppColors.green,
    onPrimary: Colors.white,
    primaryContainer: AppColors.mint,
    onPrimaryContainer: AppColors.deepGreen,
    secondary: AppColors.orange,
    onSecondary: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.muted,
    surfaceContainerHighest: AppColors.stone,
    outline: AppColors.line,
    outlineVariant: AppColors.line,
    error: AppColors.error,
    onError: Colors.white,
  );
  final textTheme = _buildTextTheme();

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: AppColors.paper,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.paper,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: textTheme.titleLarge,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
        shape: const StadiumBorder(),
        textStyle: textTheme.labelLarge?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
        shape: const StadiumBorder(),
        foregroundColor: AppColors.deepGreen,
        side: const BorderSide(color: AppColors.green, width: 1.5),
        textStyle: textTheme.labelLarge?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.green,
        minimumSize: const Size(
          AppSizes.minTouchTarget,
          AppSizes.minTouchTarget,
        ),
        textStyle: textTheme.labelLarge?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
      errorStyle: textTheme.labelSmall?.copyWith(color: AppColors.error),
      enabledBorder: _inputBorder(AppColors.line),
      disabledBorder: _inputBorder(AppColors.line),
      focusedBorder: _inputBorder(AppColors.green),
      errorBorder: _inputBorder(AppColors.error),
      focusedErrorBorder: _inputBorder(AppColors.error),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: AppSizes.navBarHeight,
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.mint,
      indicatorShape: const StadiumBorder(),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => textTheme.labelSmall?.copyWith(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: states.contains(WidgetState.selected)
              ? AppColors.deepGreen
              : AppColors.muted,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.deepGreen
              : AppColors.muted,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.ink,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.line, space: 1),
  );
}

OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(AppRadius.input),
  borderSide: BorderSide(color: color, width: 1.5),
);

TextTheme _buildTextTheme() {
  TextStyle style(double size, FontWeight weight, {double tracking = 0}) =>
      GoogleFonts.dmSans(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: tracking * size,
        color: AppColors.ink,
        height: 1.2,
      );

  return TextTheme(
    displayLarge: style(44, FontWeight.w600, tracking: -0.02),
    headlineLarge: style(32, FontWeight.w600, tracking: -0.02),
    titleLarge: style(24, FontWeight.w600, tracking: -0.02),
    titleMedium: style(16, FontWeight.w600),
    titleSmall: style(14, FontWeight.w600),
    bodyLarge: style(16, FontWeight.w400).copyWith(height: 1.4),
    bodyMedium: style(15, FontWeight.w400).copyWith(height: 1.4),
    bodySmall: style(13, FontWeight.w400).copyWith(height: 1.4),
    labelLarge: style(14, FontWeight.w500),
    labelMedium: style(13, FontWeight.w500),
    labelSmall: style(12, FontWeight.w500),
  );
}
