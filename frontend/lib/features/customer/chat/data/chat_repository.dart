import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/token_service.dart';

class ChatRepository {
  final _apiClient = ApiClient.instance;

  Future<String?> getCurrentUserId() {
    return TokenService.getUserId();
  }

  Future<String?> getCurrentUserRole() {
    return TokenService.getUserRole();
  }

  /// Get all chat threads for a user
  Future<List<Map<String, dynamic>>> getChatThreads(String userId) async {
    try {
      print('💬 Fetching chat threads for user: $userId');
      // Send GET request to /chat/threads/{userId}
      final response = await _apiClient.dio.get('/chat/threads/$userId');

      // Ensure the request was successful
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch chat threads');
      }

      final data = response.data;
      // Backend wrapper structure usually has a 'success' boolean flag
      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Invalid response');
      }

      // Extract the 'data' array and map each item to a Map<String, dynamic>
      final threads = (data['data'] as List? ?? [])
          .map((t) => Map<String, dynamic>.from(t as Map))
          .toList();

      print('✅ Fetched ${threads.length} chat threads');
      return threads;
    } on DioException catch (e) {
      // Catch DIO network exceptions specifically
      print('❌ Error fetching chat threads: ${e.message}');
      rethrow;
    }
  }

  /// Get messages in a specific chat thread by its thread ID
  Future<List<Map<String, dynamic>>> getMessages(String threadId) async {
    try {
      print('📨 Fetching messages for thread: $threadId');
      // Request messages for the specific thread
      final response = await _apiClient.dio.get('/chat/$threadId/messages');

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch messages');
      }

      final data = response.data;
      // Check for backend success structure
      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Invalid response');
      }

      // Convert dynamic list to strongly-typed List<Map>
      final messages = (data['data'] as List? ?? [])
          .map((m) => Map<String, dynamic>.from(m as Map))
          .toList();

      print('✅ Fetched ${messages.length} messages');
      return messages;
    } on DioException catch (e) {
      print('❌ Error fetching messages: ${e.message}');
      rethrow;
    }
  }

  /// Send a text message to a specific thread
  Future<Map<String, dynamic>> sendMessage({
    required String threadId,
    required String senderId,
    required String content,
  }) async {
    try {
      print('📤 Sending message to thread: $threadId from sender: $senderId');
      // POST the new message to the send endpoint
      final response = await _apiClient.dio.post(
        '/chat/send',
        data: {
          'thread_id': threadId,
          'sender_id': senderId,
          'message': content, // The actual chat text
        },
      );

      // Check for Created status (201)
      if (response.statusCode != 201) {
        throw Exception('Failed to send message');
      }

      final data = response.data;
      // Handle success wrapper from backend
      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Invalid response');
      }

      print('✅ Message sent successfully');
      // Return the created message object
      return Map<String, dynamic>.from((data['data'] ?? {}) as Map);
    } on DioException catch (e) {
      print('❌ Error sending message: ${e.message}');
      rethrow;
    }
  }

  /// Start a new chat thread with a specific jeweler (if it doesn't already exist)
  Future<Map<String, dynamic>> startChat({
    required String jewellerId,
  }) async {
    try {
      print('🔗 Starting chat with jeweler: $jewellerId');
      // Route sends request to initialize connection with jeweler
      final response = await _apiClient.dio.post(
        '/chat/start',
        data: {
          'other_user_id': jewellerId,
        },
      );

      // Accept both 201 (Created) and 200 (OK - existing thread returned)
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to start chat');
      }

      final data = response.data;
      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Invalid response');
      }

      print('✅ Chat started/retrieved successfully');
      // Return the thread metadata to be used in UI
      return data['data'] ?? {};
    } on DioException catch (e) {
      print('❌ Error starting chat: ${e.message}');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> searchJewellers(String search) async {
    try {
      final response = await _apiClient.dio.get(
        '/chat/jewellers',
        queryParameters: {'search': search},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to search jewellers');
      }

      final data = response.data;
      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Invalid response');
      }

      final jewellers = (data['jewellers'] as List? ?? [])
          .map((j) => Map<String, dynamic>.from(j as Map))
          .toList();

      return jewellers;
    } on DioException catch (e) {
      print('❌ Error searching jewellers: ${e.message}');
      rethrow;
    }
  }

  /// Mark messages as read
  Future<void> markAsRead({
    required String threadId,
    required String userId,
  }) async {
    try {
      print('✅ Marking messages as read for thread: $threadId');
      await _apiClient.dio.post(
        '/chat/read',
        data: {
          'thread_id': threadId,
        },
      );
    } catch (e) {
      print('❌ Error marking as read: $e');
      // Don't rethrow - this is not critical
    }
  }

  /// Share AI design in chat
  Future<Map<String, dynamic>> shareAIDesign({
    required String threadId,
    required String senderId,
    required String aiDesignId,
  }) async {
    try {
      print('🎨 Sharing AI design: $aiDesignId to thread: $threadId');
      final response = await _apiClient.dio.post(
        '/chat/share-design',
        data: {
          'thread_id': threadId,
          'sender_id': senderId,
          'ai_design_id': aiDesignId,
        },
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to share AI design');
      }

      final data = response.data;
      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Invalid response');
      }

      print('✅ AI design shared successfully');
      return data['data'] ?? {};
    } on DioException catch (e) {
      print('❌ Error sharing AI design: ${e.message}');
      rethrow;
    }
  }
}
