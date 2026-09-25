import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';
import 'package:booking_appointments/features/booking/domain/slot_model.dart';
import 'package:booking_appointments/features/booking/presentation/manager/booking_cubit.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/slot_cell_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/staggered_entrance_widget.dart';

/// Displays the 18-slot working day as a 3-column grid using [GridView.builder].
///
/// Wraps the section header and individual time slot cells with [StaggeredEntranceWidget]
/// to provide a smooth cascading entrance animation when the page opens.
class TimeSlotGridWidget extends StatelessWidget {
  const TimeSlotGridWidget({
    super.key,
    required this.slots,
    required this.validStartIndexes,
    this.selectedStartIndex,
  });

  final List<SlotModel> slots;
  final List<int> validStartIndexes;
  final int? selectedStartIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
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
            final isValidStart = validStartIndexes.contains(slot.index) &&
                slot.status == SlotStatus.available;
            final rangeOffset =
                (slot.status == SlotStatus.selected && selectedStartIndex != null)
                    ? (slot.index - selectedStartIndex!)
                    : 0;

            return StaggeredEntranceWidget(
              key: ValueKey('entrance_slot_${slot.index}'),
              index: index,
              initialDelay: const Duration(milliseconds: 260),
              delayStep: const Duration(milliseconds: 55),
              duration: const Duration(milliseconds: 400),
              slideOffset: const Offset(0, 0.12),
              child: SlotCellWidget(
                slot: slot,
                isValidStart: isValidStart,
                rangeOffset: rangeOffset,
                onTap: () =>
                    context.read<BookingCubit>().handleSlotTap(slot.index),
              ),
            );
          },
        ),
      ],
    );
  }
}

