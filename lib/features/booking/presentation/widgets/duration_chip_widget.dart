import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/core/utils/app_colors.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';
import 'package:booking_appointments/features/booking/domain/Entities/booking_duration.dart';
import 'package:booking_appointments/features/booking/presentation/manager/booking_cubit.dart';

/// Single interactive duration chip with press micro-interactions and smooth selection animations.
class DurationChipWidget extends StatefulWidget {
  const DurationChipWidget({
    super.key,
    required this.duration,
    required this.isSelected,
    required this.label,
  });

  final BookingDuration duration;
  final bool isSelected;
  final String label;

  @override
  State<DurationChipWidget> createState() => _DurationChipWidgetState();
}

class _DurationChipWidgetState extends State<DurationChipWidget> {
  final ValueNotifier<bool> _isPressedNotifier = ValueNotifier<bool>(false);

  void _onTapDown(TapDownDetails details) {
    _isPressedNotifier.value = true;
  }

  void _onTapUp(TapUpDetails details) {
    _isPressedNotifier.value = false;
    HapticFeedback.selectionClick();
    context.read<BookingCubit>().selectDuration(widget.duration);
  }

  void _onTapCancel() {
    _isPressedNotifier.value = false;
  }

  @override
  void dispose() {
    _isPressedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ValueListenableBuilder<bool>(
        valueListenable: _isPressedNotifier,
        builder: (context, isPressed, child) {
          final scale = isPressed ? 0.96 : (widget.isSelected ? 1.02 : 1.0);

          return AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? AppColors.primary
                    : (isDark
                          ? const Color(0xFF1E2340)
                          : AppColors.surfaceVariant),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: widget.isSelected
                      ? AppColors.primary
                      : AppColors.outline,
                  width: widget.isSelected ? 2 : 1,
                ),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.28),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: AppTextStyles.medium14.copyWith(
                  color: widget.isSelected
                      ? AppColors.onPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                child: Text(widget.label),
              ),
            ),
          );
        },
      ),
    );
  }
}
