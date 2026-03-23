import 'package:flutter/material.dart';
import 'package:aurix/core/widgets/aurix_glass_card.dart';
import 'package:aurix/core/navigation/nav.dart';
import 'package:aurix/features/customer/chat/data/chat_repository.dart';
import 'chat_room/chat_room_screen.dart';

class ChatListScreen extends StatefulWidget {
  final String? userId;

  const ChatListScreen({super.key, this.userId});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _chatRepository = ChatRepository();
  late Future<List<Map<String, dynamic>>> _chatsFuture;

  @override
  void initState() {
    super.initState();
    // Try to fetch real chats, fallback to sample data
    _chatsFuture = _loadChats();
  }

  Future<List<Map<String, dynamic>>> _loadChats() async {
    // If user is logged in, try to fetch from backend
    if (widget.userId != null && widget.userId!.isNotEmpty) {
      try {
        final threads = await _chatRepository.getChatThreads(widget.userId!);
        if (threads.isNotEmpty) {
          print('✅ Loaded ${threads.length} chats from backend');
          return threads.map((t) {
            final isCustomer = t['customer_id'] == widget.userId;
            final otherUser = isCustomer ? t['jeweller'] : t['customer'];
            return {
              'id': t['id'],
              'name': isCustomer 
                  ? (t['jeweller']?['business_name'] ?? t['jeweller']?['name'] ?? 'Jeweler')
                  : (t['customer']?['name'] ?? 'Customer'),
              'last': t['last_message'] ?? 'No messages yet',
              'unread': t['unread_count'] ?? 0,
            };
          }).toList();
        }
      } catch (e) {
        print('⚠️ Failed to load chats from backend: $e');
        // Fall through to sample data
      }
    }

    // Return sample data as fallback
    print('ℹ️ Using sample chat data');
    return [
      {
        'id': 'chat_1',
        'name': 'Luxe Jewels',
        'last': 'Hi! How can we help?',
        'unread': 0,
      },
      {
        'id': 'chat_2',
        'name': 'Aurora Gold',
        'last': 'We have 22K rings available.',
        'unread': 1,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _chatsFuture,
      builder: (context, snapshot) {
        final chats = snapshot.data ?? [];
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
          children: [
            const Text(
              "Chats",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              )
            else if (chats.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No chats yet',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              )
            else
              ...chats.map((c) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => Nav.push(
                      context,
                      ChatRoomScreen(
                        title: c["name"] ?? "Chat",
                        threadId: c["id"],
                      ),
                    ),
                    child: AurixGlassCard(
                      child: ListTile(
                        leading: Badge(
                          isLabelVisible: ((c['unread'] as int?) ?? 0) > 0,
                          label: Text('${c['unread']}'),
                          child: const CircleAvatar(
                            child: Icon(Icons.storefront_rounded),
                          ),
                        ),
                        title: Text(
                          c["name"] ?? "Unknown",
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        subtitle: Text(c["last"] ?? ""),
                        trailing: const Icon(Icons.chevron_right_rounded),
                      ),
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}