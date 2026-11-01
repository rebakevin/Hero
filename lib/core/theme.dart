import 'package:flutter/material.dart';

const _bg = Color(0xFFF7F4EE);
const _ink = Color(0xFF1D1A24);
const _line = Color(0xFFE6E1DA);
const _primary = Color(0xFF1E8E5A);

final appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: _primary,
    primary: _primary,
    onSurface: _ink,
    surface: _bg,
    outlineVariant: _line,
  ),
  scaffoldBackgroundColor: _bg,
  appBarTheme: const AppBarTheme(
    backgroundColor: _bg,
    foregroundColor: _ink,
    elevation: 0,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _line),
    ),
  ),
);
