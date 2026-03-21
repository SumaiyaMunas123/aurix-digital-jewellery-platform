import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/user.dart';
import 'auth_repository.dart';

class AuthRepoApi implements AuthRepository {
  final _apiClient = ApiClient.instance;

  @override
  Future<User?> getSavedUser() async {
    // TODO: integrate real storage
    return null;
  }

  @override
  Future<User> login(String identifier, String password) async {
    try {
      print('🔐 Attempting login with: $identifier');
      
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {
          'identifier': identifier,
          'password': password,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Login failed');
      }

      final data = response.data;
      if (data['success'] != true || data['user'] == null) {
        throw Exception(data['message'] ?? 'Invalid login response');
      }

      final userData = data['user'];
      final token = data['token'];

      // Store token
      if (token != null) {
        _apiClient.setToken(token);
      }

      print('✅ Login successful: ${userData['email']}');

      return User(
        id: userData['id'] ?? '',
        name: userData['name'] ?? 'User',
        email: userData['email'],
        role: userData['role'] == 'jeweller' ? UserRole.jeweller : UserRole.customer,
        verified: userData['verified'] ?? false,
        verificationStatus: userData['verification_status'],
      );
    } on DioException catch (e) {
      print('❌ Login error: ${e.response?.data['message'] ?? e.message}');
      throw Exception(e.response?.data['message'] ?? 'Login failed');
    } catch (e) {
      print('❌ Login error: $e');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.dio.post('/auth/logout');
      _apiClient.clearToken();
      print('✅ Logout successful');
    } catch (e) {
      print('❌ Logout error: $e');
      rethrow;
    }
  }
}