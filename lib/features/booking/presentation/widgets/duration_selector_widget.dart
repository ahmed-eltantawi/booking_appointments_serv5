import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/core/utils/app_colors.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';
import 'package:booking_appointments/features/booking/domain/booking_duration.dart';
import 'package:booking_appointments/features/booking/presentation/manager/booking_cubit.dart';

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
              return _DurationChip(
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

class _DurationChip extends StatelessWidget {
  const _DurationChip({
    required this.duration,
    required this.isSelected,
    required this.label,
  });

  final BookingDuration duration;
  final bool isSelected;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.read<BookingCubit>().selectDuration(duration),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? const Color(0xFF1E2340) : AppColors.surfaceVariant),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outline,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.medium14.copyWith(
            color: isSelected
                ? AppColors.onPrimary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
