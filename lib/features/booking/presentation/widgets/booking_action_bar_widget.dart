import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/core/utils/app_colors.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';
import 'package:booking_appointments/features/booking/presentation/manager/booking_cubit.dart';

//==============================================================================
/// Bottom action bar with Reset and Confirm Booking buttons.
/// Includes press micro-interactions, haptics, and success state transitions.
//==============================================================================
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
  // ValueNotifiers to track if the buttons are currently being pressed down
  final ValueNotifier<bool> _isResetPressedNotifier = ValueNotifier<bool>(
    false,
  );
  final ValueNotifier<bool> _isConfirmPressedNotifier = ValueNotifier<bool>(
    false,
  );

  //==============================================================================
  // Reset Button Handlers
  //==============================================================================
  void _onResetTapDown(TapDownDetails details) {
    // scale the button down when user holds it
    _isResetPressedNotifier.value = true;
  }

  void _onResetTapUp(TapUpDetails details) {
    // scale the button back up
    _isResetPressedNotifier.value = false;
    // give a subtle click feedback
    HapticFeedback.selectionClick();
    
    // clear any existing error snackbars so they don't persist after a reset
    ScaffoldMessenger.of(context).clearSnackBars();
    
    // tell the cubit to reset the schedule
    context.read<BookingCubit>().reset();
  }

  void _onResetTapCancel() {
    // handle case where user drags their finger off the button
    _isResetPressedNotifier.value = false;
  }

  //==============================================================================
  // Confirm Button Handlers
  //==============================================================================
  void _onConfirmTapDown(TapDownDetails details) {
    // only trigger the animation if the button is enabled and not already confirmed
    if (widget.canConfirm && !widget.isConfirmed) {
      _isConfirmPressedNotifier.value = true;
    }
  }

  void _onConfirmTapUp(TapUpDetails details) {
    if (widget.canConfirm && !widget.isConfirmed) {
      _isConfirmPressedNotifier.value = false;
      
      // give a stronger haptic feedback for the primary action
      HapticFeedback.mediumImpact();
      
      // tell the cubit to confirm the booking
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
        //==============================================================================
        // 1. Reset Button
        //==============================================================================
        Expanded(
          child: GestureDetector(
            onTapDown: _onResetTapDown,
            onTapUp: _onResetTapUp,
            onTapCancel: _onResetTapCancel,
            child: ValueListenableBuilder<bool>(
              valueListenable: _isResetPressedNotifier,
              builder: (context, isResetPressed, child) {
                // animated scale effect to make the button feel alive
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

        //==============================================================================
        // 2. Confirm / Confirmed Button
        //==============================================================================
        Expanded(
          // give the confirm button more space (flex 2 vs flex 1 for reset)
          flex: 2,
          child: GestureDetector(
            onTapDown: _onConfirmTapDown,
            onTapUp: _onConfirmTapUp,
            onTapCancel: _onConfirmTapCancel,
            child: ValueListenableBuilder<bool>(
              valueListenable: _isConfirmPressedNotifier,
              builder: (context, isConfirmPressed, child) {
                // animated scale effect
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
                  // cross-fade and scale transition when switching from confirm to confirmed
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                
                // if it's confirmed, show a green success box
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
                    // else show the standard elevated button
                    : ElevatedButton(
                        key: const ValueKey('confirm_button'),
                        onPressed: widget.canConfirm
                            ? () {
                                HapticFeedback.mediumImpact();
                                context.read<BookingCubit>().confirmBooking();
                              }
                            : null, // null disables the button natively
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
