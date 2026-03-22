import 'package:flutter/material.dart';
import 'package:aurix/core/widgets/aurix_glass_card.dart';
import 'package:aurix/core/navigation/nav.dart';
import 'package:aurix/features/customer/chat/chat_room/chat_room_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const chats = [
      {"name": "Luxe Jewels", "last": "Hi! How can we help?"},
      {"name": "Aurora Gold", "last": "We have 22K rings available."},
      {"name": "Ceylon Gems", "last": "Can you share your budget?"},
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      children: [
        const Text("Chats", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        const SizedBox(height: 12),
        ...chats.map((c) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => Nav.push(context, ChatRoomScreen(title: c["name"]!)),
              child: AurixGlassCard(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.storefront_rounded)),
                  title: Text(c["name"]!, style: const TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text(c["last"]!),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}