import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/auth_repository.dart';
import '../models/user.dart';
import '../../customer/customer_shell/customer_shell_screen.dart';
import '../../jeweller/shell/jeweller_app_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifier = TextEditingController();
  final _pw = TextEditingController();

  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _identifier.dispose();
    _pw.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    HapticFeedback.lightImpact();
    setState(() => _loading = true);
    try {
      final repo = context.read<AuthRepository>();
      final user = await repo.login(_identifier.text.trim(), _pw.text);

      if (!mounted) return;
      final next = user.role == UserRole.jeweller
          ? const JewellerAppShell()
          : const CustomerShellScreen();

      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => next));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0B0B) : const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -140,
              left: -120,
              child: _blob(
                size: 320,
                color: const Color(0xFFD4AF37).withOpacity(isDark ? 0.18 : 0.10),
              ),
            ),
            Positioned(
              bottom: -170,
              right: -140,
              child: _blob(
                size: 360,
                color: Colors.blue.withOpacity(isDark ? 0.10 : 0.10),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: _glassCard(
                    context,
                    child: Column(
                      children: [
                        Image.asset("assets/images/aurix_logo.png", width: 140),
                        const SizedBox(height: 18),

                        _field(
                          context,
                          controller: _identifier,
                          hint: "Mobile number or email address",
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 12),
                        _field(
                          context,
                          controller: _pw,
                          hint: "Password",
                          icon: Icons.lock_outline_rounded,
                          obscure: _obscure,
                          suffix: IconButton(
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              setState(() => _obscure = !_obscure);
                            },
                            icon: Icon(_obscure
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded),
                          ),
                        ),
                        const SizedBox(height: 14),

                        _primaryButton(
                          text: "Login",
                          loading: _loading,
                          onTap: _loading ? null : _login,
                        ),

                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => HapticFeedback.selectionClick(),
                          child: const Text(
                            "Forgotten password?",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.black.withOpacity(isDark ? 0.25 : 0.10))),
                            const SizedBox(width: 10),
                            Text(
                              "or continue with",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Divider(color: Colors.black.withOpacity(isDark ? 0.25 : 0.10))),
                          ],
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: _socialButton(
                                context,
                                asset: "assets/images/google_logo.png",
                                label: "Google",
                                onTap: () => HapticFeedback.lightImpact(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _socialButton(
                                context,
                                asset: "assets/images/apple_logo.png",
                                label: "Apple",
                                onTap: () => HapticFeedback.lightImpact(),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => HapticFeedback.selectionClick(),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontWeight: FontWeight.w700,
                              ),
                              children: const [
                                TextSpan(text: "New to Aurix? "),
                                TextSpan(
                                  text: "Create new account",
                                  style: TextStyle(
                                    color: Color(0xFFD4AF37),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blob({required double size, required Color color}) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
        child: Container(width: size, height: size, color: color),
      ),
    );
  }

  Widget _glassCard(BuildContext context, {required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.10),
            ),
            color: (isDark ? Colors.white : Colors.black)
                .withOpacity(isDark ? 0.06 : 0.04),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _field(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.10),
            ),
            color: (isDark ? Colors.white : Colors.black)
                .withOpacity(isDark ? 0.05 : 0.04),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              prefixIcon: Icon(icon, size: 20),
              suffixIcon: suffix,
            ),
          ),
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String text,
    required bool loading,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          color: const Color(0xFFD4AF37),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                  )
                : Text(text, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
          ),
        ),
      ),
    );
  }

  Widget _socialButton(
    BuildContext context, {
    required String asset,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.10),
              ),
              color: (isDark ? Colors.white : Colors.black)
                  .withOpacity(isDark ? 0.05 : 0.04),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(asset, width: 18, height: 18),
                const SizedBox(width: 10),
                Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}