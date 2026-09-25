import 'dart:async';
import 'package:flutter/material.dart';

/// Wraps a widget to provide a smooth fade and slide entrance animation.
///
/// The animation delay can be specified directly via [delay] or computed
/// using [initialDelay] + ([index] * [delayStep]).
class StaggeredEntranceWidget extends StatefulWidget {
  const StaggeredEntranceWidget({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = const Duration(milliseconds: 450),
    this.delayStep = const Duration(milliseconds: 50),
    this.slideOffset = const Offset(0, 0.15),
    this.initialDelay = Duration.zero,
    this.delay,
  });

  final Widget child;
  final int index;
  final Duration duration;
  final Duration delayStep;
  final Offset slideOffset;
  final Duration initialDelay;
  final Duration? delay;

  @override
  State<StaggeredEntranceWidget> createState() =>
      _StaggeredEntranceWidgetState();
}

class _StaggeredEntranceWidgetState extends State<StaggeredEntranceWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  Timer? _timer;
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

    _scheduleEntranceAnimation();
  }

  void _scheduleEntranceAnimation() {
    final effectiveDelay =
        widget.delay ?? (widget.initialDelay + (widget.delayStep * widget.index));

    if (effectiveDelay == Duration.zero) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed && mounted && _controller.status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });
    } else {
      _timer = Timer(effectiveDelay, () {
        if (!_isDisposed && mounted && _controller.status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void didUpdateWidget(StaggeredEntranceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.status == AnimationStatus.completed || _controller.value >= 1.0) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
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


