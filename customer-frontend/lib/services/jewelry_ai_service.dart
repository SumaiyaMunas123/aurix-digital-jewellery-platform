import 'package:http/http.dart' as http;
import 'dart:convert';

class JewelryAIService {
  // ⚠️ UPDATE THIS BASED ON YOUR SETUP:
  // Android Emulator: http://10.0.2.2:7000
  // iOS Simulator: http://localhost:7000
  // Real Device (same WiFi): http://192.168.34.234:7000
  static const String _baseUrl = "http://192.168.34.234:7000";

  /// Generate an AI image from a text prompt
  /// Returns base64 encoded image or throws exception
  static Future<String> generateImage(String prompt) async {
    if (prompt.trim().isEmpty) {
      throw Exception("Prompt cannot be empty");
    }

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/generate"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"prompt": prompt}),
        timeout: const Duration(seconds: 150),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true && data["image_base64"] != null) {
          return data["image_base64"];
        } else {
          throw Exception(data["error"] ?? "Unknown error");
        }
      } else if (response.statusCode == 503) {
        throw Exception("Model is loading. Please wait 30 seconds and try again.");
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to generate image: $e");
    }
  }

  /// Check if backend is healthy
  static Future<bool> isBackendHealthy() async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/health"),
        timeout: const Duration(seconds: 5),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
