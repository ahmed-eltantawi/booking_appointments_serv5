import 'package:flutter/material.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';

/// Single key-value summary row in [BookingSummaryWidget] with value transitions.
class SummaryRowWidget extends StatelessWidget {
  const SummaryRowWidget({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.medium14.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.25),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Text(
            value,
            key: ValueKey<String>(value),
            style: AppTextStyles.semiBold18.copyWith(
              fontSize: 14,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
