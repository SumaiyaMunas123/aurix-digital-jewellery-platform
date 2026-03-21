import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

class ChatRepository {
  final _apiClient = ApiClient.instance;

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

      final threads = (data['data'] as List? ?? [])
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
      return data['data'] ?? {};
    } on DioException catch (e) {
      print('❌ Error sending message: ${e.message}');
      rethrow;
    }
  }

  /// Start a chat with a jeweler
  Future<Map<String, dynamic>> startChat({
    required String jewellerId,
  }) async {
    try {
      print('🔗 Starting chat with jeweler: $jewellerId');
      final response = await _apiClient.dio.post(
        '/chat/start',
        data: {
          'other_user_id': jewellerId,
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
      return data['data'] ?? {};
    } on DioException catch (e) {
      print('❌ Error starting chat: ${e.message}');
      rethrow;
    }
  }

  /// Mark messages as read
  Future<void> markAsRead(String threadId) async {
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
}
