import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Gradient? borderGradient;
  final double borderWidth;
  final double blurSigma;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20.0,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderGradient,
    this.borderWidth = 1.0,
    this.blurSigma = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderGradient = borderGradient ?? AppColors.cardBorderGradient;
    final effectiveBg = backgroundColor ?? AppColors.surface.withValues(alpha: 0.82);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: effectiveBorderGradient,
      ),
      padding: EdgeInsets.all(borderWidth),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - borderWidth),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            color: effectiveBg,
            child: child,
          ),
        ),
      ),
    );
  }
}
