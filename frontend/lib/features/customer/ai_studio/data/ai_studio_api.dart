import 'package:dio/dio.dart';

import 'package:aurix/core/config/environment.dart';

class AiStudioApi {
  AiStudioApi._();

  static final AiStudioApi instance = AiStudioApi._();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Environment.aiBaseUrl,
      connectTimeout: const Duration(seconds: 45),
      sendTimeout: const Duration(seconds: 45),
      receiveTimeout: const Duration(seconds: 60),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  Future<Map<String, dynamic>> generateStyled({
    required String prompt,
    required String userType,
    String? userId,
    required Map<String, String> style,
  }) async {
    final payload = <String, dynamic>{
      'prompt': prompt,
      'user_type': userType,
      'style': style,
    };

    if (userId != null && userId.trim().isNotEmpty) {
      payload['user_id'] = userId.trim();
    }

    try {
      final response = await _dio.post('/designs/generate-styled', data: payload);
      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response from AI backend');
      }

      if (data['success'] != true) {
        throw Exception(data['error']?.toString() ?? 'AI generation failed');
      }

      return (data['data'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Cannot reach AI backend at ${Environment.aiBaseUrl}. '
          'If you are on Android emulator, keep AI BACKEND running on port 7000.',
        );
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('AI request timed out. Please retry in a moment.');
      }

      final apiError = e.response?.data;
      if (apiError is Map && apiError['error'] != null) {
        throw Exception(apiError['error'].toString());
      }

      throw Exception('AI request failed: ${e.message}');
    }
  }
}
