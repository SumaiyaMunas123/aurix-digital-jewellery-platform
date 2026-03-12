import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

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
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('user_id');

      if (_userId == null) {
        print('❌ No user ID found in SharedPreferences');
        setState(() => _isLoading = false);
        return;
      }

      print('📱 Loading chats for user: $_userId');

      final result = await _apiService.getChatThreads(_userId!);

      if (result['success'] == true) {
        setState(() {
          _allChats = result['threads'] ?? [];
          _isLoading = false;
        });
        print('✅ Loaded ${_allChats.length} chats');
      } else {
        print('❌ Failed to load chats: ${result['message']}');
        setState(() {
          _allChats = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading chats: $e');
      setState(() {
        _allChats = [];
        _isLoading = false;
      });
    }
  }

  void _openChat(BuildContext context, dynamic chat) {
    if (_userId == null) return;

    final isCustomer = chat['customer_id'] == _userId;
    final otherUser = isCustomer ? chat['jeweller'] : chat['customer'];

    if (otherUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Could not load chat participant info'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/chat-thread',
      arguments: {
        'threadId': chat['id'] ?? '',
        'shopName': otherUser['business_name'] ?? otherUser['name'] ?? 'Chat',
        'jewellerId': chat['jeweller_id'] ?? '',
        'customerId': chat['customer_id'] ?? '',
      },
    ).then((_) {
      _loadChats();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredChats = _searchQuery.isEmpty
        ? _allChats
        : _allChats.where((chat) {
            final isCustomer = chat['customer_id'] == _userId;
            final otherUser = isCustomer ? chat['jeweller'] : chat['customer'];
            final name =
                (otherUser?['business_name'] ?? otherUser?['name'] ?? '')
                    .toString()
                    .toLowerCase();
            final message = (chat['last_message'] ?? '')
                .toString()
                .toLowerCase();
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
            // ===== TOP BAR =====
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

            // ===== SEARCH BAR =====
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search conversations',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF201D12)
                      : const Color(0xFFF1F1F1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
            ),

            // ===== CHAT LIST =====
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
                          if (_searchQuery.isEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Start chatting from a product page!',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.grey[600]
                                    : Colors.grey[500],
                              ),
                            ),
                          ],
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
                          return _ChatTile(
                            chat: chat,
                            currentUserId: _userId!,
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

// ===== INDIVIDUAL CHAT TILE WIDGET =====
class _ChatTile extends StatelessWidget {
  final dynamic chat;
  final String currentUserId;
  final VoidCallback onTap;
  final bool isDark;

  const _ChatTile({
    required this.chat,
    required this.currentUserId,
    required this.onTap,
    required this.isDark,
  });

  static const Color primaryColor = Color(0xFFD4AF35);

  @override
  Widget build(BuildContext context) {
    final isCustomer = chat['customer_id'] == currentUserId;
    final otherUser = isCustomer ? chat['jeweller'] : chat['customer'];
    final product = chat['product'];
    final name = otherUser?['business_name'] ?? otherUser?['name'] ?? 'Unknown';
    final lastMessage = chat['last_message'] ?? 'No messages yet';
    final unreadCount = chat['unread_count'] ?? 0;

    // Format time
    String time = '';
    if (chat['last_message_at'] != null) {
      try {
        final DateTime messageTime = DateTime.parse(chat['last_message_at']);
        final now = DateTime.now();
        final difference = now.difference(messageTime);

        if (difference.inMinutes < 1) {
          time = 'Just now';
        } else if (difference.inMinutes < 60) {
          time = '${difference.inMinutes}m ago';
        } else if (difference.inHours < 24) {
          time = '${difference.inHours}h ago';
        } else if (difference.inDays < 7) {
          time = '${difference.inDays}d ago';
        } else {
          time = '${messageTime.day}/${messageTime.month}/${messageTime.year}';
        }
      } catch (e) {
        time = '';
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
                color: isDark ? Colors.grey[800] : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.store,
                size: 28,
                color: primaryColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(width: 14),

            // Name + last message
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
                      'Re: ${product['name'] ?? 'Product'}',
                      style: const TextStyle(fontSize: 12, color: primaryColor),
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
                          : (isDark ? Colors.grey[300] : Colors.grey[800]),
                      fontWeight: isRead ? FontWeight.normal : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Time + unread badge
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
