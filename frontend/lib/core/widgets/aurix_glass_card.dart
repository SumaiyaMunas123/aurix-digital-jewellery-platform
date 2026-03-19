import 'dart:ui';
import 'package:flutter/material.dart';

class AurixGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;

  const AurixGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 22,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: (isDark ? Colors.white : Colors.black)
                .withValues(alpha: isDark ? 0.06 : 0.04),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.10),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}