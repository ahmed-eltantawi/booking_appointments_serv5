import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/core/utils/app_colors.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';
import 'package:booking_appointments/features/booking/domain/Entities/time_slot.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/slot_cell/slot_cell_animations.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/slot_cell/slot_cell_style.dart';

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

  // this variable is used to apply staggered selection animation
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

    _shakeController = SlotCellAnimations.createShakeController(this);
    _shakeAnimation = SlotCellAnimations.createShakeAnimation(_shakeController);
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

  /// Handle tap behavior
  void _executeTapBehavior() {
    // check if slot is booked or unavailable
    final isBookedOrUnavailable =
        widget.slot.status == SlotStatus.booked ||
        widget.slot.status == SlotStatus.myBooking ||
        widget.slot.status == SlotStatus.unavailable;

    // check if slot is available but not valid because the duration
    final isInvalidAvailableStart =
        widget.slot.status == SlotStatus.available && !widget.isValidStart;

    //* check if slot is invalid
    final isInvalid = isBookedOrUnavailable || isInvalidAvailableStart;

    if (isInvalid) {
      HapticFeedback.mediumImpact(); //vibration
      _triggerInvalidFeedback(); //shake
    } else {
      HapticFeedback.selectionClick();
    }

    // call the onTap callback if provided
    widget.onTap?.call();
  }

  ///* Trigger invalid feedback (shake effect)
  void _triggerInvalidFeedback() {
    _shakeController.forward(from: 0.0);
    _isErrorFlashingNotifier.value = true;

    // reset the animation after 400ms
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

    // Selection label for accessibility
    final selectionLabel = widget.isSelected
        ? (widget.isInvalidSelection
              ? ', invalid selection'
              : ', ${l10n.selected}')
        : '';

    // ListenableBuilder is used to listen to changes in the widget's properties
    return ListenableBuilder(
      listenable: Listenable.merge([
        _shakeAnimation,
        _isPressedNotifier,
        _isErrorFlashingNotifier,
        _isVisuallySelectedNotifier,
      ]),
      builder: (context, child) {
        // Get the current value of the listenable
        final isPressed = _isPressedNotifier.value;
        final isErrorFlashing = _isErrorFlashingNotifier.value;
        final isVisuallySelected = _isVisuallySelectedNotifier.value;

        // get colors for status
        final (bgColor, fgColor) = SlotCellStyle.colorsForStatus(
          status: widget.slot.status,
          isSelected: isVisuallySelected,
          isInvalidSelection: widget.isInvalidSelection,
          isDark: isDark,
          colorScheme: colorScheme,
        );

        final IconData? statusIcon = SlotCellStyle.iconForStatus(
          status: widget.slot.status,
          isSelected: isVisuallySelected,
          isInvalidSelection: widget.isInvalidSelection,
        );

        // change the scale of the time slot based on state
        final scale = isPressed ? 0.94 : (isVisuallySelected ? 1.02 : 1.0);

        // border color and width
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
}
