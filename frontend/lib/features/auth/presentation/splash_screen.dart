import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/auth_repository.dart';
import '../models/user.dart';
import 'login_screen.dart';

import '../../customer/customer_shell/customer_shell_screen.dart';
import '../../jeweller/shell/jeweller_app_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();

    Future.delayed(const Duration(milliseconds: 900), () async {
      final repo = context.read<AuthRepository>();
      final user = await repo.getSavedUser();
      if (!mounted) return;

      final next = user == null
          ? const LoginScreen()
          : (user.role == UserRole.jeweller
              ? const JewellerAppShell()
              : const CustomerShellScreen());

      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => next));
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _pulse(double t, double delay) {
    final x = (t + delay) % 1.0;
    final v = x < 0.5 ? (x / 0.5) : (1 - (x - 0.5) / 0.5);
    return 0.75 + (v * 0.45);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              "assets/images/aurix_logo.png",
              width: 260,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            bottom: 52,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, __) {
                final t = _c.value;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _dot(_pulse(t, 0.0)),
                    const SizedBox(width: 8),
                    _dot(_pulse(t, 0.2)),
                    const SizedBox(width: 8),
                    _dot(_pulse(t, 0.4)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(double s) {
    return Transform.scale(
      scale: s,
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: Color(0xFFD4AF37),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}