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
  String? _currentUserId;
  String? _currentUserRole;

  @override
  void initState() {
    super.initState();
    _chatsFuture = _loadChats();
  }

  Future<List<Map<String, dynamic>>> _loadChats() async {
    try {
      final resolvedUserId =
          (widget.userId != null && widget.userId!.isNotEmpty)
              ? widget.userId!
              : await _chatRepository.getCurrentUserId();

      final resolvedRole = await _chatRepository.getCurrentUserRole();

      _currentUserId = resolvedUserId;
      _currentUserRole = resolvedRole;

      if (resolvedUserId == null || resolvedUserId.isEmpty) {
        return [];
      }

      final threads = await _chatRepository.getChatThreads(resolvedUserId);
      print('✅ Loaded ${threads.length} chats from backend');

      return threads.map((t) {
        final isCustomer = t['customer_id'] == resolvedUserId;

        return {
          'id': t['id'],
          'name': isCustomer
              ? (t['jeweller']?['business_name'] ??
                  t['jeweller']?['name'] ??
                  'Jeweller')
              : (t['customer']?['name'] ?? 'Customer'),
          'last': t['last_message'] ?? 'No messages yet',
          'unread': t['unread_count'] ?? 0,
        };
      }).toList();
    } catch (e) {
      print('⚠️ Failed to load chats from backend: $e');
      return [];
    }
  }

  Future<void> _refreshChats() async {
    setState(() {
      _chatsFuture = _loadChats();
    });
  }

  Future<void> _openStartChatSheet() async {
    if (_currentUserRole == 'jeweller') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only customers can start a new chat.')),
      );
      return;
    }

    final selected = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _StartChatSheet(repository: _chatRepository),
    );

    if (!mounted || selected == null) return;

    final jewellerId = (selected['id'] ?? '').toString();
    final jewellerName = (selected['display_name'] ??
            selected['business_name'] ??
            selected['name'] ??
            'Jeweller')
        .toString();

    if (jewellerId.isEmpty) return;

    try {
      final thread = await _chatRepository.startChatWithJeweller(
        jewellerId: jewellerId,
      );

      await _refreshChats();

      if (!mounted) return;
      Nav.push(
        context,
        ChatRoomScreen(
          title: jewellerName,
          threadId: (thread['id'] ?? '').toString(),
          currentUserId: _currentUserId,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start chat: $e')),
      );
    }
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
            if (_currentUserRole != 'jeweller')
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openStartChatSheet,
                    icon: const Icon(Icons.add_comment_outlined),
                    label: const Text('Start New Chat'),
                  ),
                ),
              ),
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
                        currentUserId: _currentUserId,
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

class _StartChatSheet extends StatefulWidget {
  final ChatRepository repository;

  const _StartChatSheet({required this.repository});

  @override
  State<_StartChatSheet> createState() => _StartChatSheetState();
}

class _StartChatSheetState extends State<_StartChatSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  List<Map<String, dynamic>> _results = [];

  @override
  void initState() {
    super.initState();
    _runSearch();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _runSearch() async {
    setState(() => _loading = true);
    try {
      final items =
          await widget.repository.searchJewellers(_controller.text.trim());
      if (!mounted) return;
      setState(() {
        _results = items.map((j) {
          final displayName =
              (j['business_name'] ?? j['name'] ?? 'Jeweller').toString();
          return {
            ...j,
            'display_name': displayName,
          };
        }).toList();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _results = [];
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      child: SizedBox(
        height: 480,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Start New Chat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _runSearch(),
                    decoration: const InputDecoration(
                      hintText: 'Search jewellers',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _runSearch,
                  child: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isEmpty
                      ? const Center(child: Text('No jewellers found'))
                      : ListView.separated(
                          itemCount: _results.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final jeweller = _results[index];
                            final displayName =
                                jeweller['display_name'].toString();
                            final subtitle =
                                (jeweller['name'] ?? jeweller['email'] ?? '')
                                    .toString();

                            return ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.storefront_rounded),
                              ),
                              title: Text(displayName),
                              subtitle:
                                  subtitle.isEmpty ? null : Text(subtitle),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () => Navigator.pop(context, jeweller),
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
