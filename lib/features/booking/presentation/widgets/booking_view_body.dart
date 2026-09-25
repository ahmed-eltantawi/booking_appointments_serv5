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
import 'package:booking_appointments/features/booking/presentation/widgets/no_available_slots_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/slot_legend_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/staggered_entrance_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/time_slot_grid_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/validation_error_widget.dart';

/// Main content area for the booking screen.
/// Uses [BlocConsumer] to rebuild on state changes, show feedback snackbars,
/// and render progressive entrance animations and micro-interactions.
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
        final bool isConfirmed = state is BookingConfirmed;

        if (state is BookingSuccess) {
          schedule = state.schedule;
        } else if (isConfirmed) {
          schedule = state.schedule;
        } else {
          return const SizedBox.shrink();
        }

        final showNoAvailableSlots = schedule.validStartIndexes.isEmpty &&
            schedule.selectedStartIndex == null;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Header / Title (FadeInDown) ---
              StaggeredEntranceWidget(
                key: const ValueKey('entrance_header'),
                initialDelay: Duration.zero,
                duration: const Duration(milliseconds: 450),
                slideOffset: const Offset(0, -0.15),
                child: BookingHeaderWidget(l10n: l10n),
              ),
              SizedBox(height: 24.h),

              // --- 2. Duration Selection ---
              DurationSelectorWidget(
                selectedDuration: schedule.selectedDuration,
              ),
              SizedBox(height: 20.h),

              // --- 3. Time Slots (Staggered Grid Entrance) ---
              TimeSlotGridWidget(
                key: const ValueKey('entrance_slots_grid'),
                slots: schedule.slots,
                validStartIndexes: schedule.validStartIndexes,
                selectedStartIndex: schedule.selectedStartIndex,
              ),

              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: showNoAvailableSlots ? 1.0 : 0.0,
                  child: showNoAvailableSlots
                      ? Padding(
                          padding: EdgeInsets.only(top: 12.h),
                          child: StaggeredEntranceWidget(
                            key: const ValueKey('entrance_no_slots'),
                            initialDelay: const Duration(milliseconds: 500),
                            duration: const Duration(milliseconds: 450),
                            child: NoAvailableSlotsWidget(
                              duration: schedule.selectedDuration,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              SizedBox(height: 16.h),

              // --- 4. Other Sections (Legend, Summary, Validation, Action Bar) ---
              const StaggeredEntranceWidget(
                key: ValueKey('entrance_legend'),
                initialDelay: Duration(milliseconds: 600),
                duration: Duration(milliseconds: 450),
                slideOffset: Offset(0, 0.15),
                child: SlotLegendWidget(),
              ),
              SizedBox(height: 20.h),
              StaggeredEntranceWidget(
                key: const ValueKey('entrance_summary'),
                initialDelay: const Duration(milliseconds: 680),
                duration: const Duration(milliseconds: 450),
                slideOffset: const Offset(0, 0.15),
                child: BookingSummaryWidget(
                  schedule: schedule,
                  isConfirmed: isConfirmed,
                ),
              ),
              SizedBox(height: 12.h),
              if (schedule.validationResult != null &&
                  !schedule.validationResult!.isValid)
                StaggeredEntranceWidget(
                  key: const ValueKey('entrance_validation'),
                  initialDelay: const Duration(milliseconds: 740),
                  duration: const Duration(milliseconds: 450),
                  slideOffset: const Offset(0, 0.15),
                  child: ValidationErrorWidget(
                    reason: schedule.validationResult!.reason!,
                    l10n: l10n,
                  ),
                ),
              SizedBox(height: 24.h),
              StaggeredEntranceWidget(
                key: const ValueKey('entrance_action_bar'),
                initialDelay: const Duration(milliseconds: 780),
                duration: const Duration(milliseconds: 450),
                slideOffset: const Offset(0, 0.15),
                child: BookingActionBarWidget(
                  canConfirm: schedule.selectedStartIndex != null &&
                      (schedule.validationResult?.isValid ?? false),
                  isConfirmed: isConfirmed,
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }
}
