import 'package:flutter/material.dart';

/// Helper class for configuring animations used by SlotCellWidget.
abstract final class SlotCellAnimations {
  /// Duration of the shake animation controller (300ms).
  static const Duration shakeDuration = Duration(milliseconds: 300);

  /// Creates and configures the [AnimationController] for the shake effect.
  static AnimationController createShakeController(TickerProvider vsync) {
    return AnimationController(vsync: vsync, duration: shakeDuration);
  }

  /// Creates the shake [Animation<double>] with exact sequence and curves.
  static Animation<double> createShakeAnimation(
    AnimationController controller,
  ) {
    return TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: -4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }
}
