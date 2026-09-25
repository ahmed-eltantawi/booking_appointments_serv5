import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';
import 'package:booking_appointments/features/booking/domain/booking_duration.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/duration_chip_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/staggered_entrance_widget.dart';

/// Horizontal row of duration selection chips.
/// Displays all [BookingDuration] options; the currently selected chip is
/// visually highlighted. Tapping a chip calls [BookingCubit.selectDuration].
class DurationSelectorWidget extends StatelessWidget {
  const DurationSelectorWidget({super.key, required this.selectedDuration});

  final BookingDuration selectedDuration;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final durations = BookingDuration.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StaggeredEntranceWidget(
          key: const ValueKey('entrance_duration_header'),
          initialDelay: const Duration(milliseconds: 80),
          duration: const Duration(milliseconds: 400),
          slideOffset: const Offset(0, 0.12),
          child: Text(
            l10n.selectDuration,
            style: AppTextStyles.semiBold18.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(durations.length, (index) {
              final duration = durations[index];
              return StaggeredEntranceWidget(
                key: ValueKey('entrance_chip_${duration.name}'),
                index: index,
                initialDelay: const Duration(milliseconds: 140),
                delayStep: const Duration(milliseconds: 55),
                duration: const Duration(milliseconds: 400),
                slideOffset: const Offset(0, 0.12),
                child: DurationChipWidget(
                  duration: duration,
                  isSelected: duration == selectedDuration,
                  label: _labelFor(l10n, duration),
                ),
              );
            }),
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
