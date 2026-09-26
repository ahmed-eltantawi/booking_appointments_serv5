import 'package:flutter/material.dart';
import 'package:booking_appointments/core/utils/app_colors.dart';
import 'package:booking_appointments/features/booking/domain/Entities/time_slot.dart';

/// Presentation-only styling logic for slot cell colors and icons.
abstract final class SlotCellStyle {
  /// Returns background and foreground colors based on slot status, selection state,
  /// theme mode, and [ColorScheme].
  static (Color, Color) colorsForStatus({
    required SlotStatus status,
    required bool isSelected,
    required bool isInvalidSelection,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    if (isSelected && !isInvalidSelection) {
      return isDark
          ? (AppColors.slotSelectedBgDark, AppColors.slotSelectedFgDark)
          : (AppColors.slotSelectedBg, AppColors.slotSelectedFg);
    }

    if (isSelected && isInvalidSelection) {
      switch (status) {
        case SlotStatus.myBooking:
          final baseBg = isDark
              ? AppColors.slotMyBookingBgDark
              : AppColors.slotMyBookingBg;
          final baseFg = isDark
              ? AppColors.slotMyBookingFgDark
              : AppColors.slotMyBookingFg;
          return (
            Color.alphaBlend(colorScheme.error.withValues(alpha: 0.2), baseBg),
            baseFg,
          );
        case SlotStatus.booked:
          final baseBg = isDark
              ? AppColors.slotBookedBgDark
              : AppColors.slotBookedBg;
          final baseFg = isDark
              ? AppColors.slotBookedFgDark
              : AppColors.slotBookedFg;
          return (
            Color.alphaBlend(colorScheme.error.withValues(alpha: 0.2), baseBg),
            baseFg,
          );
        case SlotStatus.unavailable:
          final baseBg = isDark
              ? AppColors.slotUnavailableBgDark
              : AppColors.slotUnavailableBg;
          final baseFg = isDark
              ? AppColors.slotUnavailableFgDark
              : AppColors.slotUnavailableFg;
          return (
            Color.alphaBlend(colorScheme.error.withValues(alpha: 0.2), baseBg),
            baseFg,
          );
        case SlotStatus.available:
          return (colorScheme.error.withValues(alpha: 0.12), colorScheme.error);
      }
    }

    return switch (status) {
      SlotStatus.available =>
        isDark
            ? (AppColors.slotAvailableBgDark, AppColors.slotAvailableFgDark)
            : (AppColors.slotAvailableBg, AppColors.slotAvailableFg),
      SlotStatus.myBooking =>
        isDark
            ? (AppColors.slotMyBookingBgDark, AppColors.slotMyBookingFgDark)
            : (AppColors.slotMyBookingBg, AppColors.slotMyBookingFg),
      SlotStatus.booked =>
        isDark
            ? (AppColors.slotBookedBgDark, AppColors.slotBookedFgDark)
            : (AppColors.slotBookedBg, AppColors.slotBookedFg),
      SlotStatus.unavailable =>
        isDark
            ? (AppColors.slotUnavailableBgDark, AppColors.slotUnavailableFgDark)
            : (AppColors.slotUnavailableBg, AppColors.slotUnavailableFg),
    };
  }

  /// Returns the appropriate icon data for the given slot status and selection state.
  static IconData? iconForStatus({
    required SlotStatus status,
    required bool isSelected,
    required bool isInvalidSelection,
  }) {
    if (isSelected && !isInvalidSelection) {
      return Icons.check_circle_rounded;
    }
    if (isSelected && isInvalidSelection) {
      switch (status) {
        case SlotStatus.myBooking:
          return Icons.person_rounded;
        case SlotStatus.booked:
          return Icons.lock_clock_rounded;
        case SlotStatus.unavailable:
          return Icons.block_rounded;
        case SlotStatus.available:
          return Icons.warning_amber_rounded;
      }
    }
    return switch (status) {
      SlotStatus.available => null,
      SlotStatus.myBooking => Icons.person_rounded,
      SlotStatus.booked => Icons.lock_clock_rounded,
      SlotStatus.unavailable => Icons.block_rounded,
    };
  }
}
