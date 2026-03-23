import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:aurix/core/services/token_service.dart';

void main() {
  group('TokenService.decodeToken', () {
    test('returns decoded payload for valid JWT format', () {
      const header = {'alg': 'HS256', 'typ': 'JWT'};
      final payload = {
        'sub': 'user-123',
        'role': 'customer',
        'exp': 2000000000,
      };

      final token = [
        base64Url.encode(utf8.encode(jsonEncode(header))).replaceAll('=', ''),
        base64Url.encode(utf8.encode(jsonEncode(payload))).replaceAll('=', ''),
        'signature',
      ].join('.');

      final decoded = TokenService.decodeToken(token);

      expect(decoded, isNotNull);
      expect(decoded!['sub'], 'user-123');
      expect(decoded['role'], 'customer');
      expect(decoded['exp'], 2000000000);
    });

    test('returns null for malformed token', () {
      expect(TokenService.decodeToken('not-a-jwt'), isNull);
      expect(TokenService.decodeToken('a.b'), isNull);
    });
  });
}
