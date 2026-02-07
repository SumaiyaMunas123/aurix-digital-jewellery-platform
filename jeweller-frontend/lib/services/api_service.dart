import 'package:dio/dio.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.8.154:5000/api'; // Change this!
  
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  // Signup (Customer)
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
      print('📤 Sending signup request to: $baseUrl/auth/signup');
      
      final data = {
        'email': email,
        'password': password,
        'name': '$firstName $lastName',
        'role': 'customer', // ← CUSTOMER SPECIFIC
        'phone': phone,
        'date_of_birth': dateOfBirth,
        'gender': gender,
        'relationship_status': relationshipStatus,
      };

      print('📦 Request data: $data');

      final response = await _dio.post('/auth/signup', data: data);
      
      print('Response: ${response.data}');
      return response.data;
      
    } on DioException catch (e) {
      print('DioException: ${e.type}');
      print('Error message: ${e.message}');
      
      if (e.response != null) {
        print('Response data: ${e.response!.data}');
        return e.response!.data;
      }
      
      return {
        'success': false,
        'message': 'Network error: ${e.message}'
      };
    } catch (e) {
      print('Unknown error: $e');
      return {
        'success': false,
        'message': 'Unknown error: $e'
      };
    }
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('Sending login request to: $baseUrl/auth/login');
      
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      print('Login response: ${response.data}');
      return response.data;
      
    } on DioException catch (e) {
      print('Login error: ${e.message}');
      
      if (e.response != null) {
        return e.response!.data;
      }
      
      return {
        'success': false,
        'message': 'Network error: ${e.message}'
      };
    }
  }

  // Get all products
  Future<Map<String, dynamic>> getAllProducts() async {
    try {
      final response = await _dio.get('/products');
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