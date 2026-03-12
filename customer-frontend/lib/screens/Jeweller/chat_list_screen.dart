import 'package:flutter/material.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  ChatListScreen({super.key});

  static const Color gold = Color(0xFFD4AF37);
  static const Color card = Color(0xFF141414);

  final List<_ChatPreview> chats = [
    _ChatPreview(
      name: 'Nimal Perera',
      lastMessage: 'Can you share the breakdown?',
      time: '10:32 AM',
      unread: 2,
    ),
    _ChatPreview(
      name: 'Sithumi Jayasinghe',
      lastMessage: 'Please check the design.',
      time: 'Yesterday',
      unread: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Messages', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final c = chats[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(chatName: c.name),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: gold.withOpacity(0.2),
                    child: Text(
                      c.name[0],
                      style: const TextStyle(
                        color: gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          c.lastMessage,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    c.time,
                    style: const TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ChatPreview {
  final String name;
  final String lastMessage;
  final String time;
  final int unread;

  _ChatPreview({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unread,
  });
}