import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';
import 'package:booking_appointments/features/booking/domain/booking_duration.dart';
import 'package:booking_appointments/features/booking/domain/booking_schedule.dart';
import 'package:booking_appointments/features/booking/domain/slot_model.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/summary_row_widget.dart';

/// Card showing the user's current booking selection.
/// When no selection is active, shows a placeholder message.
class BookingSummaryWidget extends StatelessWidget {
  const BookingSummaryWidget({super.key, required this.schedule});

  final BookingSchedule schedule;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final hasSelection = schedule.selectedStartIndex != null;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Section heading ---
            Text(
              l10n.bookingSummary,
              style: AppTextStyles.semiBold18.copyWith(color: colorScheme.onSurface),
            ),
            SizedBox(height: 12.h),

            // --- Placeholder when nothing is selected ---
            if (!hasSelection)
              Text(
                l10n.noSelectionYet,
                style: AppTextStyles.regular14.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

            // --- Summary rows when a start time is selected ---
            if (hasSelection) ...[
              SummaryRowWidget(
                label: l10n.startLabel,
                value: slotIndexToTimeLabel(schedule.selectedStartIndex!),
              ),
              SizedBox(height: 6.h),
              SummaryRowWidget(
                label: l10n.endLabel,
                value: schedule.selectedEndIndex != null
                    ? slotIndexToTimeLabel(schedule.selectedEndIndex! + 1)
                    : '—',
              ),
              SizedBox(height: 6.h),
              SummaryRowWidget(
                label: l10n.durationLabel,
                value: _durationLabel(l10n, schedule.selectedDuration),
              ),
            ],
          ],
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
