import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/core/utils/app_colors.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';
import 'package:booking_appointments/features/booking/domain/Entities/time_slot.dart';

/// An individual time-slot cell in the booking grid.
///
/// Implements domain-presentation separation (ISSUE-005) and full accessibility (ISSUE-012):
///   • Preserves original domain status (available, booked, unavailable).
///   • Renders selection overlays without hiding booked/unavailable identity.
///   • Displays non-color indicators (status icons: lock, block, checkmark, warning).
///   • Provides Semantics, 48dp+ touch target, InkWell ripple, and haptic feedback.
class SlotCellWidget extends StatefulWidget {
  const SlotCellWidget({
    super.key,
    required this.slot,
    required this.isValidStart,
    this.isSelected = false,
    this.isInvalidSelection = false,
    this.rangeOffset = 0,
    this.onTap,
  });

  final TimeSlot slot;
  final bool isValidStart;
  final bool isSelected;
  final bool isInvalidSelection;
  final int rangeOffset;
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
    _isVisuallySelectedNotifier = ValueNotifier<bool>(widget.isSelected);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _shakeAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: -6.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 6.0, end: -4.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -4.0, end: 4.0), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 4.0, end: 0.0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
        );
  }

  @override
  void didUpdateWidget(SlotCellWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _applyStaggeredSelection();
    } else if (!widget.isSelected) {
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
    if (!_isDisposed && mounted && widget.isSelected) {
      _isVisuallySelectedNotifier.value = true;
    }
  }

  void _executeTapBehavior() {
    final isBookedOrUnavailable =
        widget.slot.status == SlotStatus.booked ||
        widget.slot.status == SlotStatus.myBooking ||
        widget.slot.status == SlotStatus.unavailable;

    final isInvalidAvailableStart =
        widget.slot.status == SlotStatus.available && !widget.isValidStart;

    final isInvalid = isBookedOrUnavailable || isInvalidAvailableStart;

    if (isInvalid) {
      HapticFeedback.mediumImpact();
      _triggerInvalidFeedback();
    } else {
      HapticFeedback.selectionClick();
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
    final l10n = S.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    final isAvailableButNotValid =
        widget.slot.status == SlotStatus.available && !widget.isValidStart;

    final formattedTime = widget.slot.start.format(context);

    // Domain status label
    final statusLabel = switch (widget.slot.status) {
      SlotStatus.available => l10n.available,
      SlotStatus.myBooking => l10n.myBooking,
      SlotStatus.booked => l10n.booked,
      SlotStatus.unavailable => l10n.unavailable,
    };

    final selectionLabel = widget.isSelected
        ? (widget.isInvalidSelection
              ? ', invalid selection'
              : ', ${l10n.selected}')
        : '';

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

        final (bgColor, fgColor) = _colorsForStatus(
          status: widget.slot.status,
          isSelected: isVisuallySelected,
          isInvalidSelection: widget.isInvalidSelection,
          isDark: isDark,
          colorScheme: colorScheme,
        );

        final IconData? statusIcon = _iconForStatus(
          status: widget.slot.status,
          isSelected: isVisuallySelected,
          isInvalidSelection: widget.isInvalidSelection,
        );

        final scale = isPressed ? 0.94 : (isVisuallySelected ? 1.02 : 1.0);

        final borderColor = (widget.isInvalidSelection || isErrorFlashing)
            ? colorScheme.error
            : (isVisuallySelected
                  ? AppColors.primary
                  : AppColors.outline.withValues(alpha: isDark ? 0.3 : 1.0));

        final borderWidth =
            (isVisuallySelected || widget.isInvalidSelection || isErrorFlashing)
            ? 2.0
            : 1.0;

        return Semantics(
          button: true,
          enabled: widget.slot.status == SlotStatus.available,
          selected: isVisuallySelected,
          label: '$formattedTime, $statusLabel$selectionLabel',
          child: Transform.translate(
            offset: Offset(_shakeAnimation.value.w, 0),
            child: AnimatedScale(
              scale: scale,
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: (isAvailableButNotValid && !isVisuallySelected)
                    ? 0.45
                    : 1.0,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _executeTapBehavior,
                    onHighlightChanged: (highlighted) {
                      _isPressedNotifier.value = highlighted;
                    },
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      constraints: BoxConstraints(
                        minHeight: 48.h,
                        minWidth: 48.w,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isErrorFlashing
                            ? colorScheme.error.withValues(alpha: 0.15)
                            : bgColor,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: borderColor,
                          width: borderWidth,
                        ),
                        boxShadow:
                            (isVisuallySelected && !widget.isInvalidSelection)
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.28,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (statusIcon != null) ...[
                            Icon(
                              statusIcon,
                              size: 14.r,
                              color: isErrorFlashing
                                  ? colorScheme.error
                                  : fgColor,
                            ),
                            SizedBox(width: 4.w),
                          ],
                          Flexible(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: AppTextStyles.medium12.copyWith(
                                color: isErrorFlashing
                                    ? colorScheme.error
                                    : fgColor,
                              ),
                              child: Text(
                                formattedTime,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
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

  (Color, Color) _colorsForStatus({
    required SlotStatus status,
    required bool isSelected,
    required bool isInvalidSelection,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    if (isSelected && !isInvalidSelection) {
      return isDark
          ? (AppColors.slotSelectedBgDark, AppColors.slotSelectedFgDark)
          : (AppColors.slotSelectedBg, AppColors.slotSelectedFg);
    }

    if (isSelected && isInvalidSelection) {
      switch (status) {
        case SlotStatus.myBooking:
          final baseBg = isDark
              ? AppColors.slotMyBookingBgDark
              : AppColors.slotMyBookingBg;
          final baseFg = isDark
              ? AppColors.slotMyBookingFgDark
              : AppColors.slotMyBookingFg;
          return (
            Color.alphaBlend(colorScheme.error.withValues(alpha: 0.2), baseBg),
            baseFg,
          );
        case SlotStatus.booked:
          final baseBg = isDark
              ? AppColors.slotBookedBgDark
              : AppColors.slotBookedBg;
          final baseFg = isDark
              ? AppColors.slotBookedFgDark
              : AppColors.slotBookedFg;
          return (
            Color.alphaBlend(colorScheme.error.withValues(alpha: 0.2), baseBg),
            baseFg,
          );
        case SlotStatus.unavailable:
          final baseBg = isDark
              ? AppColors.slotUnavailableBgDark
              : AppColors.slotUnavailableBg;
          final baseFg = isDark
              ? AppColors.slotUnavailableFgDark
              : AppColors.slotUnavailableFg;
          return (
            Color.alphaBlend(colorScheme.error.withValues(alpha: 0.2), baseBg),
            baseFg,
          );
        case SlotStatus.available:
          return (colorScheme.error.withValues(alpha: 0.12), colorScheme.error);
      }
    }

    return switch (status) {
      SlotStatus.available =>
        isDark
            ? (AppColors.slotAvailableBgDark, AppColors.slotAvailableFgDark)
            : (AppColors.slotAvailableBg, AppColors.slotAvailableFg),
      SlotStatus.myBooking =>
        isDark
            ? (AppColors.slotMyBookingBgDark, AppColors.slotMyBookingFgDark)
            : (AppColors.slotMyBookingBg, AppColors.slotMyBookingFg),
      SlotStatus.booked =>
        isDark
            ? (AppColors.slotBookedBgDark, AppColors.slotBookedFgDark)
            : (AppColors.slotBookedBg, AppColors.slotBookedFg),
      SlotStatus.unavailable =>
        isDark
            ? (AppColors.slotUnavailableBgDark, AppColors.slotUnavailableFgDark)
            : (AppColors.slotUnavailableBg, AppColors.slotUnavailableFg),
    };
  }

  IconData? _iconForStatus({
    required SlotStatus status,
    required bool isSelected,
    required bool isInvalidSelection,
  }) {
    if (isSelected && !isInvalidSelection) {
      return Icons.check_circle_rounded;
    }
    if (isSelected && isInvalidSelection) {
      switch (status) {
        case SlotStatus.myBooking:
          return Icons.person_rounded;
        case SlotStatus.booked:
          return Icons.lock_clock_rounded;
        case SlotStatus.unavailable:
          return Icons.block_rounded;
        case SlotStatus.available:
          return Icons.warning_amber_rounded;
      }
    }
    return switch (status) {
      SlotStatus.available => null,
      SlotStatus.myBooking => Icons.person_rounded,
      SlotStatus.booked => Icons.lock_clock_rounded,
      SlotStatus.unavailable => Icons.block_rounded,
    };
  }
}
