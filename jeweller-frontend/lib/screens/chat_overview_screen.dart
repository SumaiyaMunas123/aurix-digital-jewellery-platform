import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'chat_thread_screen.dart';

class ChatOverviewScreen extends StatefulWidget {
  const ChatOverviewScreen({super.key});

  @override
  State<ChatOverviewScreen> createState() => _ChatOverviewScreenState();
}

class _ChatOverviewScreenState extends State<ChatOverviewScreen> {
  static const Color primaryColor = Color(0xFFD4AF35);

  final ApiService _apiService = ApiService();
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _allChats = [];
  bool _isLoading = true;
  String? _customerId;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() => _isLoading = true);

    try {
      // Get customer ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      _customerId =
          prefs.getString('user_id') ?? prefs.getString('customer_id');

      if (_customerId == null) {
        print('❌ No customer ID found');
        setState(() => _isLoading = false);
        return;
      }

      print('📱 Loading chats for customer: $_customerId');

      // Get chat threads from backend
      final result = await _apiService.getChatThreads(_customerId!);

      if (result['success'] == true) {
        setState(() {
          _allChats = result['threads'] ?? [];
          _isLoading = false;
        });
        print('✅ Loaded ${_allChats.length} chats');
      } else {
        print('❌ Failed to load chats: ${result['message']}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('❌ Error loading chats: $e');
      setState(() => _isLoading = false);
    }
  }

  void _openChat(BuildContext context, dynamic chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatThreadScreen(
          threadId: chat['id'],
          shopName:
              chat['jeweller']['business_name'] ?? chat['jeweller']['name'],
          jewellerId: chat['jeweller']['id'],
          customerId: _customerId!,
          onMessageSent: () {
            // Refresh chat list when returning
            _loadChats();
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
            final name =
                (chat['jeweller']['business_name'] ??
                        chat['jeweller']['name'] ??
                        '')
                    .toLowerCase();
            final message = (chat['last_message'] ?? '').toLowerCase();
            final query = _searchQuery.toLowerCase();
            return name.contains(query) || message.contains(query);
          }).toList();

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF201D12)
          : const Color(0xFFF5F5F5),
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
                      Icons.refresh,
                      color: isDark ? Colors.white : const Color(0xFF171612),
                    ),
                    onPressed: _loadChats,
                  ),
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
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    )
                  : filteredChats.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _searchQuery.isEmpty
                                ? Icons.chat_bubble_outline
                                : Icons.search_off,
                            size: 80,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No conversations yet'
                                : 'No chats found for "$_searchQuery"',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.grey[500]
                                  : Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_searchQuery.isNotEmpty) ...[
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
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadChats,
                      color: primaryColor,
                      child: ListView.builder(
                        itemCount: filteredChats.length,
                        itemBuilder: (context, index) {
                          final chat = filteredChats[index];
                          return ChatTile(
                            chat: chat,
                            onTap: () => _openChat(context, chat),
                            isDark: isDark,
                          );
                        },
                      ),
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
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
      ),
    );
  }
}

// Chat Tile Widget
class ChatTile extends StatelessWidget {
  final dynamic chat;
  final VoidCallback onTap;
  final bool isDark;

  const ChatTile({
    super.key,
    required this.chat,
    required this.onTap,
    required this.isDark,
  });

  static const Color primaryColor = Color(0xFFD4AF35);

  @override
  Widget build(BuildContext context) {
    final jeweller = chat['jeweller'];
    final product = chat['product'];
    final name = jeweller['business_name'] ?? jeweller['name'] ?? 'Unknown';
    final lastMessage = chat['last_message'] ?? 'No messages yet';
    final unreadCount = chat['unread_count'] ?? 0;

    // Format time
    String time = 'Recently';
    if (chat['last_message_at'] != null) {
      try {
        final DateTime messageTime = DateTime.parse(chat['last_message_at']);
        final now = DateTime.now();
        final difference = now.difference(messageTime);

        if (difference.inMinutes < 60) {
          time = '${difference.inMinutes}m ago';
        } else if (difference.inHours < 24) {
          time = '${difference.inHours}h ago';
        } else if (difference.inDays < 7) {
          time = '${difference.inDays}d ago';
        } else {
          time = '${messageTime.day}/${messageTime.month}/${messageTime.year}';
        }
      } catch (e) {
        time = 'Recently';
      }
    }

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
            // Avatar
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
                  if (product != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Re: ${product['name']}',
                      style: TextStyle(fontSize: 12, color: primaryColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
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
                    color: unreadCount > 0
                        ? primaryColor
                        : (isDark ? Colors.grey[500] : Colors.grey[600]),
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
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
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
            ),
          ],
        ),
      ),
    );
  }
}
