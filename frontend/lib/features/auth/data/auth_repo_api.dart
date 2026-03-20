import 'dart:convert';
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
      // Check if we have a valid token and user info stored
      final token = await TokenService.getToken();
      if (token == null) return null;

      final userId = await TokenService.getUserId();
      final userName = await TokenService.getUserName();
      final userRoleStr = await TokenService.getUserRole();

      if (userId == null || userName == null || userRoleStr == null) {
        return null;
      }

      final role = userRoleStr == 'jeweller' ? UserRole.jeweller : UserRole.customer;

      return User(id: userId, name: userName, role: role);
    } catch (e) {
      print('Error getting saved user: $e');
      return null;
    }
  }

  @override
  Future<User> login(String identifier, String password) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {
          'email': identifier.contains('@') ? identifier : null,
          'phone': identifier.contains('@') ? null : identifier,
          'password': password,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data?['message'] ?? 'Login failed',
        );
      }

      final data = response.data;

      if (data == null || !data.containsKey('success') || data['success'] != true) {
        throw Exception('Invalid login response');
      }

      final token = data['token'] as String?;
      final userId = data['user']?['id'] as String?;
      final userName = data['user']?['name'] as String?;
      final userRole = data['user']?['role'] as String?;

      if (token == null || userId == null || userName == null || userRole == null) {
        throw Exception('Missing required fields in login response');
      }

      // Parse token to get expiry (7 days from backend)
      final claims = TokenService.decodeToken(token);
      final expTime = claims?['exp'] as int?;
      final expiryDate = expTime != null
          ? DateTime.fromMillisecondsSinceEpoch(expTime * 1000)
          : DateTime.now().add(const Duration(days: 7));

      // Save token and user info
      await TokenService.saveToken(
        token: token,
        userId: userId,
        userName: userName,
        userRole: userRole,
        expiryDate: expiryDate,
      );

      final role = userRole == 'jeweller' ? UserRole.jeweller : UserRole.customer;

      return User(
        id: userId,
        name: userName,
        role: role,
      );
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Login failed';
      throw Exception(message);
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      final token = await TokenService.getToken();
      if (token != null) {
        try {
          await _apiClient.dio.post('/auth/logout');
        } catch (e) {
          print('Error calling logout endpoint: $e');
          // Continue with clearing token even if endpoint fails
        }
      }
      await TokenService.clearToken();
    } catch (e) {
      print('Error during logout: $e');
      rethrow;
    }
  }

  /// Signup for new customer
  Future<User> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/signup',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'role': 'customer',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data?['message'] ?? 'Signup failed',
        );
      }

      final data = response.data;

      if (data == null || !data.containsKey('success') || data['success'] != true) {
        throw Exception('Invalid signup response');
      }

      final token = data['token'] as String?;
      final userId = data['user']?['id'] as String?;
      final userName = data['user']?['name'] as String?;
      final userRole = data['user']?['role'] as String? ?? 'customer';

      if (token == null || userId == null || userName == null) {
        throw Exception('Missing required fields in signup response');
      }

      // Parse token to get expiry
      final claims = TokenService.decodeToken(token);
      final expTime = claims?['exp'] as int?;
      final expiryDate = expTime != null
          ? DateTime.fromMillisecondsSinceEpoch(expTime * 1000)
          : DateTime.now().add(const Duration(days: 7));

      // Save token and user info
      await TokenService.saveToken(
        token: token,
        userId: userId,
        userName: userName,
        userRole: userRole,
        expiryDate: expiryDate,
      );

      final role = userRole == 'jeweller' ? UserRole.jeweller : UserRole.customer;

      return User(
        id: userId,
        name: userName,
        role: role,
      );
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Signup failed';
      throw Exception(message);
    } catch (e) {
      throw Exception('Signup error: $e');
    }
  }

  /// Google login
  Future<User> googleLogin({required String idToken}) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/google',
        data: {
          'idToken': idToken,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data?['message'] ?? 'Google login failed',
        );
      }

      final data = response.data;

      if (data == null || !data.containsKey('success') || data['success'] != true) {
        throw Exception('Invalid Google login response');
      }

      final token = data['token'] as String?;
      final userId = data['user']?['id'] as String?;
      final userName = data['user']?['name'] as String?;
      final userRole = data['user']?['role'] as String? ?? 'customer';

      if (token == null || userId == null || userName == null) {
        throw Exception('Missing required fields in Google login response');
      }

      // Parse token to get expiry
      final claims = TokenService.decodeToken(token);
      final expTime = claims?['exp'] as int?;
      final expiryDate = expTime != null
          ? DateTime.fromMillisecondsSinceEpoch(expTime * 1000)
          : DateTime.now().add(const Duration(days: 7));

      // Save token and user info
      await TokenService.saveToken(
        token: token,
        userId: userId,
        userName: userName,
        userRole: userRole,
        expiryDate: expiryDate,
      );

      final role = userRole == 'jeweller' ? UserRole.jeweller : UserRole.customer;

      return User(
        id: userId,
        name: userName,
        role: role,
      );
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Google login failed';
      throw Exception(message);
    } catch (e) {
      throw Exception('Google login error: $e');
    }
  }
}