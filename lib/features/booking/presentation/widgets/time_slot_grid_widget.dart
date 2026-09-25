import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';
import 'package:booking_appointments/features/booking/domain/booking_duration.dart';
import 'package:booking_appointments/features/booking/domain/booking_validation_result.dart';
import 'package:booking_appointments/features/booking/domain/time_slot.dart';
import 'package:booking_appointments/features/booking/presentation/manager/booking_cubit.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/slot_cell_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/staggered_entrance_widget.dart';

/// Displays the working day time slots as a 3-column grid using [GridView.builder].
class TimeSlotGridWidget extends StatelessWidget {
  const TimeSlotGridWidget({
    super.key,
    required this.slots,
    required this.validStartTimes,
    required this.selectedDuration,
    this.selectedStart,
    this.validationResult,
  });

  final List<TimeSlot> slots;
  final List<TimeOfDay> validStartTimes;
  final BookingDuration selectedDuration;
  final TimeOfDay? selectedStart;
  final BookingValidationResult? validationResult;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final selectedStartMins = selectedStart != null
        ? (selectedStart!.hour * 60 + selectedStart!.minute)
        : null;
    final selectedEndMins = selectedStartMins != null
        ? selectedStartMins + selectedDuration.minutes
        : null;

    final isSelectionInvalid = validationResult != null && !validationResult!.isValid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Section header entrance ---
        StaggeredEntranceWidget(
          key: const ValueKey('entrance_slots_header'),
          initialDelay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 400),
          slideOffset: const Offset(0, 0.12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.timeSlots,
                style: AppTextStyles.semiBold18.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                l10n.selectStartTimeHint,
                style: AppTextStyles.regular12.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),

        // --- 3-column slot grid with staggered cell entrances ---
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.h,
            childAspectRatio: 2.2,
          ),
          itemCount: slots.length,
          itemBuilder: (context, index) {
            final slot = slots[index];
            final isValidStart = validStartTimes.contains(slot.start) &&
                slot.status == SlotStatus.available;

            final isSelected = selectedStartMins != null &&
                selectedEndMins != null &&
                slot.startMinutes >= selectedStartMins &&
                slot.startMinutes < selectedEndMins;

            final rangeOffset = isSelected
                ? ((slot.startMinutes - selectedStartMins) ~/ 30)
                : 0;

            return StaggeredEntranceWidget(
              key: ValueKey('entrance_slot_${slot.start.hour}_${slot.start.minute}'),
              index: index,
              initialDelay: const Duration(milliseconds: 260),
              delayStep: const Duration(milliseconds: 55),
              duration: const Duration(milliseconds: 400),
              slideOffset: const Offset(0, 0.12),
              child: SlotCellWidget(
                slot: slot,
                isValidStart: isValidStart,
                isSelected: isSelected,
                isInvalidSelection: isSelected && isSelectionInvalid,
                rangeOffset: rangeOffset,
                onTap: () =>
                    context.read<BookingCubit>().selectStartTime(slot.start),
              ),
            );
          },
        ),
      ],
    );
  }
}
