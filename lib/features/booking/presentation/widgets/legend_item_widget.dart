import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/core/utils/app_colors.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';

/// Single legend chip used within [SlotLegendWidget].
class LegendItemWidget extends StatelessWidget {
  const LegendItemWidget({
    super.key,
    required this.bg,
    required this.fg,
    required this.label,
    this.icon,
    this.borderColor,
  });

  final Color bg;
  final Color fg;
  final String label;
  final IconData? icon;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: borderColor ?? AppColors.outline.withValues(alpha: 0.4),
          width: borderColor != null ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14.r, color: fg),
            SizedBox(width: 4.w),
          ],
          Text(label, style: AppTextStyles.regular12.copyWith(color: fg)),
        ],
      ),
    );
  }
}
