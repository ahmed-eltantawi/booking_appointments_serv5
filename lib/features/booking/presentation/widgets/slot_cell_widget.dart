import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/core/utils/app_colors.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';
import 'package:booking_appointments/features/booking/domain/slot_model.dart';

/// An individual time-slot cell in the booking grid.
///
/// Visual states:
///   • [SlotStatus.available] + [isValidStart] = true → tappable, green tint.
///   • [SlotStatus.available] + [isValidStart] = false → dimmed, non-tappable.
///   • [SlotStatus.selected] → primary-color highlight with border pulse.
///   • [SlotStatus.booked]   → red/coral tint, non-tappable.
///   • [SlotStatus.unavailable] → gray, non-tappable.
class SlotCellWidget extends StatelessWidget {
  const SlotCellWidget({
    super.key,
    required this.slot,
    required this.isValidStart,
    this.onTap,
  });

  final SlotModel slot;

  /// True when this slot is a valid start point for the current duration.
  /// Used to visually distinguish tappable available slots from dimmed ones.
  final bool isValidStart;

  /// Callback invoked when the slot is tapped. Null for non-interactive slots.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (bgColor, fgColor) = _colorsForStatus(slot.status, isDark);
    final isAvailableButNotValid =
        slot.status == SlotStatus.available && !isValidStart;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isAvailableButNotValid ? 0.45 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: slot.status == SlotStatus.selected
                  ? AppColors.primary
                  : AppColors.outline.withValues(alpha: isDark ? 0.3 : 1.0),
              width: slot.status == SlotStatus.selected ? 2 : 1,
            ),
            boxShadow: slot.status == SlotStatus.selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              slot.timeLabel,
              style: AppTextStyles.medium12.copyWith(color: fgColor),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  /// Returns (backgroundColor, foregroundColor) for the given [status].
  /// Dark-mode values use the *Dark AppColors constants.
  (Color, Color) _colorsForStatus(SlotStatus status, bool isDark) {
    return switch (status) {
      SlotStatus.available   => isDark
          ? (AppColors.slotAvailableBgDark, AppColors.slotAvailableFgDark)
          : (AppColors.slotAvailableBg, AppColors.slotAvailableFg),
      SlotStatus.booked      => isDark
          ? (AppColors.slotBookedBgDark, AppColors.slotBookedFgDark)
          : (AppColors.slotBookedBg, AppColors.slotBookedFg),
      SlotStatus.unavailable => isDark
          ? (AppColors.slotUnavailableBgDark, AppColors.slotUnavailableFgDark)
          : (AppColors.slotUnavailableBg, AppColors.slotUnavailableFg),
      SlotStatus.selected    => isDark
          ? (AppColors.slotSelectedBgDark, AppColors.slotSelectedFgDark)
          : (AppColors.slotSelectedBg, AppColors.slotSelectedFg),
    };
  }
}
