import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Interactive menu button for the AppBar with a subtle press micro-interaction.
class AnimatedDrawerButton extends StatefulWidget {
  const AnimatedDrawerButton({super.key});

  @override
  State<AnimatedDrawerButton> createState() => _AnimatedDrawerButtonState();
}

class _AnimatedDrawerButtonState extends State<AnimatedDrawerButton> {
  final ValueNotifier<bool> _isPressedNotifier = ValueNotifier<bool>(false);

  void _onTapDown(TapDownDetails details) {
    _isPressedNotifier.value = true;
  }

  void _onTapUp(TapUpDetails details) {
    _isPressedNotifier.value = false;
    HapticFeedback.selectionClick();
    Scaffold.of(context).openDrawer();
  }

  void _onTapCancel() {
    _isPressedNotifier.value = false;
  }

  @override
  void dispose() {
    _isPressedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ValueListenableBuilder<bool>(
        valueListenable: _isPressedNotifier,
        builder: (context, isPressed, child) {
          return AnimatedScale(
            scale: isPressed ? 0.90 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeInOut,
            child: child,
          );
        },
        child: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () {
            HapticFeedback.selectionClick();
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
    );
  }
}
