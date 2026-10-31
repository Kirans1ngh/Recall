import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class BreathingHalo extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double maxBlur;
  final double maxSpread;
  final bool animate;

  const BreathingHalo({
    super.key,
    required this.child,
    this.glowColor = AppColors.cyan,
    this.maxBlur = 12.0,
    this.maxSpread = 3.0,
    this.animate = true,
  });

  @override
  State<BreathingHalo> createState() => _BreathingHaloState();
}

class _BreathingHaloState extends State<BreathingHalo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(BreathingHalo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.value = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final progress = _animation.value;
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(alpha: 0.25 + (progress * 0.4)),
                blurRadius: widget.maxBlur * (0.5 + progress * 0.5),
                spreadRadius: widget.maxSpread * progress,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
