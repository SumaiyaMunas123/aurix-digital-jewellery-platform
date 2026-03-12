import 'package:dio/dio.dart';

class ApiService {
  // static const String baseUrl = 'http://10.0.2.2:5000'; // Android Emulator
  static const String baseUrl = 'http://localhost:5000'; // iOS Simulator
  // static const String baseUrl = 'http://YOUR_IP:5000'; // Real Device

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // ==================== CUSTOMER SIGNUP ====================
  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String dateOfBirth,
    required String gender,
    required String relationshipStatus,
  }) async {
    try {
      final data = {
        'email': email,
        'password': password,
        'name': '$firstName $lastName',
        'role': 'customer',
        'phone': phone,
        'date_of_birth': dateOfBirth,
        'gender': gender,
        'relationship_status': relationshipStatus,
      };

      final response = await _dio.post('/api/auth/signup', data: data);
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {'success': false, 'message': 'Network error: ${e.message}'};
    }
  }

  // ==================== JEWELLER REGISTRATION ====================
  Future<Map<String, dynamic>> registerJeweller({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String businessName,
    required String registrationNumber,
    required String certificationUrl,
  }) async {
    try {
      final data = {
        'email': email,
        'password': password,
        'name': '$firstName $lastName',
        'role': 'jeweller',
        'phone': phone,
        'business_name': businessName,
        'business_registration_number': registrationNumber,
        'certification_document_url': certificationUrl,
      };

      final response = await _dio.post('/api/auth/signup', data: data);
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {'success': false, 'message': 'Network error: ${e.message}'};
    }
  }

  // ==================== LOGIN ====================
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {'success': false, 'message': 'Network error: ${e.message}'};
    }
  }

  // ==================== CHECK VERIFICATION STATUS ====================
  Future<Map<String, dynamic>> getVerificationStatus(String jewellerId) async {
    try {
      final response = await _dio.get(
        '/api/admin/jewellers/$jewellerId/status',
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {'success': false, 'message': 'Network error: ${e.message}'};
    }
  }

  // ==================== GET ALL PRODUCTS ====================
  Future<Map<String, dynamic>> getAllProducts() async {
    try {
      final response = await _dio.get('/api/products');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {'success': false, 'message': 'Network error: ${e.message}'};
    }
  }

  // ==================== CHAT: GET MESSAGES ====================
  Future<Map<String, dynamic>> getMessages(
    String threadId, {
    int limit = 100,
  }) async {
    try {
      final response = await _dio.get(
        '/api/chat/$threadId/messages',
        queryParameters: {'limit': limit},
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {'success': false, 'message': 'Network error: ${e.message}'};
    }
  }

  // ==================== CHAT: MARK AS READ ====================
  Future<Map<String, dynamic>> markMessagesAsRead({
    required String threadId,
    required String userId,
  }) async {
    try {
      final response = await _dio.post(
        '/api/chat/read',
        data: {'thread_id': threadId, 'user_id': userId},
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {'success': false, 'message': 'Network error: ${e.message}'};
    }
  }

  // ==================== CHAT: SEND MESSAGE ====================
  Future<Map<String, dynamic>> sendMessage({
    required String threadId,
    required String senderId,
    required String message,
    String messageType = 'text',
    String? fileUrl,
    String? quotationId,
    String? aiDesignId,
  }) async {
    try {
      final payload = {
        'thread_id': threadId,
        'sender_id': senderId,
        'message': message,
        'message_type': messageType,
        'file_url': fileUrl,
        'quotation_id': quotationId,
        'ai_design_id': aiDesignId,
      };

      final response = await _dio.post('/api/chat/send', data: payload);
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {'success': false, 'message': 'Network error: ${e.message}'};
    }
  }

  // ==================== CHAT: GET THREADS FOR USER ====================
  Future<Map<String, dynamic>> getChatThreads(
    String userId, {
    String status = 'active',
  }) async {
    try {
      final response = await _dio.get(
        '/api/chat/threads/$userId',
        queryParameters: {'status': status},
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {'success': false, 'message': 'Network error: ${e.message}'};
    }
  }

  // ==================== AI CHAT (GROQ) ====================
  Future<Map<String, dynamic>> aiChat({
    required String message,
    List<Map<String, String>> conversationHistory = const [],
    String? userId,
  }) async {
    try {
      final response = await _dio.post(
        '/api/ai/chat',
        data: {
          'message': message,
          'conversation_history': conversationHistory,
          'user_id': userId,
        },
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {'success': false, 'message': 'Network error: ${e.message}'};
    }
  }

  // ==================== AI SUGGESTIONS ====================
  Future<Map<String, dynamic>> aiSuggestions({
    String? occasion,
    String? budget,
    String? materialPreference,
    String? stylePreference,
  }) async {
    try {
      final response = await _dio.post(
        '/api/ai/suggestions',
        data: {
          'occasion': occasion,
          'budget': budget,
          'material_preference': materialPreference,
          'style_preference': stylePreference,
        },
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {'success': false, 'message': 'Network error: ${e.message}'};
    }
  }

  // ==================== AI HEALTH CHECK ====================
  Future<Map<String, dynamic>> aiHealthCheck() async {
    try {
      final response = await _dio.get('/api/ai/health');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      return {'success': false, 'message': 'Network error: ${e.message}'};
    }
  }
}
