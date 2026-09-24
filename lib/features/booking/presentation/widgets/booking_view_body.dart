import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/core/utils/app_colors.dart';
import 'package:booking_appointments/features/booking/domain/booking_validation_result.dart';
import 'package:booking_appointments/features/booking/presentation/manager/booking_cubit.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/booking_action_bar_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/booking_header_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/booking_summary_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/duration_selector_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/slot_legend_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/time_slot_grid_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/validation_error_widget.dart';

/// Main content area for the booking screen.
/// Uses [BlocConsumer] to rebuild on state changes and show a success snackbar
/// when a booking is confirmed or an error snackbar when invalid slot is tapped.
class BookingViewBody extends StatelessWidget {
  const BookingViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return BlocConsumer<BookingCubit, BookingState>(
      listenWhen: (previous, current) {
        if (current is! BookingData) return false;
        return current.status == BookingStatus.confirmed ||
            (current.validationResult != null && !current.validationResult!.isValid);
      },
      listener: (context, state) {
        if (state is! BookingData) return;
        if (state.status == BookingStatus.confirmed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.bookingSuccessful),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state.validationResult != null && !state.validationResult!.isValid) {
          final slotName = state.selectedStartIndex != null &&
                  state.selectedStartIndex! < state.slots.length
              ? state.slots[state.selectedStartIndex!].timeLabel
              : '';
          final String msg = switch (state.validationResult!.reason!) {
            BookingInvalidReason.containsBookedSlot =>
              '$slotName is already booked.',
            BookingInvalidReason.containsUnavailableSlot =>
              '$slotName is currently unavailable.',
            BookingInvalidReason.exceedsWorkingHours =>
              l10n.errorExceedsWorkingHours,
            BookingInvalidReason.createsInvalidGap =>
              l10n.errorCreatesInvalidGap,
          };
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
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
              BookingHeaderWidget(l10n: l10n),
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
                ValidationErrorWidget(
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
