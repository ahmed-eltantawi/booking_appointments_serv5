import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';
import 'package:booking_appointments/features/booking/domain/Entities/booking_duration.dart';

/// Banner widget displayed when no valid start times exist for the selected duration.
class NoAvailableSlotsWidget extends StatelessWidget {
  const NoAvailableSlotsWidget({
    super.key,
    required this.duration,
  });

  final BookingDuration duration;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final durationText = _durationLabel(l10n, duration);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: colorScheme.primary,
            size: 18.r,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              l10n.noAvailableSlotsForDuration(durationText),
              style: AppTextStyles.regular14.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _durationLabel(S l10n, BookingDuration duration) {
    return switch (duration) {
      BookingDuration.thirtyMinutes => l10n.duration30Min,
      BookingDuration.oneHour       => l10n.duration1Hour,
      BookingDuration.oneHalfHour   => l10n.duration1Half,
      BookingDuration.twoHours      => l10n.duration2Hours,
    };
  }
}
