import 'package:flutter/material.dart';
import 'package:booking_appointments/core/utils/app_constants.dart';

///* darkTheme — Material3 dark theme for the booking appointments app.
///* Dark-specific colors use inline hex values per GEMINI.md convention.

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  fontFamily: AppConstants.appFamilyFont.isEmpty ? null : AppConstants.appFamilyFont,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF4763E4),
    brightness: Brightness.dark,
  ).copyWith(
    primary: const Color(0xFF7B96FF),
    onPrimary: const Color(0xFF0A1560),
    secondary: const Color(0xFF4DDDD2),
    onSecondary: const Color(0xFF00302C),
    tertiary: const Color(0xFF64B5F6),
    onTertiary: const Color(0xFF00285A),
    error: const Color(0xFFFF7878),
    surface: const Color(0xFF12152B),
    onSurface: const Color(0xFFE2E8F0),
    onSurfaceVariant: const Color(0xFF94A3B8),
    outline: const Color(0xFF2D3453),
    surfaceContainerHighest: const Color(0xFF1E2340),
  ),
  scaffoldBackgroundColor: const Color(0xFF0A0D1F),
  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: Color(0xFF12152B),
    foregroundColor: Color(0xFFE2E8F0),
    surfaceTintColor: Colors.transparent,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: const Color(0xFF7B96FF),
      foregroundColor: const Color(0xFF0A1560),
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: const Color(0xFF7B96FF),
      minimumSize: const Size(double.infinity, 52),
      side: const BorderSide(color: Color(0xFF7B96FF)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  cardTheme: const CardThemeData(
    elevation: 0,
    color: Color(0xFF12152B),
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFF2D3453),
    thickness: 1,
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);
