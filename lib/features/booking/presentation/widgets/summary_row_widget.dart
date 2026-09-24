import 'package:flutter/material.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';

/// Single key-value summary row in [BookingSummaryWidget].
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
        Text(
          value,
          style: AppTextStyles.semiBold18.copyWith(
            fontSize: 14,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
