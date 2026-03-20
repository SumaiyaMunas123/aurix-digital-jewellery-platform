import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../../core/network/api_client.dart';
import '../models/ai_generation_request.dart';

class AiRepository {
  final _apiClient = ApiClient.instance;

  /// Generate image using AI (text-to-image or sketch-to-image)
  Future<Map<String, dynamic>> generateImage({
    required AiGenerationRequest request,
    int mode = 0, // 0 = text-to-image, 1 = sketch-to-image
  }) async {
    try {
      print('🎨 Generating AI image...');

      final formData = FormData.fromMap({
        'mode': mode,
        'prompt': request.prompt,
        'category': request.category,
        'weight': request.weight,
        'material': request.material,
        'karat': request.karat,
        'style': request.style,
        'occasion': request.occasion,
        'budget': request.budget,
        'user_type': 'customer',
      });

      // Add sketch file if in sketch-to-image mode
      if (mode == 1 && request.sketchPath != null && request.sketchPath!.isNotEmpty) {
        final File sketchFile = File(request.sketchPath!);
        if (await sketchFile.exists()) {
          formData.files.add(
            MapEntry(
              'sketch',
              await MultipartFile.fromFile(
                sketchFile.path,
                filename: 'sketch.png',
              ),
            ),
          );
          print('📸 Sketch file attached: ${sketchFile.path}');
        }
      }

      final response = await _apiClient.dio.post(
        '/ai/generate', // Routes to ai-backend port 7000
        data: formData,
      );

      print('✅ Generation successful (status: ${response.statusCode})');
      print('Response data: ${response.data}');

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Generation failed',
        );
      }

      final data = response.data;

      if (data == null || data['success'] != true) {
        throw Exception(data?['error'] ?? 'Generation failed');
      }

      // Return the generated data
      return {
        'success': true,
        'imageUrl': data['data']?['image_url'] ?? '',
        'imageBase64': data['data']?['image_base64'] ?? '',
        'sketchUrl': data['data']?['sketch_url'],
        'design': data['data']?['design'],
      };
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      final message = e.response?.data?['error'] ?? 'Generation failed: ${e.message}';
      throw Exception(message);
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Generation error: $e');
    }
  }

  /// Save generated design quotation
  Future<Map<String, dynamic>> saveQuotation({
    required String designImageUrl,
    required String prompt,
    required String category,
    required String material,
    required String karat,
    required String weight,
    required String style,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/ai/save-quotation',
        data: {
          'design_image_url': designImageUrl,
          'prompt': prompt,
          'category': category,
          'material': material,
          'karat': karat,
          'weight': weight,
          'style': style,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Save failed',
        );
      }

      return response.data;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Save failed';
      throw Exception(message);
    } catch (e) {
      throw Exception('Save error: $e');
    }
  }

  /// Get AI chat response
  Future<String> getChatResponse(String message) async {
    try {
      final response = await _apiClient.dio.post(
        '/ai/chat',
        data: {'message': message},
      );

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Chat failed',
        );
      }

      final data = response.data;
      return data['data']?['response'] ?? 'No response';
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Chat failed';
      throw Exception(message);
    } catch (e) {
      throw Exception('Chat error: $e');
    }
  }
}
