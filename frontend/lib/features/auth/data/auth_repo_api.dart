import 'package:aurix/core/network/api_client.dart';

import '../models/user.dart';
import 'auth_repository.dart';

class AuthRepoApi implements AuthRepository {
  @override
  Future<User?> getSavedUser() async {
    try {
      // TODO: Implement secure local storage (SharedPreferences or similar)
      return null;
    } catch (e) {
      print('Error getting saved user: $e');
      return null;
    }
  }

  @override
  Future<User> login(String identifier, String password) async {
    try {
      final response = await ApiClient.instance.dio.post(
        '/auth/login',
        data: {
          'identifier': identifier,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final user = User(
          id: data['user']['id'] ?? '',
          name: data['user']['name'] ?? 'User',
          role: _parseUserRole(data['user']['role']),
        );
        
        // TODO: Save token securely: ApiClient.instance.setToken(data['token']);
        // TODO: Save user locally for persistence
        
        return user;
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await ApiClient.instance.dio.post('/auth/logout');
      ApiClient.instance.clearToken();
      // TODO: Clear local user data
    } catch (e) {
      print('Logout error: $e');
      ApiClient.instance.clearToken();
    }
  }

  UserRole _parseUserRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'jeweller':
        return UserRole.jeweller;
      default:
        return UserRole.customer;
    }
  }
}