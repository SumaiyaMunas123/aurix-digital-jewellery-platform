import 'package:flutter/material.dart';
import 'chat_thread_screen.dart';

class ChatOverviewScreen extends StatefulWidget {
  const ChatOverviewScreen({super.key});

  @override
  State<ChatOverviewScreen> createState() => _ChatOverviewScreenState();
}

class _ChatOverviewScreenState extends State<ChatOverviewScreen> {
  static const Color primaryColor = Color(0xFFD4AF35);
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  Map<String, int> _unreadCounts = {
    'luxe': 2,
    'cartier': 1,
    'tiffany': 0,
    'bvlgari': 0,
    'veni': 3,
    'diamond_palace': 0,
    'gold_house': 1,
    'royal_gems': 0,
    'sapphire': 0,
    'pearl_boutique': 0,
    'crystal_jewels': 2,
    'emerald_creations': 0,
  };

  final List<Map<String, String>> _allChats = [
    {'id': 'luxe', 'name': 'LUXE Jewellers', 'message': 'This looks perfect! Thank you.', 'time': '10:45 AM'},
    {'id': 'cartier', 'name': 'Cartier', 'message': 'Can you confirm the carat size?', 'time': '9:30 AM'},
    {'id': 'tiffany', 'name': 'Tiffany & Co.', 'message': 'Yes, we have that ring in stock.', 'time': 'Yesterday'},
    {'id': 'bvlgari', 'name': 'Bvlgari', 'message': 'Thank you for your purchase!', 'time': 'Yesterday'},
    {'id': 'veni', 'name': 'Veni Jewellers', 'message': 'Your custom piece is ready!', 'time': '2 days ago'},
    {'id': 'diamond_palace', 'name': 'Diamond Palace', 'message': 'We received your inquiry.', 'time': '3 days ago'},
    {'id': 'gold_house', 'name': 'Gold House', 'message': 'New designs available!', 'time': '4 days ago'},
    {'id': 'royal_gems', 'name': 'Royal Gems', 'message': 'Your order has been shipped.', 'time': '5 days ago'},
    {'id': 'sapphire', 'name': 'Sapphire Collection', 'message': 'Thank you for visiting our store.', 'time': '1 week ago'},
    {'id': 'pearl_boutique', 'name': 'Pearl Boutique', 'message': 'Your quotation is ready.', 'time': '1 week ago'},
    {'id': 'crystal_jewels', 'name': 'Crystal Jewels', 'message': 'Special discount this weekend!', 'time': '2 weeks ago'},
    {'id': 'emerald_creations', 'name': 'Emerald Creations', 'message': 'We\'d love to hear your feedback.', 'time': '2 weeks ago'},
  ];

  void _openChat(BuildContext context, String chatId, String shopName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatThreadScreen(
          onViewed: () {
            setState(() => _unreadCounts[chatId] = 0);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter chats based on search query
    final filteredChats = _searchQuery.isEmpty
        ? _allChats
        : _allChats.where((chat) {
            final name = chat['name']!.toLowerCase();
            final message = chat['message']!.toLowerCase();
            final query = _searchQuery.toLowerCase();
            return name.contains(query) || message.contains(query);
          }).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF201D12) : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: isDark ? const Color(0xFF2A271A) : Colors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: isDark ? Colors.white : const Color(0xFF171612),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Chats',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF171612),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.edit_square,
                      color: isDark ? Colors.white : const Color(0xFF171612),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('New chat')),
                      );
                    },
                  )
                ],
              ),
            ),
            // Search Bar
            _SearchBar(
              isDark: isDark,
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onClear: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
              hasText: _searchQuery.isNotEmpty,
            ),
            // Chat List
            Expanded(
              child: filteredChats.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No chats found for "$_searchQuery"',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.grey[500] : Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            child: const Text(
                              'Clear search',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredChats.length,
                      itemBuilder: (context, index) {
                        final chat = filteredChats[index];
                        return ChatTile(
                          chatId: chat['id']!,
                          name: chat['name']!,
                          message: chat['message']!,
                          time: chat['time']!,
                          unreadCount: _unreadCounts[chat['id']!]!,
                          onTap: () => _openChat(context, chat['id']!, chat['name']!),
                          isDark: isDark,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Search Bar Widget
class _SearchBar extends StatelessWidget {
  final bool isDark;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool hasText;

  const _SearchBar({
    required this.isDark,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.hasText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search for jewellers or messages',
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[500] : Colors.grey[600],
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          suffixIcon: hasText
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  onPressed: onClear,
                )
              : null,
          filled: true,
          fillColor: isDark ? const Color(0xFF201D12) : const Color(0xFFF1F1F1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}

// Chat Tile Widget
class ChatTile extends StatelessWidget {
  final String chatId;
  final String name;
  final String message;
  final String time;
  final int unreadCount;
  final VoidCallback onTap;
  final bool isDark;

  const ChatTile({
    super.key,
    required this.chatId,
    required this.name,
    required this.message,
    required this.time,
    required this.onTap,
    required this.isDark,
    this.unreadCount = 0,
  });

  static const Color primaryColor = Color(0xFFD4AF35);

  @override
  Widget build(BuildContext context) {
    final bool isRead = unreadCount == 0;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF201D12) : const Color(0xFFF5F5F5),
          border: Border(
            bottom: BorderSide(
              color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Avatar placeholder
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.store,
                size: 28,
                color: primaryColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color: isRead
                          ? (isDark ? Colors.grey[500] : Colors.grey[600])
                          : (isDark ? Colors.grey[400] : Colors.grey[700]),
                      fontWeight: isRead ? FontWeight.normal : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: unreadCount > 0 ? primaryColor : (isDark ? Colors.grey[500] : Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 6),
                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 22,
                      minHeight: 22,
                    ),
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  const SizedBox(height: 22),
              ],
            )
          ],
        ),
      ),
    );
  }
}
