import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/auth_repository.dart';
import '../data/google_auth_service.dart';
import '../models/user.dart';

import '../../customer/customer_shell/customer_shell_screen.dart';
import '../../jeweller/shell/jeweller_app_shell.dart';

import 'forgot_password_screen.dart';
import 'create_account_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifier = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  bool _googleLoading = false;
  bool _obscure = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    GoogleAuthService.initialize();
  }

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  bool _looksLikeEmail(String value) {
    final email = value.trim();
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  bool _looksLikeMobile(String value) {
    final mobile = value.replaceAll(RegExp(r'[^0-9]'), '');
    return mobile.length >= 9 && mobile.length <= 12;
  }

  Future<void> _login() async {
    HapticFeedback.lightImpact();

    final identifier = _identifier.text.trim();
    final password = _password.text;

    if (identifier.isEmpty) {
      setState(() => _error = "Enter your mobile or email.");
      return;
    }

    if (!_looksLikeEmail(identifier) && !_looksLikeMobile(identifier)) {
      setState(() => _error = "Enter a valid mobile number or email.");
      return;
    }

    if (password.trim().isEmpty) {
      setState(() => _error = "Enter your password.");
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final repo = context.read<AuthRepository>();
      final user = await repo.login(identifier, password);

      if (!mounted) return;

      final next = user.role == UserRole.jeweller
          ? const JewellerAppShell()
          : const CustomerShellScreen();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => next),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = "Invalid login credentials";
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleLogin() async {
    HapticFeedback.mediumImpact();

    setState(() {
      _googleLoading = true;
      _error = null;
    });

    try {
      final account = await GoogleAuthService.signIn();

      if (!mounted) return;

      if (account == null) {
        setState(() {
          _error = "Google sign-in was cancelled.";
        });
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const CustomerShellScreen(),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = "Google sign-in failed.";
      });
    } finally {
      if (mounted) {
        setState(() => _googleLoading = false);
      }
    }
  }

  void _forgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ForgotPasswordScreen(),
      ),
    );
  }

  void _createAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateAccountScreen(),
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.10),
            ),
            color: (isDark ? Colors.white : Colors.black)
                .withOpacity(isDark ? 0.06 : 0.045),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        onChanged: (_) {
          if (_error != null) {
            setState(() => _error = null);
          }
        },
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          suffixIcon: suffix,
        ),
      ),
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
    final identifier = _identifier.text.trim();

    String? helper;
    Color? helperColor;

    if (identifier.isNotEmpty) {
      if (_looksLikeEmail(identifier) || _looksLikeMobile(identifier)) {
        helper = "Valid input";
        helperColor = Colors.green;
      } else {
        helper = "Enter a valid mobile number or email";
        helperColor = Colors.redAccent;
      }
    }

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
                size: 320,
                color: const Color(0xFFD4AF37).withOpacity(0.15),
              ),
            ),
            Positioned(
              bottom: -160,
              right: -140,
              child: _blob(
                size: 360,
                color: const Color(0xFFD4AF37).withOpacity(0.12),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/images/aurix_logo.png",
                        width: 160,
                      ),
                      const SizedBox(height: 16),
                      _glassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              "Welcome back",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _textField(
                              controller: _identifier,
                              hint: "Mobile or Email",
                              keyboardType: TextInputType.emailAddress,
                            ),
                            if (helper != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                helper,
                                style: TextStyle(
                                  color: helperColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            _textField(
                              controller: _password,
                              hint: "Password",
                              obscure: _obscure,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() => _obscure = !_obscure);
                                },
                              ),
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                _error!,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: _loading ? null : _login,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  color: const Color(0xFFD4AF37),
                                ),
                                child: Center(
                                  child: _loading
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.black,
                                          ),
                                        )
                                      : const Text(
                                          "Login",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.center,
                              child: GestureDetector(
                                onTap: _forgotPassword,
                                child: const Text(
                                  "Forgot password?",
                                  style: TextStyle(
                                    color: Color(0xFFD4AF37),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Expanded(child: Divider()),
                                const SizedBox(width: 10),
                                Text(
                                  "or continue with",
                                  style: TextStyle(
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 14),
                            GestureDetector(
                              onTap: _googleLoading ? null : _googleLogin,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: const Color(0xFFD4AF37),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_googleLoading)
                                      const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    else ...[
                                      Image.asset(
                                        "assets/images/google_logo.png",
                                        width: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        "Continue with Google",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Center(
                              child: GestureDetector(
                                onTap: _createAccount,
                                child: const Text.rich(
                                  TextSpan(
                                    text: "New to Aurix? ",
                                    children: [
                                      TextSpan(
                                        text: "Create Account",
                                        style: TextStyle(
                                          color: Color(0xFFD4AF37),
                                          fontWeight: FontWeight.w900,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}