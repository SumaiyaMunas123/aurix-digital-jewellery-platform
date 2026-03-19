import 'package:aurix/core/network/api_client.dart';
import 'package:aurix/features/customer/chat/models/chat_message.dart';

class ChatApi {
  static final _dio = ApiClient.instance.dio;

  // Start or get a chat thread
  static Future<String> startThread({
    required String customerId,
    required String jewellerId,
    String? productId,
  }) async {
    final res = await _dio.post('/chat/start', data: {
      'customer_id': customerId,
      'jeweller_id': jewellerId,
      if (productId != null) 'product_id': productId,
    });
    if (res.data['success'] == true) {
      return res.data['thread']['id'] as String;
    }
    throw Exception(res.data['message'] ?? 'Failed to start chat');
  }

  // Get all messages in a thread
  static Future<List<ChatMessage>> getMessages(
      String threadId, String myId) async {
    final res = await _dio.get('/chat/$threadId/messages');
    if (res.data['success'] == true) {
      return (res.data['messages'] as List)
          .map((m) => ChatMessage(
                id: m['id'],
                text: m['message_text'],
                isMe: m['sender_id'] == myId,
                time: DateTime.parse(m['created_at']),
              ))
          .toList();
    }
    throw Exception(res.data['message'] ?? 'Failed to load messages');
  }

  // Send a message
  static Future<void> sendMessage({
    required String threadId,
    required String senderId,
    required String text,
  }) async {
    final res = await _dio.post('/chat/send', data: {
      'thread_id': threadId,
      'sender_id': senderId,
      'message': text,
    });
    if (res.data['success'] != true) {
      throw Exception(res.data['message'] ?? 'Failed to send message');
    }
  }

  // Mark all messages as read
  static Future<void> markAsRead({
    required String threadId,
    required String userId,
  }) async {
    await _dio.post('/chat/read', data: {
      'thread_id': threadId,
      'user_id': userId,
    });
  }
}
