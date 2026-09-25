import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';
import 'package:booking_appointments/features/booking/domain/booking_validation_result.dart';

/// Formats a human-readable validation error message based on [validationResult].
String formatValidationErrorMessage({
  required BookingValidationResult validationResult,
  required S l10n,
}) {
  final reason = validationResult.reason;
  if (reason == null) return '';

  final conflictingTimeLabels = validationResult.conflictingTimeLabels;

  if (conflictingTimeLabels.isEmpty) {
    return switch (reason) {
      BookingInvalidReason.exceedsWorkingHours => l10n.errorExceedsWorkingHours,
      BookingInvalidReason.containsBookedSlot => l10n.errorContainsBookedSlot,
      BookingInvalidReason.containsUnavailableSlot => l10n.errorContainsUnavailableSlot,
      BookingInvalidReason.createsInvalidGap => l10n.errorCreatesInvalidGap,
    };
  }

  final String formattedTimes;
  if (conflictingTimeLabels.length == 1) {
    formattedTimes = conflictingTimeLabels.first;
    return switch (reason) {
      BookingInvalidReason.containsBookedSlot => '$formattedTimes is already booked.',
      BookingInvalidReason.containsUnavailableSlot => '$formattedTimes is currently unavailable.',
      BookingInvalidReason.exceedsWorkingHours => l10n.errorExceedsWorkingHours,
      BookingInvalidReason.createsInvalidGap => l10n.errorCreatesInvalidGap,
    };
  } else if (conflictingTimeLabels.length == 2) {
    formattedTimes = '${conflictingTimeLabels[0]} and ${conflictingTimeLabels[1]}';
  } else {
    final allButLast = conflictingTimeLabels
        .sublist(0, conflictingTimeLabels.length - 1)
        .join(', ');
    final last = conflictingTimeLabels.last;
    formattedTimes = '$allButLast and $last';
  }

  return switch (reason) {
    BookingInvalidReason.containsBookedSlot => '$formattedTimes are booked.',
    BookingInvalidReason.containsUnavailableSlot => '$formattedTimes are unavailable.',
    BookingInvalidReason.exceedsWorkingHours => l10n.errorExceedsWorkingHours,
    BookingInvalidReason.createsInvalidGap => l10n.errorCreatesInvalidGap,
  };
}

/// Banner widget displaying validation error messages when a booking selection is invalid.
class ValidationErrorWidget extends StatelessWidget {
  const ValidationErrorWidget({
    super.key,
    required this.reason,
    required this.l10n,
  });

  final BookingInvalidReason reason;
  final S l10n;

  @override
  Widget build(BuildContext context) {
    final message = switch (reason) {
      BookingInvalidReason.exceedsWorkingHours     => l10n.errorExceedsWorkingHours,
      BookingInvalidReason.containsBookedSlot      => l10n.errorContainsBookedSlot,
      BookingInvalidReason.containsUnavailableSlot => l10n.errorContainsUnavailableSlot,
      BookingInvalidReason.createsInvalidGap       => l10n.errorCreatesInvalidGap,
    };

    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: 1.0,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Theme.of(context).colorScheme.error,
                size: 18.r,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.regular14.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
