import 'package:flutter/material.dart';
import 'package:booking_appointments/core/utils/app_constants.dart';

///* darkTheme — Material3 dark theme for the booking appointments app.
///* Implements a layered dark palette (Background → Surface → Container → Accent)
///* maintaining app brand identity (indigo/blue accent) with optimal contrast.

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  fontFamily: AppConstants.appFamilyFont.isEmpty ? null : AppConstants.appFamilyFont,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF4763E4),
    brightness: Brightness.dark,
  ).copyWith(
    primary: const Color(0xFF637CFF),
    onPrimary: const Color(0xFFFFFFFF),
    primaryContainer: const Color(0xFF1E2856),
    onPrimaryContainer: const Color(0xFFDCE2FF),
    secondary: const Color(0xFF2DD4BF),
    onSecondary: const Color(0xFF003731),
    tertiary: const Color(0xFF60A5FA),
    onTertiary: const Color(0xFF00295B),
    error: const Color(0xFFF87171),
    onError: const Color(0xFF450A0A),
    errorContainer: const Color(0xFF7F1D1D),
    onErrorContainer: const Color(0xFFFECACA),
    surface: const Color(0xFF161B2E),
    onSurface: const Color(0xFFF1F5F9),
    onSurfaceVariant: const Color(0xFF94A3B8),
    outline: const Color(0xFF2A324E),
    outlineVariant: const Color(0xFF1E243B),
    surfaceContainerLow: const Color(0xFF121729),
    surfaceContainer: const Color(0xFF1A2035),
    surfaceContainerHigh: const Color(0xFF222942),
    surfaceContainerHighest: const Color(0xFF2B3454),
  ),
  scaffoldBackgroundColor: const Color(0xFF0F1424),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Color(0xFF14192B),
    surfaceTintColor: Colors.transparent,
  ),
  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: Colors.transparent,
    foregroundColor: Color(0xFFF1F5F9),
    surfaceTintColor: Colors.transparent,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: const Color(0xFF637CFF),
      foregroundColor: const Color(0xFFFFFFFF),
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: const Color(0xFF637CFF),
      minimumSize: const Size(double.infinity, 52),
      side: const BorderSide(color: Color(0xFF637CFF)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  cardTheme: const CardThemeData(
    elevation: 0,
    color: Color(0xFF1A2035),
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
  dialogTheme: const DialogThemeData(
    backgroundColor: Color(0xFF1A2035),
    surfaceTintColor: Colors.transparent,
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Color(0xFF14192B),
    surfaceTintColor: Colors.transparent,
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFF2A324E),
    thickness: 1,
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: const Color(0xFF2B3454),
    contentTextStyle: const TextStyle(color: Color(0xFFF1F5F9)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);
