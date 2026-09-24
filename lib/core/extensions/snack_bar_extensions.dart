import 'package:flutter/material.dart';
import 'package:booking_appointments/core/functions/show_snack_bar.dart';
import 'package:booking_appointments/core/utils/app_colors.dart';

/// Extensions on [BuildContext] for displaying semantic SnackBars.
extension SnackBarContextExtension on BuildContext {
  /// Displays a success SnackBar with [message].
  void showSuccessSnackBar(String message) {
    showSnackBar(
      context: this,
      message: message,
      backgroundColor: AppColors.success,
    );
  }

  /// Displays an error SnackBar with [message].
  void showErrorSnackBar(String message) {
    showSnackBar(
      context: this,
      message: message,
      backgroundColor: Theme.of(this).colorScheme.error,
    );
  }
}
