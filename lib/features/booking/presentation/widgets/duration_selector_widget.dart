import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';
import 'package:booking_appointments/features/booking/domain/booking_duration.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/duration_chip_widget.dart';

/// Horizontal row of duration selection chips.
/// Displays all [BookingDuration] options; the currently selected chip is
/// visually highlighted. Tapping a chip calls [BookingCubit.selectDuration].
class DurationSelectorWidget extends StatelessWidget {
  const DurationSelectorWidget({super.key, required this.selectedDuration});

  final BookingDuration selectedDuration;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectDuration,
          style: AppTextStyles.semiBold18.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 12.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: BookingDuration.values.map((duration) {
              return DurationChipWidget(
                duration: duration,
                isSelected: duration == selectedDuration,
                label: _labelFor(l10n, duration),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _labelFor(S l10n, BookingDuration duration) {
    return switch (duration) {
      BookingDuration.thirtyMinutes => l10n.duration30Min,
      BookingDuration.oneHour       => l10n.duration1Hour,
      BookingDuration.oneHalfHour   => l10n.duration1Half,
      BookingDuration.twoHours      => l10n.duration2Hours,
    };
  }
}
