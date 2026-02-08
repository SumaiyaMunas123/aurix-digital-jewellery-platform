import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';

class JewellerRegistrationScreen extends StatefulWidget {
  const JewellerRegistrationScreen({super.key});

  @override
  State<JewellerRegistrationScreen> createState() => _JewellerRegistrationScreenState();
}

class _JewellerRegistrationScreenState extends State<JewellerRegistrationScreen> {
  static const Color primaryColor = Color(0xFFD4AF35);
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  final ApiService _apiService = ApiService();
  
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _registrationNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  String? _certificationFileName;
  String? _certificationFileUrl;
  
  // Error messages
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _phoneError;
  String? _businessNameError;
  String? _registrationNumberError;
  String? _certificationError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _termsError;

  final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  bool isValidEmail(String email) => emailRegex.hasMatch(email);
  bool isValidPhone(String phone) => phone.length == 10 && int.tryParse(phone) != null;
  bool isValidPassword(String password) => password.length >= 8;

  Future<void> _pickCertificationDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        _certificationFileName = result.files.single.name;
        // TODO: Upload to cloud storage (Supabase Storage/Firebase/AWS S3)
        // For now, use a temporary placeholder
        _certificationFileUrl = 'temp_cert_${DateTime.now().millisecondsSinceEpoch}';
        _certificationError = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File selected: ${result.files.single.name}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _clearErrors() {
    setState(() {
      _firstNameError = null;
      _lastNameError = null;
      _emailError = null;
      _phoneError = null;
      _businessNameError = null;
      _registrationNumberError = null;
      _certificationError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _termsError = null;
    });
  }

  bool _validateAllFields() {
    _clearErrors();
    bool isValid = true;

    if (_firstNameController.text.trim().isEmpty) {
      setState(() => _firstNameError = 'Please enter your first name');
      isValid = false;
    }

    if (_lastNameController.text.trim().isEmpty) {
      setState(() => _lastNameError = 'Please enter your last name');
      isValid = false;
    }

    if (_emailController.text.trim().isEmpty) {
      setState(() => _emailError = 'Please enter your email address');
      isValid = false;
    } else if (!isValidEmail(_emailController.text.trim())) {
      setState(() => _emailError = 'Please enter a valid email address');
      isValid = false;
    }

    if (_phoneController.text.trim().isEmpty) {
      setState(() => _phoneError = 'Please enter your phone number');
      isValid = false;
    } else if (!isValidPhone(_phoneController.text.trim())) {
      setState(() => _phoneError = 'Please enter a valid 10-digit mobile number');
      isValid = false;
    }

    if (_businessNameController.text.trim().isEmpty) {
      setState(() => _businessNameError = 'Please enter your business name');
      isValid = false;
    }

    if (_registrationNumberController.text.trim().isEmpty) {
      setState(() => _registrationNumberError = 'Please enter business registration number');
      isValid = false;
    }

    if (_certificationFileUrl == null) {
      setState(() => _certificationError = 'Please upload your certification document');
      isValid = false;
    }

    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = 'Please enter a password');
      isValid = false;
    } else if (!isValidPassword(_passwordController.text)) {
      setState(() => _passwordError = 'Password must be at least 8 characters long');
      isValid = false;
    }

    if (_confirmPasswordController.text.isEmpty) {
      setState(() => _confirmPasswordError = 'Please confirm your password');
      isValid = false;
    } else if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _confirmPasswordError = 'Passwords do not match');
      isValid = false;
    }

    if (!_agreeToTerms) {
      setState(() => _termsError = 'Please agree to the Terms & Conditions');
      isValid = false;
    }

    return isValid;
  }

  void _handleRegistration() async {
    if (!_validateAllFields()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('🚀 Calling Jeweller Registration API...');
      
      final result = await _apiService.registerJeweller(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        businessName: _businessNameController.text.trim(),
        registrationNumber: _registrationNumberController.text.trim(),
        certificationUrl: _certificationFileUrl!,
      );

      setState(() => _isLoading = false);

      print('📥 API Result: $result');

      if (result['success'] == true) {
        final jewellerId = result['user']['id'];
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Waiting for admin approval.'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to pending verification screen
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacementNamed(
            context,
            '/pending-verification',
            arguments: jewellerId,
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Registration failed'),
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
    _businessNameController.dispose();
    _registrationNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          'Jeweller Verification',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.verified_user,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Business Verification Required',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Submit your details for admin approval',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Personal Information Card
              _buildCard(
                title: 'Personal Information',
                children: [
                  _buildTextField('First Name', _firstNameController, errorText: _firstNameError),
                  const SizedBox(height: 16),
                  _buildTextField('Last Name', _lastNameController, errorText: _lastNameError),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Contact Information Card
              _buildCard(
                title: 'Contact Information',
                children: [
                  _buildTextField('Email Address', _emailController, keyboardType: TextInputType.emailAddress, errorText: _emailError),
                  const SizedBox(height: 16),
                  _buildTextField('Mobile Number', _phoneController, keyboardType: TextInputType.phone, errorText: _phoneError),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Business Information Card
              _buildCard(
                title: 'Business Information',
                children: [
                  _buildTextField('Business Name', _businessNameController, errorText: _businessNameError),
                  const SizedBox(height: 16),
                  _buildTextField('Business Registration Number', _registrationNumberController, errorText: _registrationNumberError),
                  const SizedBox(height: 16),
                  
                  // Certification Upload
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Business Certification Document *',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickCertificationDocument,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F7F6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _certificationError != null 
                                  ? Colors.red 
                                  : (_certificationFileName != null ? primaryColor : Colors.grey[300]!),
                              width: _certificationError != null ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.upload_file,
                                  color: primaryColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _certificationFileName ?? 'Upload Document',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _certificationFileName != null 
                                          ? 'File selected' 
                                          : 'PDF, JPG, or PNG (Max 5MB)',
                                      style: TextStyle(
                                        color: _certificationFileName != null
                                            ? Colors.green
                                            : Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                _certificationFileName != null 
                                    ? Icons.check_circle 
                                    : Icons.arrow_forward_ios,
                                color: _certificationFileName != null 
                                    ? Colors.green 
                                    : primaryColor,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_certificationError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                _certificationError!,
                                style: const TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Security Card
              _buildCard(
                title: 'Account Security',
                children: [
                  _buildPasswordField('Password', _obscurePassword, () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  }, _passwordController, errorText: _passwordError),
                  const SizedBox(height: 16),
                  _buildPasswordField('Confirm Password', _obscureConfirmPassword, () {
                    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                  }, _confirmPasswordController, errorText: _confirmPasswordError),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Terms & Conditions
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
                      const Expanded(
                        child: Text(
                          'I agree to the Terms & Conditions',
                          style: TextStyle(fontSize: 14),
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
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    disabledBackgroundColor: primaryColor.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
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
                          'SUBMIT FOR VERIFICATION',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Already registered
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Already registered? ',
                          style: TextStyle(color: Colors.black54),
                        ),
                        TextSpan(
                          text: 'Login here',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
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
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType? keyboardType, String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F7F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null ? Colors.red : Colors.grey[300]!,
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
            style: const TextStyle(color: Colors.black, fontSize: 15),
            onChanged: (value) {
              if (errorText != null) {
                setState(() {
                  if (label == 'First Name') _firstNameError = null;
                  if (label == 'Last Name') _lastNameError = null;
                  if (label == 'Email Address') _emailError = null;
                  if (label == 'Mobile Number') _phoneError = null;
                  if (label == 'Business Name') _businessNameError = null;
                  if (label == 'Business Registration Number') _registrationNumberError = null;
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
                  child: Text(errorText, style: const TextStyle(color: Colors.red, fontSize: 12)),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordField(String label, bool obscure, VoidCallback toggle, TextEditingController controller, {String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F7F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null ? Colors.red : Colors.grey[300]!,
              width: errorText != null ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[600],
                  size: 20,
                ),
                onPressed: toggle,
              ),
            ),
            style: const TextStyle(color: Colors.black, fontSize: 15),
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
                  child: Text(errorText, style: const TextStyle(color: Colors.red, fontSize: 12)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}