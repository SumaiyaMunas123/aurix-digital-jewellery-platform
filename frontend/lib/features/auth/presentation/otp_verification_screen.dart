import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String contact;

  const OtpVerificationScreen({
    super.key,
    required this.contact,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  bool _verifying = false;
  int _secondsLeft = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 30);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _otp => _controllers.map((e) => e.text).join();

  void _onOtpChanged(int index, String value) {
    if (value.length > 1) {
      _controllers[index].text = value.substring(value.length - 1);
      _controllers[index].selection = const TextSelection.collapsed(offset: 1);
    }

    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    if (_otp.length == 6) {
      HapticFeedback.selectionClick();
    }

    setState(() {});
  }

  void _onBackspace(int index, KeyEvent event) {
    if (event is! KeyDownEvent) return;

    if (event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      setState(() {});
    }
  }

  Future<void> _verifyOtp() async {
    if (_otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter the 6-digit OTP")),
      );
      return;
    }

    HapticFeedback.mediumImpact();

    setState(() => _verifying = true);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _verifying = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("OTP verified")),
    );

    Navigator.pop(context, true);
  }

  void _resendOtp() {
    HapticFeedback.selectionClick();
    _startTimer();

    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("OTP resent")),
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
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back_ios_new),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                const Expanded(
                                  child: Text(
                                    "OTP Verification",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 40),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Enter the 6-digit code sent to",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.contact,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(
                                6,
                                (index) => SizedBox(
                                  width: 48,
                                  child: Focus(
                                    onKeyEvent: (node, event) {
                                      _onBackspace(index, event);
                                      return KeyEventResult.ignored;
                                    },
                                    child: TextField(
                                      controller: _controllers[index],
                                      focusNode: _focusNodes[index],
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      maxLength: 1,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      ),
                                      decoration: InputDecoration(
                                        counterText: "",
                                        filled: true,
                                        fillColor: (isDark
                                                ? Colors.white
                                                : Colors.black)
                                            .withValues(alpha: isDark ? 0.05 : 0.04),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                      onChanged: (value) =>
                                          _onOtpChanged(index, value),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            GestureDetector(
                              onTap: _verifying ? null : _verifyOtp,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  color: const Color(0xFFD4AF37),
                                ),
                                child: Center(
                                  child: _verifying
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.black,
                                          ),
                                        )
                                      : const Text(
                                          "Verify OTP",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Center(
                              child: _secondsLeft > 0
                                  ? Text(
                                      "Resend OTP in ${_secondsLeft}s",
                                      style: TextStyle(
                                        color: Theme.of(context).hintColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: _resendOtp,
                                      child: const Text(
                                        "Resend OTP",
                                        style: TextStyle(
                                          color: Color(0xFFD4AF37),
                                          fontWeight: FontWeight.w900,
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