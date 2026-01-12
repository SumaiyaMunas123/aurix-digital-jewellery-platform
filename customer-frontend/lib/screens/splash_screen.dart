import 'dart:async';
import 'package:aurix_app/screens/auth_screen.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Center logo
            Center(
              child: Image.asset(
                'assets/images/aurix_logo.png',
                width: 140,
              ),
            ),

            // Bottom animated dots
            Positioned(
              left: 0,
              right: 0,
              bottom: 32,
              child: Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final t = _controller.value;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Dot(opacity: _pulse(t, 0.0)),
                        const SizedBox(width: 8),
                        _Dot(opacity: _pulse(t, 0.2)),
                        const SizedBox(width: 8),
                        _Dot(opacity: _pulse(t, 0.4)),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _pulse(double t, double delay) {
    final x = (t + delay) % 1.0;
    final triangle = x < 0.5 ? (x * 2) : (2 - x * 2);
    return 0.25 + (triangle * 0.75);
  }
}

class _Dot extends StatelessWidget {
  final double opacity;
  const _Dot({required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: const Color(0xFFD4AF37), // Aurix gold
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }
}
