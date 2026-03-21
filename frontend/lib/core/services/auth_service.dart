import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../network/api_client.dart';
import 'file_upload_service.dart';
import '../../features/auth/models/user.dart';

class AuthService {
  final _apiClient = ApiClient.instance;
  final _fileUploadService = FileUploadService();

  /// Signup a new user (customer or jeweler)
  Future<User> signup({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role, // 'customer' or 'jeweller'
    String? dateOfBirth,
    String? gender,
    String? relationshipStatus,
    String? businessName,
    String? businessRegistrationNumber,
    XFile? certificateDoc,
  }) async {
    try {
      print('📝 Starting signup for: $email');

      String? certDocUrl;

      // Upload certificate document if this is a jeweler
      if (role == 'jeweller' && certificateDoc != null) {
        print('📤 Uploading certification document...');
        certDocUrl = await _fileUploadService.uploadFile(
          bucket: 'documents',
          file: certificateDoc,
          folder: 'jeweler-verification',
        );
      }

      // Prepare signup data
      final signupData = {
        'email': email,
        'password': password,
        'name': name,
        'phone': phone,
        'role': role,
      };

      // Add customer-specific fields
      if (role == 'customer') {
        signupData['date_of_birth'] = dateOfBirth!;
        signupData['gender'] = gender!;
        signupData['relationship_status'] = relationshipStatus!;
      }

      // Add jeweler-specific fields
      if (role == 'jeweller') {
        signupData['business_name'] = businessName!;
        signupData['business_registration_number'] = businessRegistrationNumber!;
        signupData['certification_document_url'] = certDocUrl!;
      }

      print('🔐 Calling signup API...');
      final response = await _apiClient.dio.post(
        '/auth/signup',
        data: signupData,
      );

      if (response.statusCode != 201) {
        throw Exception(response.data['message'] ?? 'Signup failed');
      }

      final data = response.data;
      if (data['success'] != true || data['user'] == null) {
        throw Exception(data['message'] ?? 'Invalid signup response');
      }

      final userData = data['user'];
      final token = data['token'];

      // Store token if provided
      if (token != null) {
        _apiClient.setToken(token);
      }

      print('✅ Signup successful: ${userData['email']}');

      return User(
        id: userData['id'] ?? '',
        name: userData['name'] ?? 'User',
        email: userData['email'],
        role: userData['role'] == 'jeweller' ? UserRole.jeweller : UserRole.customer,
        verified: userData['verified'] ?? false,
        verificationStatus: userData['verification_status'],
      );
    } on DioException catch (e) {
      print('❌ Signup error: ${e.response?.data['message'] ?? e.message}');
      throw Exception(e.response?.data['message'] ?? 'Signup failed');
    } catch (e) {
      print('❌ Signup error: $e');
      rethrow;
    }
  }

  /// Request email verification code
  Future<void> requestEmailVerification(String email) async {
    try {
      print('📧 Requesting email verification...');
      final response = await _apiClient.dio.post(
        '/auth/email/request-verification',
        data: {'email': email},
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to request verification');
      }

      print('✅ Verification code sent to: $email');
    } catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
  }

  /// Verify email code
  Future<void> verifyEmailCode(String email, String code) async {
    try {
      print('✔️ Verifying email code...');
      final response = await _apiClient.dio.post(
        '/auth/email/verify-code',
        data: {
          'email': email,
          'code': code,
        },
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Verification failed');
      }

      print('✅ Email verified successfully');
    } catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
  }
}
