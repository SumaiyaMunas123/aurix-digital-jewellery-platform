import 'package:dio/dio.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://10.0.2.2:5000',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Add logging interceptor for debugging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('📡 API: $obj'),
      ),
    );
  }

  // ==================== AUTH APIs ====================

  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    required String phone,
    String role = 'customer',
    String? businessName,
    String? businessAddress,
    String? businessRegNumber,
  }) async {
    try {
      print('📤 Registering user: $email');

      final Map<String, dynamic> data = {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'role': role,
      };

      if (role == 'jeweller') {
        data['business_name'] = businessName;
        data['business_address'] = businessAddress;
        data['business_reg_number'] = businessRegNumber;
      }

      final response = await _dio.post('/api/auth/signup', data: data);

      print('✅ Registration response: ${response.statusCode}');
      return response.data;
    } on DioException catch (e) {
      print('❌ Registration error: ${e.message}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
        return e.response!.data;
      }
      return {'success': false, 'message': 'Network error: ${e.message}'};
    }
  }

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
      print('📤 Registering jeweller: $email');

      final response = await _dio.post('/api/auth/signup', data: {
        'name': '$firstName $lastName',
        'email': email,
        'password': password,
        'phone': phone,
        'role': 'jeweller',
        'business_name': businessName,
        'business_registration_number': registrationNumber,
        'certification_document_url': certificationUrl,
      });

      print('✅ Jeweller registration response: ${response.statusCode}');
      return response.data;
    } on DioException catch (e) {
      print('❌ Jeweller registration error: ${e.message}');
      if (e.response != null) {
        return e.response!.data;
      }
      return {'success': false, 'message': 'Network error: ${e.message}'};
    }
  }

  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      print('📤 Logging in: $email');

      final response = await _dio.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );

      print('✅ Login response: ${response.statusCode}');
      return response.data;
    } on DioException catch (e) {
      print('❌ Login error: ${e.message}');
      if (e.response != null) {
        return e.response!.data;
      }
      return {'success': false, 'message': 'Network error: ${e.message}'};
    }
  }

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
      print('📤 Signing up customer: $email');

      final response = await _dio.post('/api/auth/signup', data: {
        'name': '$firstName $lastName',
        'email': email,
        'password': password,
        'phone': phone,
        'role': 'customer',
        'date_of_birth': dateOfBirth,
        'gender': gender,
        'relationship_status': relationshipStatus,
      });

      print('✅ Signup response: ${response.statusCode}');
      return response.data;
    } on DioException catch (e) {
      print('❌ Signup error: ${e.message}');
      if (e.response != null) {
        return e.response!.data;
      }
      return {'success': false, 'message': 'Network error: ${e.message}'};
    }
  }

  Future<Map<String, dynamic>> getVerificationStatus(String jewellerId) async {
    try {
      print('📤 Getting verification status for: $jewellerId');

      final response = await _dio.get('/api/admin/jewellers/$jewellerId/status');

      print('✅ Verification status response: ${response.statusCode}');
      return response.data;
    } on DioException catch (e) {
      print('❌ Get verification status error: ${e.message}');
      if (e.response != null) {
        return e.response!.data;
      }
      return {'success': false, 'message': 'Network error: ${e.message}'};
    }
  }

  Future<Map<String, dynamic>> aiChat({
    required String message,
    required List<Map<String, String>> conversationHistory,
  }) async {
    try {
      print('📤 Sending AI chat message...');

      final response = await _dio.post('/api/ai/chat', data: {
        'message': message,
        'conversation_history': conversationHistory,
      });

      print('✅ AI chat response: ${response.statusCode}');
      return response.data;
    } on DioException catch (e) {
      print('❌ AI chat error: ${e.message}');
      if (e.response != null) {
        return e.response!.data;
      }
      return {'success': false, 'message': 'Network error: ${e.message}'};
    }
  }

  // ==================== PRODUCT APIs ====================

  Future<Map<String, dynamic>> getProducts({
    String? category,
    String? jewellerId,
    double? minPrice,
    double? maxPrice,
    String? search,
  }) async {
    try {
      print('📤 Getting products...');

      final Map<String, dynamic> queryParams = {};
      if (category != null) queryParams['category'] = category;
      if (jewellerId != null) queryParams['jeweller_id'] = jewellerId;
      if (minPrice != null) queryParams['min_price'] = minPrice;
      if (maxPrice != null) queryParams['max_price'] = maxPrice;
      if (search != null) queryParams['search'] = search;

      final response = await _dio.get(
        '/api/products',
        queryParameters: queryParams,
      );

      print('✅ Products response: ${response.statusCode}');
      return response.data;
    } on DioException catch (e) {
      print('❌ Products error: ${e.message}');
      if (e.response != null) {
        return e.response!.data;
      }
      return {'success': false, 'message': 'Network error: ${e.message}'};
    }
  }

  Future<Map<String, dynamic>> getProductById(String productId) async {
    try {
      print('📤 Getting product: $productId');

      final response = await _dio.get('/api/products/$productId');

      print('✅ Product response: ${response.statusCode}');
      return response.data;
    } on DioException catch (e) {
      print('❌ Product error: ${e.message}');
      if (e.response != null) {
        return e.response!.data;
      }
      return {'success': false, 'message': 'Network error: ${e.message}'};
    }
  }

  Future<Map<String, dynamic>> addProduct({
    required String jewellerId,
    required String name,
    required String description,
    required String category,
    required double price,
    required double weight,
    required String karat,
    required String primaryImageUrl,
    List<String>? additionalImages,
    bool isCustomizable = false,
  }) async {
    try {
      print('📤 Adding product: $name');

      final response = await _dio.post(
        '/api/products',
        data: {
          'jeweller_id': jewellerId,
          'name': name,
          'description': description,
          'category': category,
          'price': price,
          'weight': weight,
          'karat': karat,
          'primary_image_url': primaryImageUrl,
          'additional_images': additionalImages ?? [],
          'is_customizable': isCustomizable,
        },
      );

      print('✅ Add product response: ${response.statusCode}');
      return response.data;
    } on DioException catch (e) {
      print('❌ Add product error: ${e.message}');
      if (e.response != null) {
        return e.response!.data;
      }
      return {'success': false, 'message': 'Network error: ${e.message}'};
    }
  }

  // ==================== CHAT APIs ====================

  /// Start or get an existing chat thread between customer and jeweller
  Future<Map<String, dynamic>> startChat({
    required String customerId,
    required String jewellerId,
    String? productId,
  }) async {
    try {
      print('📤 Starting chat...');

      final response = await _dio.post(
        '/api/chat/start',
        data: {
          'customer_id': customerId,
          'jeweller_id': jewellerId,
          'product_id': productId,
        },
      );

      print('✅ Chat started: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('❌ Start chat error: ${e.message}');
      if (e.response != null) {
        return e.response!.data;
      }
      return {'success': false, 'message': 'Network error: ${e.message}'};
    }
  }

  /// Get all chat threads for a user (works for both customer and jeweller)
  Future<Map<String, dynamic>> getChatThreads(String userId) async {
    try {
      print('📤 Getting chat threads for: $userId');

      final response = await _dio.get('/api/chat/threads/$userId');

      print('✅ Got ${response.data['count']} threads');
      return response.data;
    } on DioException catch (e) {
      print('❌ Get threads error: ${e.message}');
      if (e.response != null) {
        return e.response!.data;
      }
      return {'success': false, 'message': 'Network error: ${e.message}'};
    }
  }

  /// Get all messages in a specific chat thread
  Future<Map<String, dynamic>> getMessages(String threadId) async {
    try {
      print('📤 Getting messages for thread: $threadId');

      final response = await _dio.get('/api/chat/$threadId/messages');

      print('✅ Got ${response.data['count']} messages');
      return response.data;
    } on DioException catch (e) {
      print('❌ Get messages error: ${e.message}');
      if (e.response != null) {
        return e.response!.data;
      }
      return {'success': false, 'message': 'Network error: ${e.message}'};
    }
  }

  /// Send a text message in a chat thread
  Future<Map<String, dynamic>> sendMessage({
    required String threadId,
    required String senderId,
    required String message,
    String messageType = 'text',
  }) async {
    try {
      print('📤 Sending message...');

      final response = await _dio.post(
        '/api/chat/send',
        data: {
          'thread_id': threadId,
          'sender_id': senderId,
          'message': message,
          'message_type': messageType,
        },
      );

      print('✅ Message sent');
      return response.data;
    } on DioException catch (e) {
      print('❌ Send message error: ${e.message}');
      if (e.response != null) {
        return e.response!.data;
      }
      return {'success': false, 'message': 'Network error: ${e.message}'};
    }
  }

  /// Mark all unread messages in a thread as read for a specific user
  Future<Map<String, dynamic>> markMessagesAsRead({
    required String threadId,
    required String userId,
  }) async {
    try {
      print('📤 Marking messages as read...');

      final response = await _dio.post(
        '/api/chat/read',
        data: {'thread_id': threadId, 'user_id': userId},
      );

      print('✅ Messages marked as read');
      return response.data;
    } on DioException catch (e) {
      print('❌ Mark as read error: ${e.message}');
      if (e.response != null) {
        return e.response!.data;
      }
      return {'success': false, 'message': 'Network error: ${e.message}'};
    }
  }
}
