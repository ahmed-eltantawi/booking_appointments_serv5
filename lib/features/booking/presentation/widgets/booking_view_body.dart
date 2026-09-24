import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/core/utils/app_colors.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';
import 'package:booking_appointments/features/booking/domain/booking_validation_result.dart';
import 'package:booking_appointments/features/booking/presentation/manager/booking_cubit.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/booking_action_bar_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/booking_summary_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/duration_selector_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/slot_legend_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/time_slot_grid_widget.dart';

/// Main content area for the booking screen.
/// Uses [BlocConsumer] to rebuild on state changes and show a success snackbar
/// when a booking is confirmed.
class BookingViewBody extends StatelessWidget {
  const BookingViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return BlocConsumer<BookingCubit, BookingState>(
      listenWhen: (_, current) =>
          current is BookingData && current.status == BookingStatus.confirmed,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.bookingSuccessful),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      },
      builder: (context, state) {
        if (state is BookingInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = state as BookingData;
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BookingHeaderWidget(l10n: l10n),
              SizedBox(height: 24.h),
              DurationSelectorWidget(selectedDuration: data.selectedDuration),
              SizedBox(height: 20.h),
              TimeSlotGridWidget(
                slots: data.slots,
                validStartIndexes: data.validStartIndexes,
              ),
              SizedBox(height: 16.h),
              const SlotLegendWidget(),
              SizedBox(height: 20.h),
              BookingSummaryWidget(data: data),
              SizedBox(height: 12.h),
              if (data.validationResult != null && !data.validationResult!.isValid)
                _ValidationErrorWidget(
                  reason: data.validationResult!.reason!,
                  l10n: l10n,
                ),
              SizedBox(height: 24.h),
              BookingActionBarWidget(
                canConfirm: data.selectedStartIndex != null &&
                    (data.validationResult?.isValid ?? false),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }
}

// --- Private sub-widgets ---

class _BookingHeaderWidget extends StatelessWidget {
  const _BookingHeaderWidget({required this.l10n});

  final S l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.bookAppointment,
          style: AppTextStyles.bold24.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          l10n.workingHours,
          style: AppTextStyles.regular14.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ValidationErrorWidget extends StatelessWidget {
  const _ValidationErrorWidget({required this.reason, required this.l10n});

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

    return Container(
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
    );
  }
}
