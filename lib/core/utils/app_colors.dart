import 'package:flutter/material.dart';

///* AppColors — centralized color palette for the booking appointments app.
///* All colors are grouped by semantic category. Reference these constants
///* in themes, widgets, and extensions — never hardcode hex values elsewhere.

abstract class AppColors {
  //! ===== Primary =====
  static const Color primary = Color(0xFF4763E4);
  static const Color primaryLight = Color(0xFFE8EBFD);
  static const Color onPrimary = Color(0xFFFFFFFF);

  //! ===== Secondary =====
  static const Color secondary = Color(0xFF00B8A9);
  static const Color onSecondary = Color(0xFFFFFFFF);

  //! ===== Backgrounds =====
  static const Color background = Color(0xFFF8F9FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F2FF);

  //! ===== Text Colors =====
  static const Color textPrimary = Color(0xFF1A1D3A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFFB0B8C8);

  //! ===== Borders & Divider =====
  static const Color outline = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFEEF0F6);

  //! ===== Status Colors =====
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  //! ===== Slot Status Colors — Light Theme =====
  static const Color slotAvailableBg = Color(0xFFDCFCE7);
  static const Color slotAvailableFg = Color(0xFF166534);
  static const Color slotBookedBg = Color(0xFFFFE4E6);
  static const Color slotBookedFg = Color(0xFF9F1239);
  static const Color slotUnavailableBg = Color(0xFFF1F5F9);
  static const Color slotUnavailableFg = Color(0xFF94A3B8);
  static const Color slotSelectedBg = Color(0xFF4763E4);
  static const Color slotSelectedFg = Color(0xFFFFFFFF);

  //! ===== Slot Status Colors — Dark Theme =====
  static const Color slotAvailableBgDark = Color(0xFF052E16);
  static const Color slotAvailableFgDark = Color(0xFF4ADE80);
  static const Color slotBookedBgDark = Color(0xFF4C0519);
  static const Color slotBookedFgDark = Color(0xFFFCA5A5);
  static const Color slotUnavailableBgDark = Color(0xFF1E2130);
  static const Color slotUnavailableFgDark = Color(0xFF64748B);
  static const Color slotSelectedBgDark = Color(0xFF4763E4);
  static const Color slotSelectedFgDark = Color(0xFFFFFFFF);
}
