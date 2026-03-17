import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'email_verification_screen.dart';
import 'jeweller_pending_approval_screen.dart';
import 'otp_verification_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  int _accountType = 0; // 0 = customer, 1 = jeweller

  final _fullName = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _shopName = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  XFile? _shopImage;
  XFile? _registrationDoc;

  bool _mobileVerified = false;
  bool _creating = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullName.dispose();
    _mobile.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _shopName.dispose();
    super.dispose();
  }

  Future<void> _pickShopImage() async {
    HapticFeedback.selectionClick();
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null) {
      setState(() => _shopImage = file);
    }
  }

  Future<void> _pickRegistrationDoc() async {
    HapticFeedback.selectionClick();
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null) {
      setState(() => _registrationDoc = file);
    }
  }

  String _normalizeMobile(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  bool _isValidMobile(String value) {
    final mobile = _normalizeMobile(value);
    return mobile.length >= 9 && mobile.length <= 12;
  }

  bool _isValidEmail(String value) {
    final email = value.trim();
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  Future<void> _verifyMobile() async {
    final mobile = _normalizeMobile(_mobile.text.trim());

    if (mobile.isEmpty) {
      _showSnack("Enter mobile number first.");
      return;
    }

    if (!_isValidMobile(mobile)) {
      _showSnack("Enter a valid mobile number.");
      return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(contact: mobile),
      ),
    );

    if (result == true) {
      setState(() => _mobileVerified = true);
      _showSnack("Mobile number verified.");
    }
  }

  PasswordStrength get _passwordStrength {
    final p = _password.text;

    if (p.isEmpty) return PasswordStrength.none;

    int score = 0;
    if (p.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(p)) score++;
    if (RegExp(r'[a-z]').hasMatch(p)) score++;
    if (RegExp(r'[0-9]').hasMatch(p)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=/\\[\];`~]').hasMatch(p)) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  String get _passwordStrengthLabel {
    switch (_passwordStrength) {
      case PasswordStrength.none:
        return "";
      case PasswordStrength.weak:
        return "Weak password";
      case PasswordStrength.medium:
        return "Medium password";
      case PasswordStrength.strong:
        return "Strong password";
    }
  }

  Color _passwordStrengthColor() {
    switch (_passwordStrength) {
      case PasswordStrength.none:
        return Colors.transparent;
      case PasswordStrength.weak:
        return Colors.redAccent;
      case PasswordStrength.medium:
        return Colors.orangeAccent;
      case PasswordStrength.strong:
        return Colors.green;
    }
  }

  bool get _passwordsMatch =>
      _confirmPassword.text.isNotEmpty &&
      _password.text == _confirmPassword.text;

  Future<void> _createAccount() async {
    HapticFeedback.mediumImpact();

    if (_fullName.text.trim().isEmpty) {
      _showSnack("Enter full name.");
      return;
    }

    if (_mobile.text.trim().isEmpty) {
      _showSnack("Enter mobile number.");
      return;
    }

    if (!_isValidMobile(_mobile.text.trim())) {
      _showSnack("Enter a valid mobile number.");
      return;
    }

    if (!_mobileVerified) {
      _showSnack("Please verify your mobile number.");
      return;
    }

    if (_email.text.trim().isEmpty) {
      _showSnack("Enter email address.");
      return;
    }

    if (!_isValidEmail(_email.text.trim())) {
      _showSnack("Enter a valid email address.");
      return;
    }

    if (_password.text.trim().isEmpty) {
      _showSnack("Enter password.");
      return;
    }

    if (_passwordStrength == PasswordStrength.weak ||
        _passwordStrength == PasswordStrength.none) {
      _showSnack("Please use a stronger password.");
      return;
    }

    if (_confirmPassword.text.trim().isEmpty) {
      _showSnack("Confirm your password.");
      return;
    }

    if (_password.text != _confirmPassword.text) {
      _showSnack("Passwords do not match.");
      return;
    }

    if (_accountType == 1) {
      if (_shopName.text.trim().isEmpty) {
        _showSnack("Enter shop name.");
        return;
      }

      if (_registrationDoc == null) {
        _showSnack("Upload registration document.");
        return;
      }

      if (_shopImage == null) {
        _showSnack("Upload shop photo.");
        return;
      }
    }

    setState(() => _creating = true);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _creating = false);

    if (_accountType == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EmailVerificationScreen(
            email: _email.text.trim(),
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const JewellerPendingApprovalScreen(),
        ),
      );
    }
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: (isDark ? Colors.white : Colors.black)
                                .withOpacity(0.10),
                          ),
                          color: (isDark ? Colors.white : Colors.black)
                              .withOpacity(isDark ? 0.06 : 0.045),
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
                                    "Create Account",
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
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _typeButton(
                                    label: "Customer",
                                    value: 0,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _typeButton(
                                    label: "Jeweller",
                                    value: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _field(
                              controller: _fullName,
                              hint: _accountType == 0
                                  ? "Full Name"
                                  : "Owner Full Name",
                              textCapitalization: TextCapitalization.words,
                            ),
                            if (_accountType == 1) ...[
                              const SizedBox(height: 12),
                              _field(
                                controller: _shopName,
                                hint: "Shop Name",
                                textCapitalization: TextCapitalization.words,
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _field(
                                    controller: _mobile,
                                    hint: "Mobile Number",
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(12),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: _verifyMobile,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: _mobileVerified
                                          ? Colors.green
                                          : const Color(0xFFD4AF37),
                                    ),
                                    child: Text(
                                      _mobileVerified ? "Verified" : "Verify",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: _mobileVerified
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_mobile.text.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                _isValidMobile(_mobile.text)
                                    ? "Valid mobile number"
                                    : "Enter a valid mobile number",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: _isValidMobile(_mobile.text)
                                      ? Colors.green
                                      : Colors.redAccent,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            _field(
                              controller: _email,
                              hint: "Email Address",
                              keyboardType: TextInputType.emailAddress,
                            ),
                            if (_email.text.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                _isValidEmail(_email.text)
                                    ? "Valid email address"
                                    : "Enter a valid email address",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: _isValidEmail(_email.text)
                                      ? Colors.green
                                      : Colors.redAccent,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            _field(
                              controller: _password,
                              hint: "Password",
                              obscure: _obscurePassword,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            if (_password.text.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 8,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(999),
                                        color: _passwordStrengthColor()
                                            .withOpacity(0.25),
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor:
                                            _passwordStrength == PasswordStrength.weak
                                                ? 0.33
                                                : _passwordStrength ==
                                                        PasswordStrength.medium
                                                    ? 0.66
                                                    : _passwordStrength ==
                                                            PasswordStrength.strong
                                                        ? 1
                                                        : 0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(999),
                                            color: _passwordStrengthColor(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    _passwordStrengthLabel,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: _passwordStrengthColor(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 12),
                            _field(
                              controller: _confirmPassword,
                              hint: "Confirm Password",
                              obscure: _obscureConfirmPassword,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            if (_confirmPassword.text.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                _passwordsMatch
                                    ? "Passwords match"
                                    : "Passwords do not match",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: _passwordsMatch
                                      ? Colors.green
                                      : Colors.redAccent,
                                ),
                              ),
                            ],
                            if (_accountType == 1) ...[
                              const SizedBox(height: 14),
                              const Text(
                                "Business Registration Document",
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 8),
                              _uploadBox(
                                file: _registrationDoc,
                                onTap: _pickRegistrationDoc,
                                text: "Upload Document",
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Shop Photo",
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 8),
                              _uploadBox(
                                file: _shopImage,
                                onTap: _pickShopImage,
                                text: "Upload Shop Photo",
                              ),
                            ],
                            const SizedBox(height: 22),
                            GestureDetector(
                              onTap: _creating ? null : _createAccount,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  color: const Color(0xFFD4AF37),
                                ),
                                child: Center(
                                  child: _creating
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.black,
                                          ),
                                        )
                                      : Text(
                                          _accountType == 0
                                              ? "Create Customer Account"
                                              : "Submit Jeweller Registration",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black,
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

  Widget _typeButton({
    required String label,
    required int value,
  }) {
    final selected = _accountType == value;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _accountType = value;
          _mobileVerified = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: selected ? const Color(0xFFD4AF37) : Colors.transparent,
          border: Border.all(color: const Color(0xFFD4AF37)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: selected ? Colors.black : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffix,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      onChanged: (value) {
        if (controller == _mobile && _mobileVerified) {
          setState(() => _mobileVerified = false);
        } else {
          setState(() {});
        }
      },
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        suffixIcon: suffix,
      ),
    );
  }

  Widget _uploadBox({
    required XFile? file,
    required VoidCallback onTap,
    required String text,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD4AF37),
          ),
        ),
        child: file == null
            ? Center(
                child: Text(
                  text,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(file.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
      ),
    );
  }
}

enum PasswordStrength {
  none,
  weak,
  medium,
  strong,
}