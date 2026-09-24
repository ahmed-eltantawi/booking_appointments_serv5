import 'package:flutter/material.dart';

///* Top-level function to display a single, non-duplicating SnackBar.
///* Clears any currently visible or queued SnackBars before displaying [message]
///* to prevent stacking and duplicate queued SnackBars from rapid user actions.
void showSnackBar({
  required BuildContext context,
  required String message,
  Color? backgroundColor,
  Duration duration = const Duration(seconds: 3),
  SnackBarAction? action,
}) {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  scaffoldMessenger.clearSnackBars();
  scaffoldMessenger.showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      duration: duration,
      action: action,
    ),
  );
}
