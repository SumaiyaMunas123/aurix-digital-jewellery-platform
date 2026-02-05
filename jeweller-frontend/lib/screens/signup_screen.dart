import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  static const Color primaryColor = Color(0xFFD4AF35);
  bool _agreeToTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  DateTime? _selectedDate;
  String? _selectedGender;
  String? _selectedRelationshipStatus;

  // Email validation regex
  final RegExp emailRegex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  bool isValidEmail(String email) {
    return emailRegex.hasMatch(email);
  }

  // Phone validation (10 digits)
  bool isValidPhone(String phone) {
    return phone.length == 10 && int.tryParse(phone) != null;
  }

  // Password validation (min 8 chars)
  bool isValidPassword(String password) {
    return password.length >= 8;
  }

  // Age validation (18+)
  bool isAdult(DateTime? birthDate) {
    if (birthDate == null) return false;
    final age = DateTime.now().year - birthDate.year;
    final hasHadBirthdayThisYear = DateTime.now().month > birthDate.month ||
        (DateTime.now().month == birthDate.month && DateTime.now().day >= birthDate.day);
    return hasHadBirthdayThisYear ? age >= 18 : age - 1 >= 18;
  }

  void _handleSignup() {
    // Validate first name
    if (_firstNameController.text.trim().isEmpty) {
      _showError('Please enter your first name');
      return;
    }

    // Validate last name
    if (_lastNameController.text.trim().isEmpty) {
      _showError('Please enter your last name');
      return;
    }

    // Validate email
    if (_emailController.text.trim().isEmpty) {
      _showError('Please enter your email address');
      return;
    }

    if (!isValidEmail(_emailController.text.trim())) {
      _showError('Please enter a valid email address');
      return;
    }

    // Validate phone
    if (_phoneController.text.trim().isEmpty) {
      _showError('Please enter your mobile number');
      return;
    }

    if (!isValidPhone(_phoneController.text.trim())) {
      _showError('Please enter a valid 10-digit mobile number');
      return;
    }

    // Validate date of birth
    if (_selectedDate == null) {
      _showError('Please select your date of birth');
      return;
    }

    if (!isAdult(_selectedDate)) {
      _showError('You must be at least 18 years old to register');
      return;
    }

    // Validate gender
    if (_selectedGender == null) {
      _showError('Please select your gender');
      return;
    }

    // Validate relationship status
    if (_selectedRelationshipStatus == null) {
      _showError('Please select your relationship status');
      return;
    }

    // Validate password
    if (_passwordController.text.isEmpty) {
      _showError('Please enter a password');
      return;
    }

    if (!isValidPassword(_passwordController.text)) {
      _showError('Password must be at least 8 characters long');
      return;
    }

    // Validate confirm password
    if (_confirmPasswordController.text.isEmpty) {
      _showError('Please confirm your password');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    // Validate terms agreement
    if (!_agreeToTerms) {
      _showError('Please agree to the Terms & Conditions');
      return;
    }

    // If all validations pass, show success and navigate to login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account created successfully! Please login.'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate to login screen after signup
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF201D12) : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Title
              Text(
                'SIGNUP',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 36,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              
              // Input Fields
              _buildTextField('First Name', isDark, controller: _firstNameController),
              const SizedBox(height: 20),
              _buildTextField('Last Name', isDark, controller: _lastNameController),
              const SizedBox(height: 20),
              _buildTextField('Email Address', isDark, controller: _emailController, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 20),
              _buildTextField('Mobile Number', isDark, controller: _phoneController, keyboardType: TextInputType.phone),
              const SizedBox(height: 20),
              _buildDateField('Date of Birth', isDark),
              const SizedBox(height: 20),
              _buildDropdownField('Gender', ['Male', 'Female', 'Other'], isDark, (value) {
                setState(() => _selectedGender = value);
              }),
              const SizedBox(height: 20),
              _buildDropdownField('Relationship Status', ['Single', 'Married', 'Divorced', 'Widowed'], isDark, (value) {
                setState(() => _selectedRelationshipStatus = value);
              }),
              const SizedBox(height: 20),
              _buildPasswordField('Password', _obscurePassword, () {
                setState(() => _obscurePassword = !_obscurePassword);
              }, isDark, _passwordController),
              const SizedBox(height: 20),
              _buildPasswordField('Confirm Password', _obscureConfirmPassword, () {
                setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
              }, isDark, _confirmPasswordController),
              
              const SizedBox(height: 20),
              
              // Terms & Conditions Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (value) {
                      setState(() => _agreeToTerms = value ?? false);
                    },
                    activeColor: primaryColor,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/terms');
                      },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'I agree to the ',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : const Color(0xFF303030),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const TextSpan(
                              text: 'Terms & Conditions',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Signup Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: const Text(
                    'SIGNUP',
                    style: TextStyle(
                      color: Color(0xFFF5F5F5),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Or register with
              Text(
                'Or register with',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : const Color(0xFF303030),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Social Login Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildSocialButton('Google', isDark),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSocialButton('Apple', isDark),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    bool isDark, {
    TextEditingController? controller,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : const Color(0xFF404040),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.grey[600]! : const Color(0xFF404040),
                width: 2,
              ),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : const Color(0xFF404040),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.grey[600]! : const Color(0xFF404040),
                width: 2,
              ),
            ),
          ),
          child: InkWell(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime(2000),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedDate == null
                        ? ''
                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    color: isDark ? Colors.grey[400] : const Color(0xFF404040),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> options, bool isDark, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : const Color(0xFF404040),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.grey[600]! : const Color(0xFF404040),
                width: 2,
              ),
            ),
          ),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
            hint: Text(
              'Select $label',
              style: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[600],
                fontSize: 16,
              ),
            ),
            dropdownColor: isDark ? const Color(0xFF2A271A) : Colors.white,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 16,
            ),
            items: options.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onChanged,
            icon: Icon(
              Icons.arrow_drop_down,
              color: isDark ? Colors.grey[400] : const Color(0xFF404040),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    String label,
    bool obscureText,
    VoidCallback onToggle,
    bool isDark,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : const Color(0xFF404040),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.grey[600]! : const Color(0xFF404040),
                width: 2,
              ),
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: isDark ? Colors.grey[400] : const Color(0xFF404040),
                ),
                onPressed: onToggle,
              ),
            ),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(String label, bool isDark) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? Colors.grey[600]! : const Color(0xFF404040),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.grey[400] : const Color(0xFF404040),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              label == 'Google' ? Icons.g_mobiledata : Icons.apple,
              size: 20,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
