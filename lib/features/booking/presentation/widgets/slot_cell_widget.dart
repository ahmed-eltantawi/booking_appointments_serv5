import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/core/utils/app_colors.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';
import 'package:booking_appointments/features/booking/domain/slot_model.dart';

/// An individual time-slot cell in the booking grid.
///
/// Features:
///   • Press scale micro-interaction.
///   • Staggered range selection animation.
///   • Shake & error flash visual feedback on invalid slot taps.
///   • Contextual haptic feedback.
class SlotCellWidget extends StatefulWidget {
  const SlotCellWidget({
    super.key,
    required this.slot,
    required this.isValidStart,
    this.rangeOffset = 0,
    this.onTap,
  });

  final SlotModel slot;
  final bool isValidStart;

  /// Stagger index offset when part of a multi-slot selected range.
  final int rangeOffset;

  /// Callback invoked when the slot is tapped.
  final VoidCallback? onTap;

  @override
  State<SlotCellWidget> createState() => _SlotCellWidgetState();
}

class _SlotCellWidgetState extends State<SlotCellWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  late final ValueNotifier<bool> _isPressedNotifier;
  late final ValueNotifier<bool> _isErrorFlashingNotifier;
  late final ValueNotifier<bool> _isVisuallySelectedNotifier;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _isPressedNotifier = ValueNotifier<bool>(false);
    _isErrorFlashingNotifier = ValueNotifier<bool>(false);
    _isVisuallySelectedNotifier =
        ValueNotifier<bool>(widget.slot.status == SlotStatus.selected);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: -4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(SlotCellWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.slot.status == SlotStatus.selected &&
        oldWidget.slot.status != SlotStatus.selected) {
      _applyStaggeredSelection();
    } else if (widget.slot.status != SlotStatus.selected) {
      _isVisuallySelectedNotifier.value = false;
    } else {
      _isVisuallySelectedNotifier.value = true;
    }
  }

  void _applyStaggeredSelection() async {
    final delay = Duration(milliseconds: widget.rangeOffset * 40);
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }
    if (!_isDisposed && mounted && widget.slot.status == SlotStatus.selected) {
      _isVisuallySelectedNotifier.value = true;
    }
  }

  void _handleTapDown(TapDownDetails details) {
    _isPressedNotifier.value = true;
  }

  void _handleTapUp(TapUpDetails details) {
    _isPressedNotifier.value = false;
    _executeTapBehavior();
  }

  void _handleTapCancel() {
    _isPressedNotifier.value = false;
  }

  void _executeTapBehavior() {
    final isInteractiveAndValid =
        widget.slot.status == SlotStatus.available && widget.isValidStart;

    if (isInteractiveAndValid) {
      HapticFeedback.selectionClick();
    } else {
      HapticFeedback.mediumImpact();
      _triggerInvalidFeedback();
    }

    widget.onTap?.call();
  }

  void _triggerInvalidFeedback() {
    _shakeController.forward(from: 0.0);
    _isErrorFlashingNotifier.value = true;

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!_isDisposed && mounted) {
        _isErrorFlashingNotifier.value = false;
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _isPressedNotifier.dispose();
    _isErrorFlashingNotifier.dispose();
    _isVisuallySelectedNotifier.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAvailableButNotValid =
        widget.slot.status == SlotStatus.available && !widget.isValidStart;

    return ListenableBuilder(
      listenable: Listenable.merge([
        _shakeAnimation,
        _isPressedNotifier,
        _isErrorFlashingNotifier,
        _isVisuallySelectedNotifier,
      ]),
      builder: (context, child) {
        final isPressed = _isPressedNotifier.value;
        final isErrorFlashing = _isErrorFlashingNotifier.value;
        final isVisuallySelected = _isVisuallySelectedNotifier.value;

        final effectiveStatus =
            isVisuallySelected ? SlotStatus.selected : widget.slot.status;
        final (bgColor, fgColor) = _colorsForStatus(effectiveStatus, isDark);

        final scale = isPressed
            ? 0.94
            : (isVisuallySelected ? 1.02 : 1.0);

        return Transform.translate(
          offset: Offset(_shakeAnimation.value.w, 0),
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            behavior: HitTestBehavior.opaque,
            child: AnimatedScale(
              scale: scale,
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isAvailableButNotValid ? 0.45 : 1.0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: isErrorFlashing
                        ? Theme.of(context).colorScheme.error.withValues(alpha: 0.15)
                        : bgColor,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: isErrorFlashing
                          ? Theme.of(context).colorScheme.error
                          : (effectiveStatus == SlotStatus.selected
                              ? AppColors.primary
                              : AppColors.outline.withValues(alpha: isDark ? 0.3 : 1.0)),
                      width: (effectiveStatus == SlotStatus.selected || isErrorFlashing) ? 2 : 1,
                    ),
                    boxShadow: effectiveStatus == SlotStatus.selected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.28),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: AppTextStyles.medium12.copyWith(
                        color: isErrorFlashing
                            ? Theme.of(context).colorScheme.error
                            : fgColor,
                      ),
                      child: Text(
                        widget.slot.timeLabel,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  (Color, Color) _colorsForStatus(SlotStatus status, bool isDark) {
    return switch (status) {
      SlotStatus.available   => isDark
          ? (AppColors.slotAvailableBgDark, AppColors.slotAvailableFgDark)
          : (AppColors.slotAvailableBg, AppColors.slotAvailableFg),
      SlotStatus.booked      => isDark
          ? (AppColors.slotBookedBgDark, AppColors.slotBookedFgDark)
          : (AppColors.slotBookedBg, AppColors.slotBookedFg),
      SlotStatus.unavailable => isDark
          ? (AppColors.slotUnavailableBgDark, AppColors.slotUnavailableFgDark)
          : (AppColors.slotUnavailableBg, AppColors.slotUnavailableFg),
      SlotStatus.selected    => isDark
          ? (AppColors.slotSelectedBgDark, AppColors.slotSelectedFgDark)
          : (AppColors.slotSelectedBg, AppColors.slotSelectedFg),
    };
  }
}

