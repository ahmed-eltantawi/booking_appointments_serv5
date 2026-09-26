import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/core/utils/app_colors.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';
import 'package:booking_appointments/features/booking/presentation/manager/booking_cubit.dart';

/// Bottom action bar with Reset and Confirm Booking buttons.
/// Includes press micro-interactions, haptics, and success state transitions.
class BookingActionBarWidget extends StatefulWidget {
  const BookingActionBarWidget({
    super.key,
    required this.canConfirm,
    this.isConfirmed = false,
  });

  /// True when a start time is selected and the booking is currently valid.
  final bool canConfirm;

  /// True when the current schedule has been confirmed successfully.
  final bool isConfirmed;

  @override
  State<BookingActionBarWidget> createState() => _BookingActionBarWidgetState();
}

class _BookingActionBarWidgetState extends State<BookingActionBarWidget> {
  final ValueNotifier<bool> _isResetPressedNotifier = ValueNotifier<bool>(
    false,
  );
  final ValueNotifier<bool> _isConfirmPressedNotifier = ValueNotifier<bool>(
    false,
  );

  void _onResetTapDown(TapDownDetails details) {
    _isResetPressedNotifier.value = true;
  }

  void _onResetTapUp(TapUpDetails details) {
    _isResetPressedNotifier.value = false;
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).clearSnackBars();
    context.read<BookingCubit>().reset();
  }

  void _onResetTapCancel() {
    _isResetPressedNotifier.value = false;
  }

  void _onConfirmTapDown(TapDownDetails details) {
    if (widget.canConfirm && !widget.isConfirmed) {
      _isConfirmPressedNotifier.value = true;
    }
  }

  void _onConfirmTapUp(TapUpDetails details) {
    if (widget.canConfirm && !widget.isConfirmed) {
      _isConfirmPressedNotifier.value = false;
      HapticFeedback.mediumImpact();
      context.read<BookingCubit>().confirmBooking();
    }
  }

  void _onConfirmTapCancel() {
    _isConfirmPressedNotifier.value = false;
  }

  @override
  void dispose() {
    _isResetPressedNotifier.dispose();
    _isConfirmPressedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Row(
      children: [
        // --- Reset Button ---
        Expanded(
          child: GestureDetector(
            onTapDown: _onResetTapDown,
            onTapUp: _onResetTapUp,
            onTapCancel: _onResetTapCancel,
            child: ValueListenableBuilder<bool>(
              valueListenable: _isResetPressedNotifier,
              builder: (context, isResetPressed, child) {
                return AnimatedScale(
                  scale: isResetPressed ? 0.95 : 1.0,
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOutCubic,
                  child: child,
                );
              },
              child: OutlinedButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  ScaffoldMessenger.of(context).clearSnackBars();
                  context.read<BookingCubit>().reset();
                },
                child: Text(l10n.reset),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),

        // --- Confirm / Confirmed Button ---
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTapDown: _onConfirmTapDown,
            onTapUp: _onConfirmTapUp,
            onTapCancel: _onConfirmTapCancel,
            child: ValueListenableBuilder<bool>(
              valueListenable: _isConfirmPressedNotifier,
              builder: (context, isConfirmPressed, child) {
                return AnimatedScale(
                  scale: isConfirmPressed ? 0.96 : 1.0,
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOutCubic,
                  child: child,
                );
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: widget.isConfirmed
                    ? Container(
                        key: const ValueKey('confirmed_button'),
                        height: 48.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.onPrimary,
                              size: 18.r,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '✓ ${l10n.selected}',
                              style: AppTextStyles.bold14.copyWith(
                                color: AppColors.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ElevatedButton(
                        key: const ValueKey('confirm_button'),
                        onPressed: widget.canConfirm
                            ? () {
                                HapticFeedback.mediumImpact();
                                context.read<BookingCubit>().confirmBooking();
                              }
                            : null,
                        child: Text(l10n.confirmBooking),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
