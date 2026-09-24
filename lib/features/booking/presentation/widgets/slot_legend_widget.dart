import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/core/utils/app_colors.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';

/// A compact color-coded legend explaining the four slot statuses.
class SlotLegendWidget extends StatelessWidget {
  const SlotLegendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.legend,
          style: AppTextStyles.semiBold18.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 8.h,
          children: [
            _LegendItem(
              bg: isDark ? AppColors.slotAvailableBgDark : AppColors.slotAvailableBg,
              fg: isDark ? AppColors.slotAvailableFgDark : AppColors.slotAvailableFg,
              label: l10n.available,
            ),
            _LegendItem(
              bg: isDark ? AppColors.slotBookedBgDark : AppColors.slotBookedBg,
              fg: isDark ? AppColors.slotBookedFgDark : AppColors.slotBookedFg,
              label: l10n.booked,
            ),
            _LegendItem(
              bg: isDark ? AppColors.slotUnavailableBgDark : AppColors.slotUnavailableBg,
              fg: isDark ? AppColors.slotUnavailableFgDark : AppColors.slotUnavailableFg,
              label: l10n.unavailable,
            ),
            _LegendItem(
              bg: isDark ? AppColors.slotSelectedBgDark : AppColors.slotSelectedBg,
              fg: isDark ? AppColors.slotSelectedFgDark : AppColors.slotSelectedFg,
              label: l10n.selected,
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.bg,
    required this.fg,
    required this.label,
  });

  final Color bg;
  final Color fg;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: AppTextStyles.regular12.copyWith(color: fg),
      ),
    );
  }
}
