import 'package:dio/dio.dart';

class ApiService {
  // IMPORTANT: Change to your IP address
  static const String baseUrl = 'http://127.0.0.1:5000'; // ← YOUR IP HERE
  
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  // ==================== CUSTOMER SIGNUP ====================
  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String dateOfBirth,
    required String gender,
    required String relationshipStatus,
  }) async {
    try {
      print('📤 Customer Signup Request');
      
      final data = {
        'email': email,
        'password': password,
        'name': '$firstName $lastName',
        'role': 'customer',
        'phone': phone,
        'date_of_birth': dateOfBirth,
        'gender': gender,
        'relationship_status': relationshipStatus,
      };

      final response = await _dio.post('/api/auth/signup', data: data);
      print('✅ Signup Response: ${response.data}');
      return response.data;
      
    } on DioException catch (e) {
      print('❌ Signup Error: ${e.message}');
      if (e.response != null) {
        return e.response!.data;
      }
      return {
        'success': false,
        'message': 'Network error: ${e.message}'
      };
    }
  }

  // ==================== JEWELLER REGISTRATION ====================
  Future<Map<String, dynamic>> registerJeweller({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String businessName,
    required String registrationNumber,
    required String certificationUrl,
  }) async {
    try {
      print('📤 Jeweller Registration Request');
      
      final data = {
        'email': email,
        'password': password,
        'name': '$firstName $lastName',
        'role': 'jeweller',
        'phone': phone,
        'business_name': businessName,
        'business_registration_number': registrationNumber,
        'certification_document_url': certificationUrl,
      };

      final response = await _dio.post('/api/auth/signup', data: data);
      print('✅ Registration Response: ${response.data}');
      return response.data;
      
    } on DioException catch (e) {
      print('❌ Registration Error: ${e.message}');
      if (e.response != null) {
        return e.response!.data;
      }
      return {
        'success': false,
        'message': 'Network error: ${e.message}'
      };
    }
  }

  // ==================== LOGIN (Both Customer & Jeweller) ====================
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('📤 Login Request for: $email');
      
      final response = await _dio.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      print('✅ Login Response: ${response.data}');
      return response.data;
      
    } on DioException catch (e) {
      print('❌ Login Error: ${e.message}');
      if (e.response != null) {
        return e.response!.data;
      }
      return {
        'success': false,
        'message': 'Network error: ${e.message}'
      };
    }
  }

  // ==================== CHECK VERIFICATION STATUS ====================
  Future<Map<String, dynamic>> getVerificationStatus(String jewellerId) async {
    try {
      print('📤 Checking verification status for: $jewellerId');
      
      final response = await _dio.get('/api/admin/jewellers/$jewellerId/status');
      
      print('✅ Status Response: ${response.data}');
      return response.data;
      
    } on DioException catch (e) {
      print('❌ Status Check Error: ${e.message}');
      if (e.response != null) {
        return e.response!.data;
      }
      return {
        'success': false,
        'message': 'Network error: ${e.message}'
      };
    }
  }

  // ==================== GET ALL PRODUCTS ====================
  Future<Map<String, dynamic>> getAllProducts() async {
    try {
      final response = await _dio.get('/api/products');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!.data;
      }
      return {
        'success': false,
        'message': 'Network error: ${e.message}'
      };
    }
  }
}