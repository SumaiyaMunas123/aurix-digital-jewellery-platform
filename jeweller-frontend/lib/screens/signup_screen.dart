import 'package:flutter/material.dart';
import '../services/api_service.dart';

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

  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  DateTime? _selectedDate;
  String? _selectedGender;
  String? _selectedRelationshipStatus;

  // Error messages for each field
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _phoneError;
  String? _dateError;
  String? _genderError;
  String? _relationshipError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _termsError;

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

  void _clearErrors() {
    setState(() {
      _firstNameError = null;
      _lastNameError = null;
      _emailError = null;
      _phoneError = null;
      _dateError = null;
      _genderError = null;
      _relationshipError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _termsError = null;
    });
  }

  bool _validateAllFields() {
    _clearErrors();
    bool isValid = true;

    // Validate first name
    if (_firstNameController.text.trim().isEmpty) {
      setState(() => _firstNameError = 'Please enter your first name');
      isValid = false;
    }

    // Validate last name
    if (_lastNameController.text.trim().isEmpty) {
      setState(() => _lastNameError = 'Please enter your last name');
      isValid = false;
    }

    // Validate email
    if (_emailController.text.trim().isEmpty) {
      setState(() => _emailError = 'Please enter your email address');
      isValid = false;
    } else if (!isValidEmail(_emailController.text.trim())) {
      setState(() => _emailError = 'Please enter a valid email address');
      isValid = false;
    }

    // Validate phone
    if (_phoneController.text.trim().isEmpty) {
      setState(() => _phoneError = 'Please enter your mobile number');
      isValid = false;
    } else if (!isValidPhone(_phoneController.text.trim())) {
      setState(() => _phoneError = 'Please enter a valid 10-digit mobile number');
      isValid = false;
    }

    // Validate date of birth
    if (_selectedDate == null) {
      setState(() => _dateError = 'Please select your date of birth');
      isValid = false;
    } else if (!isAdult(_selectedDate)) {
      setState(() => _dateError = 'You must be at least 18 years old to register');
      isValid = false;
    }

    // Validate gender
    if (_selectedGender == null) {
      setState(() => _genderError = 'Please select your gender');
      isValid = false;
    }

    // Validate relationship status
    if (_selectedRelationshipStatus == null) {
      setState(() => _relationshipError = 'Please select your relationship status');
      isValid = false;
    }

    // Validate password
    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = 'Please enter a password');
      isValid = false;
    } else if (!isValidPassword(_passwordController.text)) {
      setState(() => _passwordError = 'Password must be at least 8 characters long');
      isValid = false;
    }

    // Validate confirm password
    if (_confirmPasswordController.text.isEmpty) {
      setState(() => _confirmPasswordError = 'Please confirm your password');
      isValid = false;
    } else if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _confirmPasswordError = 'Passwords do not match');
      isValid = false;
    }

    // Validate terms agreement
    if (!_agreeToTerms) {
      setState(() => _termsError = 'Please agree to the Terms & Conditions');
      isValid = false;
    }

    return isValid;
  }

  void _handleSignup() async {
    if (!_validateAllFields()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Format date as YYYY-MM-DD
      final formattedDate = '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
      
      print('🚀 Calling API...');
      
      final result = await _apiService.signup(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        dateOfBirth: formattedDate,
        gender: _selectedGender!,
        relationshipStatus: _selectedRelationshipStatus!,
      );

      setState(() => _isLoading = false);

      print('📥 API Result: $result');

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Please login.'),
            backgroundColor: Colors.green,
          ),
        );

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacementNamed(context, '/login');
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Signup failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
    } catch (e) {
      setState(() => _isLoading = false);
      print('❌ Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
              
              // Personal Information Card
              _buildCard(
                isDark: isDark,
                title: 'Personal Information',
                children: [
                  _buildTextField('First Name', isDark, controller: _firstNameController, errorText: _firstNameError),
                  const SizedBox(height: 20),
                  _buildTextField('Last Name', isDark, controller: _lastNameController, errorText: _lastNameError),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Contact Information Card
              _buildCard(
                isDark: isDark,
                title: 'Contact Information',
                children: [
                  _buildTextField('Email Address', isDark, controller: _emailController, keyboardType: TextInputType.emailAddress, errorText: _emailError),
                  const SizedBox(height: 20),
                  _buildTextField('Mobile Number', isDark, controller: _phoneController, keyboardType: TextInputType.phone, errorText: _phoneError),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Additional Details Card
              _buildCard(
                isDark: isDark,
                title: 'Additional Details',
                children: [
                  _buildDateField('Date of Birth', isDark, errorText: _dateError),
                  const SizedBox(height: 20),
                  _buildDropdownField('Gender', ['Male', 'Female', 'Other'], isDark, (value) {
                    setState(() {
                      _selectedGender = value;
                      _genderError = null;
                    });
                  }, errorText: _genderError),
                  const SizedBox(height: 20),
                  _buildDropdownField('Relationship Status', ['Single', 'Married', 'Divorced', 'Widowed'], isDark, (value) {
                    setState(() {
                      _selectedRelationshipStatus = value;
                      _relationshipError = null;
                    });
                  }, errorText: _relationshipError),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Security Card
              _buildCard(
                isDark: isDark,
                title: 'Security',
                children: [
                  _buildPasswordField('Password', _obscurePassword, () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  }, isDark, _passwordController, errorText: _passwordError),
                  const SizedBox(height: 20),
                  _buildPasswordField('Confirm Password', _obscureConfirmPassword, () {
                    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                  }, isDark, _confirmPasswordController, errorText: _confirmPasswordError),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Terms & Conditions Checkbox
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreeToTerms = value ?? false;
                            _termsError = null;
                          });
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
                  if (_termsError != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            _termsError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
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
                  onPressed: _isLoading ? null : _handleSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    disabledBackgroundColor: primaryColor.withOpacity(0.5),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
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

  // Card Widget
  Widget _buildCard({
    required bool isDark,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A271A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Title
          Text(
            title,
            style: TextStyle(
              color: isDark ? primaryColor : primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          
          // Card Content
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    bool isDark, {
    TextEditingController? controller,
    TextInputType? keyboardType,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[700],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F1D14) : const Color(0xFFF8F7F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null 
                  ? Colors.red 
                  : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
              width: errorText != null ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 15,
            ),
            onChanged: (value) {
              if (errorText != null) {
                setState(() {
                  if (label == 'First Name') _firstNameError = null;
                  if (label == 'Last Name') _lastNameError = null;
                  if (label == 'Email Address') _emailError = null;
                  if (label == 'Mobile Number') _phoneError = null;
                });
              }
            },
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    errorText,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDateField(String label, bool isDark, {String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[700],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime(2000),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                _selectedDate = picked;
                _dateError = null;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F1D14) : const Color(0xFFF8F7F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: errorText != null 
                    ? Colors.red 
                    : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                width: errorText != null ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDate == null
                      ? 'Select date'
                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  style: TextStyle(
                    color: _selectedDate == null 
                        ? (isDark ? Colors.grey[500] : Colors.grey[600])
                        : (isDark ? Colors.white : Colors.black),
                    fontSize: 15,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    errorText,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> options, bool isDark, Function(String?) onChanged, {String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[700],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F1D14) : const Color(0xFFF8F7F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null 
                  ? Colors.red 
                  : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
              width: errorText != null ? 1.5 : 1,
            ),
          ),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 4),
            ),
            hint: Text(
              'Select $label',
              style: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[600],
                fontSize: 15,
              ),
            ),
            dropdownColor: isDark ? const Color(0xFF2A271A) : Colors.white,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 15,
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
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    errorText,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
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
    {String? errorText}
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[700],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F1D14) : const Color(0xFFF8F7F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null 
                  ? Colors.red 
                  : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
              width: errorText != null ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  size: 20,
                ),
                onPressed: onToggle,
              ),
            ),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 15,
            ),
            onChanged: (value) {
              if (errorText != null) {
                setState(() {
                  if (label == 'Password') _passwordError = null;
                  if (label == 'Confirm Password') _confirmPasswordError = null;
                });
              }
            },
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    errorText,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
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