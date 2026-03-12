import 'package:http/http.dart' as http;
import 'dart:convert';

class JewelryAIService {
  // ⚠️ UPDATE THIS BASED ON YOUR SETUP:
  // Android Emulator:  http://10.0.2.2:5000
  // iOS Simulator:     http://localhost:5000
  // Real Device (WiFi): http://<YOUR_PC_IP>:5000
  // Web (Chrome):      http://localhost:5000
  //
  // This points to the Node.js backend (same as ApiService)
  static const String _baseUrl = "http://localhost:5000";

  /// Generate an AI jewellery image from a text prompt.
  /// Returns base64-encoded PNG image data on success.
  /// Throws [Exception] with a user-friendly message on failure.
  static Future<String> generateImage(String prompt) async {
    if (prompt.trim().isEmpty) {
      throw Exception("Prompt cannot be empty");
    }

    try {
      final uri = Uri.parse("$_baseUrl/api/ai/generate");
      final response = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"prompt": prompt}),
          )
          .timeout(const Duration(seconds: 150));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true && data["image_base64"] != null) {
          return data["image_base64"];
        } else {
          throw Exception(data["error"] ?? "Failed to generate image");
        }
      } else if (response.statusCode == 503) {
        throw Exception(
            "AI model is loading. Please wait 30 seconds and try again.");
      } else {
        String errorMsg = "Server error (${response.statusCode})";
        try {
          final data = jsonDecode(response.body);
          errorMsg = data["error"] ?? errorMsg;
        } catch (_) {}
        throw Exception(errorMsg);
      }
    } on http.ClientException catch (e) {
      throw Exception(
          "Cannot connect to AI server. Make sure the backend is running.\n$e");
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception("Failed to generate image: $e");
    }
  }

  /// Check if the AI backend is running and reachable.
  static Future<bool> isBackendHealthy() async {
    try {
      final response = await http
          .get(Uri.parse("$_baseUrl/api/ai/health"))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["status"] == "ok";
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
