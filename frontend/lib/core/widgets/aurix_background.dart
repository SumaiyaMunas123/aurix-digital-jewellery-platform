import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'aurix_noise_overlay.dart';

class AurixBackground extends StatelessWidget {
  final Widget child;
  const AurixBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Container(
          color: isDark ? AppColors.darkBg : AppColors.offWhite,
        ),
        Positioned(
          top: -140,
          left: -120,
          child: _blob(
            size: 320,
            color: AppColors.gold.withValues(alpha: isDark ? 0.18 : 0.10),
          ),
        ),
        Positioned(
          bottom: -170,
          right: -140,
          child: _blob(
            size: 360,
            color: AppColors.royalBlue.withValues(alpha: isDark ? 0.12 : 0.10),
          ),
        ),
        Positioned(
          top: 200,
          right: -100,
          child: _blob(
            size: 240,
            color: Colors.white.withValues(alpha: isDark ? 0.06 : 0.25),
          ),
        ),
        AurixNoiseOverlay(opacity: isDark ? 0.05 : 0.03),
        child,
      ],
    );
  }

  Widget _blob({required double size, required Color color}) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(width: size, height: size, color: color),
      ),
    );
  }
}