import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/core/extensions/snack_bar_extensions.dart';
import 'package:booking_appointments/features/booking/domain/booking_schedule.dart';
import 'package:booking_appointments/features/booking/presentation/manager/booking_cubit.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/booking_action_bar_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/booking_header_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/booking_summary_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/duration_selector_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/slot_legend_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/time_slot_grid_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/validation_error_widget.dart';

/// Main content area for the booking screen.
/// Uses [BlocConsumer] to rebuild on state changes and show feedback snackbars.
class BookingViewBody extends StatelessWidget {
  const BookingViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return BlocConsumer<BookingCubit, BookingState>(
      listenWhen: (previous, current) {
        if (current is BookingConfirmed) return true;
        if (current is BookingFailure) return true;
        if (current is BookingSuccess) {
          final vr = current.schedule.validationResult;
          return vr != null && !vr.isValid;
        }
        return false;
      },
      listener: (context, state) {
        if (state is BookingConfirmed) {
          context.showSuccessSnackBar(l10n.bookingSuccessful);
        } else if (state is BookingFailure) {
          context.showErrorSnackBar(state.message);
        } else if (state is BookingSuccess) {
          final schedule = state.schedule;
          final vr = schedule.validationResult;
          if (vr != null && !vr.isValid) {
            final String msg = formatValidationErrorMessage(
              validationResult: vr,
              l10n: l10n,
            );
            context.showErrorSnackBar(msg);
          }
        }
      },
      builder: (context, state) {
        if (state is BookingInitial || state is BookingLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final BookingSchedule schedule;
        if (state is BookingSuccess) {
          schedule = state.schedule;
        } else if (state is BookingConfirmed) {
          schedule = state.schedule;
        } else {
          return const SizedBox.shrink();
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookingHeaderWidget(l10n: l10n),
              SizedBox(height: 24.h),
              DurationSelectorWidget(
                selectedDuration: schedule.selectedDuration,
              ),
              SizedBox(height: 20.h),
              TimeSlotGridWidget(
                slots: schedule.slots,
                validStartIndexes: schedule.validStartIndexes,
              ),
              SizedBox(height: 16.h),
              const SlotLegendWidget(),
              SizedBox(height: 20.h),
              BookingSummaryWidget(schedule: schedule),
              SizedBox(height: 12.h),
              if (schedule.validationResult != null &&
                  !schedule.validationResult!.isValid)
                ValidationErrorWidget(
                  reason: schedule.validationResult!.reason!,
                  l10n: l10n,
                ),
              SizedBox(height: 24.h),
              BookingActionBarWidget(
                canConfirm: schedule.selectedStartIndex != null &&
                    (schedule.validationResult?.isValid ?? false),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }
}
