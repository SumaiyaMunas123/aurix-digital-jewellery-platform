import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:async';

class TokenService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userRoleKey = 'user_role';
  static const String _tokenExpiryKey = 'token_expiry';

  static const _secureStorage = FlutterSecureStorage();

  /// Save token and user info
  static Future<void> saveToken({
    required String token,
    required String userId,
    required String userName,
    required String userRole,
    required DateTime expiryDate,
  }) async {
    await Future.wait([
      _secureStorage.write(key: _tokenKey, value: token),
      _secureStorage.write(key: _userIdKey, value: userId),
      _secureStorage.write(key: _userNameKey, value: userName),
      _secureStorage.write(key: _userRoleKey, value: userRole),
      _secureStorage.write(
        key: _tokenExpiryKey,
        value: expiryDate.toIso8601String(),
      ),
    ]);
  }

  /// Get current token
  static Future<String?> getToken() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      if (token == null) return null;

      // Check if token is expired
      final expiry = await _getTokenExpiry();
      if (expiry != null && DateTime.now().isAfter(expiry)) {
        // Token expired
        await clearToken();
        return null;
      }

      return token;
    } catch (e) {
      print('Error reading token: $e');
      return null;
    }
  }

  /// Get user ID
  static Future<String?> getUserId() async {
    try {
      return await _secureStorage.read(key: _userIdKey);
    } catch (e) {
      print('Error reading user ID: $e');
      return null;
    }
  }

  /// Get user name
  static Future<String?> getUserName() async {
    try {
      return await _secureStorage.read(key: _userNameKey);
    } catch (e) {
      print('Error reading user name: $e');
      return null;
    }
  }

  /// Get user role
  static Future<String?> getUserRole() async {
    try {
      return await _secureStorage.read(key: _userRoleKey);
    } catch (e) {
      print('Error reading user role: $e');
      return null;
    }
  }

  /// Check if token exists and is valid
  static Future<bool> hasValidToken() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      if (token == null) return false;

      final expiry = await _getTokenExpiry();
      if (expiry == null) return false;

      // Consider token valid if not expired and at least 2 minutes remain
      final now = DateTime.now();
      final twoMinutesFromNow = now.add(const Duration(minutes: 2));

      return twoMinutesFromNow.isBefore(expiry);
    } catch (e) {
      print('Error checking token validity: $e');
      return false;
    }
  }

  /// Get remaining time before token expires
  static Future<Duration?> getTokenRemainingTime() async {
    try {
      final expiry = await _getTokenExpiry();
      if (expiry == null) return null;

      final remaining = expiry.difference(DateTime.now());
      if (remaining.isNegative) return null;

      return remaining;
    } catch (e) {
      print('Error getting token remaining time: $e');
      return null;
    }
  }

  /// Clear token and user info
  static Future<void> clearToken() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: _tokenKey),
        _secureStorage.delete(key: _userIdKey),
        _secureStorage.delete(key: _userNameKey),
        _secureStorage.delete(key: _userRoleKey),
        _secureStorage.delete(key: _tokenExpiryKey),
      ]);
    } catch (e) {
      print('Error clearing token: $e');
    }
  }

  /// Get token expiry time
  static Future<DateTime?> _getTokenExpiry() async {
    try {
      final expiryStr = await _secureStorage.read(key: _tokenExpiryKey);
      if (expiryStr == null) return null;
      return DateTime.parse(expiryStr);
    } catch (e) {
      print('Error parsing token expiry: $e');
      return null;
    }
  }

  /// Decode JWT token to get claims (exp, sub, etc)
  static Map<String, dynamic>? decodeToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final decoded = base64Url.decode(base64Url.normalize(parts[1]));
      return jsonDecode(utf8.decode(decoded));
    } catch (e) {
      print('Error decoding token: $e');
      return null;
    }
  }
}
