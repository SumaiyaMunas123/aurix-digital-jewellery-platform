import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/services/token_service.dart';
import '../models/user.dart';
import 'auth_repository.dart';

class AuthRepoApi implements AuthRepository {
  final _apiClient = ApiClient.instance;

  @override
  Future<User?> getSavedUser() async {
    try {
      final token = await TokenService.getToken();
      if (token == null || token.isEmpty) return null;

      final userId = await TokenService.getUserId();
      final userName = await TokenService.getUserName();
      final userRole = await TokenService.getUserRole();

      if (userId == null || userName == null || userRole == null) {
        return null;
      }

      return User(
        id: userId,
        name: userName,
        role: userRole == 'jeweller' ? UserRole.jeweller : UserRole.customer,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<User> login(String identifier, String password) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {
          'identifier': identifier,
          'password': password,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(response.data?['message'] ?? 'Login failed');
      }

      final data = response.data as Map<String, dynamic>?;
      if (data == null || data['success'] != true) {
        throw Exception(data?['message'] ?? 'Invalid login response');
      }

      final userData = (data['user'] as Map?)?.cast<String, dynamic>() ?? {};
      final token = (data['token'] ?? '').toString();
      if (token.isEmpty) {
        throw Exception('Token missing in login response');
      }

      final userId = (userData['id'] ?? '').toString();
      final userName = (userData['name'] ?? 'User').toString();
      final userRole = (userData['role'] ?? 'customer').toString();

      if (userId.isEmpty) {
        throw Exception('User id missing in login response');
      }

      final claims = TokenService.decodeToken(token);
      final exp = claims?['exp'] as int?;
      final expiryDate = exp != null
          ? DateTime.fromMillisecondsSinceEpoch(exp * 1000)
          : DateTime.now().add(const Duration(days: 7));

      await TokenService.saveToken(
        token: token,
        userId: userId,
        userName: userName,
        userRole: userRole,
        expiryDate: expiryDate,
      );
      _apiClient.setToken(token);

      return User(
        id: userId,
        name: userName,
        email: userData['email']?.toString(),
        role: userRole == 'jeweller' ? UserRole.jeweller : UserRole.customer,
        verified: userData['verified'] == true,
        verificationStatus: userData['verification_status']?.toString(),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Login failed');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.dio.post('/auth/logout');
    } catch (_) {
      // Ignore API logout failure and still clear local auth state.
    } finally {
      await TokenService.clearToken();
      _apiClient.clearToken();
    }
  }
}
