import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/core/utils/app_colors.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';
import 'package:booking_appointments/features/booking/domain/booking_duration.dart';
import 'package:booking_appointments/features/booking/domain/booking_schedule.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/summary_row_widget.dart';

/// Card showing the user's current booking selection with smooth animated transitions.
class BookingSummaryWidget extends StatelessWidget {
  const BookingSummaryWidget({
    super.key,
    required this.schedule,
    this.isConfirmed = false,
  });

  final BookingSchedule schedule;
  final bool isConfirmed;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final hasSelection = schedule.selectedStart != null;

    final selectedStart = schedule.selectedStart;
    final selectedEnd = schedule.selectedEnd;

    final startTimeFormatted = selectedStart != null ? selectedStart.format(context) : '';
    final endTimeFormatted = selectedEnd != null ? selectedEnd.format(context) : '';

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: isConfirmed
              ? const BorderSide(color: AppColors.success, width: 1.5)
              : BorderSide.none,
        ),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Section heading & confirmation badge ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      l10n.bookingSummary,
                      style: AppTextStyles.semiBold18.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (isConfirmed)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 14.r,
                            color: AppColors.success,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            l10n.selected,
                            style: AppTextStyles.bold12.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12.h),

              // --- Animated content switcher ---
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: !hasSelection
                    ? SizedBox(
                        key: const ValueKey('no_selection'),
                        width: double.infinity,
                        child: Text(
                          l10n.noSelectionYet,
                          style: AppTextStyles.regular14.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : Column(
                        key: const ValueKey('has_selection'),
                        children: [
                          SummaryRowWidget(
                            label: l10n.startLabel,
                            value: startTimeFormatted,
                          ),
                          SizedBox(height: 6.h),
                          SummaryRowWidget(
                            label: l10n.endLabel,
                            value: endTimeFormatted,
                          ),
                          SizedBox(height: 6.h),
                          SummaryRowWidget(
                            label: l10n.selectedDurationLabel,
                            value: _durationLabel(
                              l10n,
                              schedule.selectedDuration,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          SummaryRowWidget(
                            label: l10n.totalDurationLabel,
                            value: _durationLabel(
                              l10n,
                              schedule.selectedDuration,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
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
