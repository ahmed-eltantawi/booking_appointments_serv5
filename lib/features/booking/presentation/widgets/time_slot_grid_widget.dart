import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';
import 'package:booking_appointments/features/booking/domain/slot_model.dart';
import 'package:booking_appointments/features/booking/presentation/manager/booking_cubit.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/slot_cell_widget.dart';

/// Displays the 18-slot working day as a 3-column grid using [GridView.builder].
class TimeSlotGridWidget extends StatelessWidget {
  const TimeSlotGridWidget({
    super.key,
    required this.slots,
    required this.validStartIndexes,
  });

  final List<SlotModel> slots;
  final List<int> validStartIndexes;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Section header ---
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
        SizedBox(height: 12.h),

        // --- 3-column slot grid ---
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
            return SlotCellWidget(
              slot: slot,
              isValidStart: isValidStart,
              onTap: () =>
                  context.read<BookingCubit>().handleSlotTap(slot.index),
            );
          },
        ),
      ],
    );
  }
}
