import 'package:dio/dio.dart';

class ApiService {
  // IMPORTANT: Change to your IP address
  static const String baseUrl = 'http://127.0.0.1:5000'; // ← Change for physical device
  
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

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
      print('📤 Jeweller Registration Request');
      
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
      print('✅ Registration Response: ${response.data}');
      return response.data;
      
    } on DioException catch (e) {
      print('❌ Registration Error: ${e.message}');
      if (e.response != null) {
        return e.response!.data;
      }
      return {
        'success': false,
        'message': 'Network error: ${e.message}'
      };
    }
  }

  // ==================== LOGIN (Jeweller) ====================
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('📤 Login Request for: $email');
      
      final response = await _dio.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      print('✅ Login Response: ${response.data}');
      return response.data;
      
    } on DioException catch (e) {
      print('❌ Login Error: ${e.message}');
      if (e.response != null) {
        return e.response!.data;
      }
      return {
        'success': false,
        'message': 'Network error: ${e.message}'
      };
    }
  }

  // ==================== CHECK VERIFICATION STATUS ====================
  Future<Map<String, dynamic>> getVerificationStatus(String jewellerId) async {
    try {
      print('📤 Checking verification status for: $jewellerId');
      
      final response = await _dio.get('/api/admin/jewellers/$jewellerId/status');
      
      print('✅ Status Response: ${response.data}');
      return response.data;
      
    } on DioException catch (e) {
      print('❌ Status Check Error: ${e.message}');
      if (e.response != null) {
        return e.response!.data;
      }
      return {
        'success': false,
        'message': 'Network error: ${e.message}'
      };
    }
  }

  // ==================== ADD PRODUCT (Jeweller) ====================
  Future<Map<String, dynamic>> addProduct({
    required String jewellerId,
    required String name,
    required String description,
    required String category,
    String? priceMode,
    double? price,
    double? weightGrams,
    String? karat,
    String? metalType,
    double? makingCharge,
    int? stockQuantity,
  }) async {
    try {
      print('📤 Adding product: $name');
      
      final Map<String, dynamic> data = {
        'jeweller_id': jewellerId,
        'name': name,
        'description': description,
        'category': category,
        'price_mode': priceMode ?? 'show_price',
      };

      // Add optional fields only if provided
      if (price != null) data['price'] = price;
      if (weightGrams != null) data['weight_grams'] = weightGrams;
      if (karat != null) data['karat'] = karat;
      if (metalType != null) data['metal_type'] = metalType;
      if (makingCharge != null) data['making_charge'] = makingCharge;
      if (stockQuantity != null) data['stock_quantity'] = stockQuantity;

      print('📦 Request data: $data');

      final response = await _dio.post('/api/products', data: data);
      
      print('✅ Product added successfully: ${response.data}');
      return response.data;
      
    } on DioException catch (e) {
      print('❌ Add product error: ${e.message}');
      if (e.response != null) {
        print('❌ Response error: ${e.response!.data}');
        return e.response!.data;
      }
      return {
        'success': false,
        'message': 'Network error: ${e.message}'
      };
    } catch (e) {
      print('❌ Unexpected error: $e');
      return {
        'success': false,
        'message': 'Error: $e'
      };
    }
  }

  // ==================== GET JEWELLER'S PRODUCTS ====================
  Future<Map<String, dynamic>> getJewellerProducts(String jewellerId) async {
    try {
      print('📤 Getting products for jeweller: $jewellerId');
      
      final response = await _dio.get('/api/products/jeweller/$jewellerId');
      
      print('✅ Products fetched: ${response.data}');
      return response.data;
      
    } on DioException catch (e) {
      print('❌ Get products error: ${e.message}');
      if (e.response != null) {
        return e.response!.data;
      }
      return {
        'success': false,
        'message': 'Network error: ${e.message}'
      };
    }
  }

  // ==================== UPDATE PRODUCT ====================
  Future<Map<String, dynamic>> updateProduct({
    required String productId,
    String? name,
    String? description,
    String? category,
    String? priceMode,
    double? price,
    double? weightGrams,
    String? karat,
    String? metalType,
    double? makingCharge,
    int? stockQuantity,
    bool? isAvailable,
  }) async {
    try {
      print('📤 Updating product: $productId');
      
      final Map<String, dynamic> data = {};

      // Add only fields that are provided
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (category != null) data['category'] = category;
      if (priceMode != null) data['price_mode'] = priceMode;
      if (price != null) data['price'] = price;
      if (weightGrams != null) data['weight_grams'] = weightGrams;
      if (karat != null) data['karat'] = karat;
      if (metalType != null) data['metal_type'] = metalType;
      if (makingCharge != null) data['making_charge'] = makingCharge;
      if (stockQuantity != null) data['stock_quantity'] = stockQuantity;
      if (isAvailable != null) data['is_available'] = isAvailable;

      final response = await _dio.put('/api/products/$productId', data: data);
      
      print('✅ Product updated: ${response.data}');
      return response.data;
      
    } on DioException catch (e) {
      print('❌ Update product error: ${e.message}');
      if (e.response != null) {
        return e.response!.data;
      }
      return {
        'success': false,
        'message': 'Network error: ${e.message}'
      };
    }
  }

  // ==================== TOGGLE PRODUCT VISIBILITY ====================
  Future<Map<String, dynamic>> toggleProductVisibility(String productId) async {
    try {
      print('📤 Toggling visibility for: $productId');
      
      final response = await _dio.patch('/api/products/$productId/toggle-visibility');
      
      print('✅ Visibility toggled: ${response.data}');
      return response.data;
      
    } on DioException catch (e) {
      print('❌ Toggle visibility error: ${e.message}');
      if (e.response != null) {
        return e.response!.data;
      }
      return {
        'success': false,
        'message': 'Network error: ${e.message}'
      };
    }
  }

  // ==================== DELETE PRODUCT ====================
  Future<Map<String, dynamic>> deleteProduct(String productId) async {
    try {
      print('📤 Deleting product: $productId');
      
      final response = await _dio.delete('/api/products/$productId');
      
      print('✅ Product deleted: ${response.data}');
      return response.data;
      
    } on DioException catch (e) {
      print('❌ Delete product error: ${e.message}');
      if (e.response != null) {
        return e.response!.data;
      }
      return {
        'success': false,
        'message': 'Network error: ${e.message}'
      };
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