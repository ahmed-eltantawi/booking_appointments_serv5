import 'package:flutter/material.dart';
import 'package:booking_appointments/core/utils/app_colors.dart';
import 'package:booking_appointments/core/utils/app_constants.dart';

///* lightTheme — Material3 light theme for the booking appointments app.
///* Colors are sourced from AppColors. Font family from AppConstants.

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  fontFamily: AppConstants.appFamilyFont.isEmpty
      ? null
      : AppConstants.appFamilyFont,
  colorScheme:
      ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        tertiary: AppColors.info,
        onTertiary: AppColors.onPrimary,
        error: AppColors.error,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.outline,
        surfaceContainerHighest: AppColors.surfaceVariant,
      ),
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.textPrimary,
    surfaceTintColor: Colors.transparent,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: AppColors.primary,
      minimumSize: const Size(double.infinity, 52),
      side: const BorderSide(color: AppColors.primary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  cardTheme: const CardThemeData(
    elevation: 0,
    color: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
  dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);
