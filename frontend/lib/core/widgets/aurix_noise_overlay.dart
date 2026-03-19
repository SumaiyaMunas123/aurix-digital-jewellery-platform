import 'dart:math' as math;
import 'package:flutter/material.dart';

class AurixNoiseOverlay extends StatelessWidget {
  final double opacity;
  const AurixNoiseOverlay({super.key, this.opacity = 0.035});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _NoisePainter(opacity: opacity),
        size: Size.infinite,
      ),
    );
  }
}

class _NoisePainter extends CustomPainter {
  final double opacity;
  _NoisePainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final rand = math.Random(7);
    final paint = Paint()..color = Colors.white.withOpacity(opacity);

    for (int i = 0; i < 900; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      canvas.drawRect(Rect.fromLTWH(x, y, 1, 1), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NoisePainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}