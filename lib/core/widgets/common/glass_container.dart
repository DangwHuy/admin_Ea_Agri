import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final Color? color;

  final double? width;
  final double? height;
  final Duration duration;
  final Curve curve;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 24.0,
    this.opacity = 0.5,
    this.padding,
    this.margin,
    this.borderRadius,
    this.border,
    this.color,
    this.width,
    this.height,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutQuart,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBorderRadius = borderRadius ?? BorderRadius.circular(24.0);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: defaultBorderRadius,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.03),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: defaultBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: AnimatedContainer(
            duration: duration,
            curve: curve,
            padding: padding,
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: color ?? (isDark ? const Color(0x991E2538) : Colors.white.withValues(alpha: 0.35)),
              borderRadius: defaultBorderRadius,
              border: border ?? Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.6), 
                width: 0.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
