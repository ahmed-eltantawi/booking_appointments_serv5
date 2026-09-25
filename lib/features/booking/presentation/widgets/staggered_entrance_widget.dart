import 'package:flutter/material.dart';

/// Wraps a widget to provide a staggered fade and slide entrance animation.
///
/// The animation delay is determined by multiplying [index] by [delayStep].
class StaggeredEntranceWidget extends StatefulWidget {
  const StaggeredEntranceWidget({
    super.key,
    required this.index,
    required this.child,
    this.duration = const Duration(milliseconds: 350),
    this.delayStep = const Duration(milliseconds: 40),
    this.slideOffset = const Offset(0, 0.15),
  });

  final int index;
  final Widget child;
  final Duration duration;
  final Duration delayStep;
  final Offset slideOffset;

  @override
  State<StaggeredEntranceWidget> createState() =>
      _StaggeredEntranceWidgetState();
}

class _StaggeredEntranceWidgetState extends State<StaggeredEntranceWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curve);
    _slideAnimation = Tween<Offset>(
      begin: widget.slideOffset,
      end: Offset.zero,
    ).animate(curve);

    _startDelayedAnimation();
  }

  void _startDelayedAnimation() async {
    final delay = widget.delayStep * widget.index;
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }
    if (!_isDisposed && mounted) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
