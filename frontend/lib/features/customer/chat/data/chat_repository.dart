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
      final response = await _apiClient.dio.get('/chat/threads/$userId');

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch chat threads');
      }

      final data = response.data;
      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Invalid response');
      }

      final threads = (data['threads'] as List? ?? [])
          .map((t) => Map<String, dynamic>.from(t as Map))
          .toList();

      print('✅ Fetched ${threads.length} chat threads');
      return threads;
    } on DioException catch (e) {
      print('❌ Error fetching chat threads: ${e.message}');
      rethrow;
    }
  }

  /// Get messages in a chat thread
  Future<List<Map<String, dynamic>>> getMessages(String threadId) async {
    try {
      print('📨 Fetching messages for thread: $threadId');
      final response = await _apiClient.dio.get('/chat/$threadId/messages');

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch messages');
      }

      final data = response.data;
      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Invalid response');
      }

      final messages = (data['messages'] as List? ?? [])
          .map((m) => Map<String, dynamic>.from(m as Map))
          .toList();

      print('✅ Fetched ${messages.length} messages');
      return messages;
    } on DioException catch (e) {
      print('❌ Error fetching messages: ${e.message}');
      rethrow;
    }
  }

  /// Send a message
  Future<Map<String, dynamic>> sendMessage({
    required String threadId,
    required String content,
  }) async {
    try {
      print('📤 Sending message to thread: $threadId');
      final response = await _apiClient.dio.post(
        '/chat/send',
        data: {
          'thread_id': threadId,
          'content': content,
        },
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to send message');
      }

      final data = response.data;
      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Invalid response');
      }

      print('✅ Message sent successfully');
      return Map<String, dynamic>.from((data['data'] ?? {}) as Map);
    } on DioException catch (e) {
      print('❌ Error sending message: ${e.message}');
      rethrow;
    }
  }

  /// Start a chat with a jeweler
  Future<Map<String, dynamic>> startChatWithJeweller({
    required String jewellerId,
  }) async {
    try {
      final currentUserId = await getCurrentUserId();
      if (currentUserId == null || currentUserId.isEmpty) {
        throw Exception('Missing current user session');
      }

      print('🔗 Starting chat with jeweler: $jewellerId');
      final response = await _apiClient.dio.post(
        '/chat/start',
        data: {
          'customer_id': currentUserId,
          'jeweller_id': jewellerId,
        },
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to start chat');
      }

      final data = response.data;
      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Invalid response');
      }

      print('✅ Chat started/retrieved successfully');
      return Map<String, dynamic>.from((data['thread'] ?? {}) as Map);
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
  Future<void> markAsRead(String threadId) async {
    try {
      final currentUserId = await getCurrentUserId();
      if (currentUserId == null || currentUserId.isEmpty) {
        return;
      }

      print('✅ Marking messages as read for thread: $threadId');
      await _apiClient.dio.post(
        '/chat/read',
        data: {
          'thread_id': threadId,
          'user_id': currentUserId,
        },
      );
    } catch (e) {
      print('❌ Error marking as read: $e');
      // Don't rethrow - this is not critical
    }
  }
}
