import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'login_screen.dart';

class JewellerPendingApprovalScreen extends StatelessWidget {
  const JewellerPendingApprovalScreen({super.key});

  void _contactSupport(BuildContext context) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Support flow coming soon.")),
    );
  }

  void _logout(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  Widget _blob({required double size, required Color color}) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: size,
          height: size,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0B0B0B) : const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -120,
              left: -100,
              child: _blob(
                size: 300,
                color:
                    const Color(0xFFD4AF37).withValues(alpha: isDark ? 0.18 : 0.14),
              ),
            ),
            Positioned(
              bottom: -140,
              right: -120,
              child: _blob(
                size: 320,
                color:
                    const Color(0xFFD4AF37).withValues(alpha: isDark ? 0.14 : 0.10),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: (isDark ? Colors.white : Colors.black)
                                .withValues(alpha: 0.10),
                          ),
                          color: (isDark ? Colors.white : Colors.black)
                              .withValues(alpha: isDark ? 0.06 : 0.045),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Icon(
                              Icons.verified_user_rounded,
                              size: 60,
                              color: Color(0xFFD4AF37),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              "Account Under Review",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Your jeweller account has been submitted successfully.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Our team is verifying your documents. This usually takes 24–48 hours.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 24),
                            GestureDetector(
                              onTap: () => _contactSupport(context),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  color: const Color(0xFFD4AF37),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Contact Support",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () => _logout(context),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: const Color(0xFFD4AF37),
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Back to Login",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
}