import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';
import 'package:booking_appointments/features/booking/domain/Entities/booking_duration.dart';
import 'package:booking_appointments/features/booking/domain/Entities/booking_validation_result.dart';
import 'package:booking_appointments/features/booking/domain/Entities/time_slot.dart';
import 'package:booking_appointments/features/booking/presentation/manager/booking_cubit.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/slot_cell/slot_cell_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/staggered_entrance_widget.dart';

//==============================================================================
/// Displays the working day time slots as a 3-column grid using [GridView.builder].
//==============================================================================
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
    
    // convert start time to minutes to make calculations easier
    final selectedStartMins = selectedStart != null
        ? (selectedStart!.hour * 60 + selectedStart!.minute)
        : null;
        
    // calculate the end minutes of the current selection
    final selectedEndMins = selectedStartMins != null
        ? selectedStartMins + selectedDuration.minutes
        : null;

    // check if the current selection failed validation
    final isSelectionInvalid =
        validationResult != null && !validationResult!.isValid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //==============================================================================
        // 1. Section Header
        //==============================================================================
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

        //==============================================================================
        // 2. 3-column Slot Grid
        //==============================================================================
        GridView.builder(
          shrinkWrap: true,
          // we disable scrolling here because we use SingleChildScrollView in the parent
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
            
            // a slot is valid to start a booking if it's available and inside the valid starts list
            final isValidStart =
                validStartTimes.contains(slot.start) &&
                slot.status == SlotStatus.available;

            // check if this specific slot falls within the currently selected time range
            final isSelected =
                selectedStartMins != null &&
                selectedEndMins != null &&
                slot.startMinutes >= selectedStartMins &&
                slot.startMinutes < selectedEndMins;

            // calculate the offset to determine if it's the first, middle, or last slot in the selection
            final rangeOffset = isSelected
                ? ((slot.startMinutes - selectedStartMins) ~/ 30)
                : 0;

            return StaggeredEntranceWidget(
              key: ValueKey(
                'entrance_slot_${slot.start.hour}_${slot.start.minute}',
              ),
              index: index,
              initialDelay: const Duration(milliseconds: 260),
              // stagger each cell slightly to create a wave effect
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
                    // dispatch the tap event to the cubit
                    context.read<BookingCubit>().selectStartTime(slot.start),
              ),
            );
          },
        ),
      ],
    );
  }
}
