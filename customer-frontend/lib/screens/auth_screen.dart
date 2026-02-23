import 'package:flutter/material.dart';
import 'login_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  static const Color gold = Color(0xFFD4AF37);
  static const Color card = Color(0xFF141414);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 34),

                  // Logo
                  Center(
                    child: Image.asset(
                      'assets/images/aurix_logo.png',
                      width: 120,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // App Name
                  const Center(
                    child: Text(
                      'Aurix',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Tagline (optional, clean)
                  Center(
                    child: Text(
                      'Buy with trust. Sell with proof.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Login button
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gold,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Sign up button (placeholder)
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sign up screen will be added next')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.25)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                      child: const Text(
                        'Sign up',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white.withOpacity(0.15))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'or continue with',
                          style: TextStyle(color: Colors.white.withOpacity(0.65)),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.white.withOpacity(0.15))),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Circular social buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SocialCircleButton(
                        icon: Icons.g_mobiledata, // placeholder for Google logo
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Google sign-in – later')),
                          );
                        },
                      ),
                      const SizedBox(width: 24),
                      _SocialCircleButton(
                        icon: Icons.apple,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Apple sign-in – later')),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _SocialCircleButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFD4AF37), 
            width: 1.2,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
