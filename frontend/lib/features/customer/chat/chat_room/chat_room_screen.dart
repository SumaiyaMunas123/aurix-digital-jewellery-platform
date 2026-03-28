import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:aurix/core/theme/app_colors.dart';
import 'package:aurix/features/customer/chat/data/chat_repository.dart';
import 'package:aurix/features/customer/chat/models/chat_message.dart';

class ChatRoomScreen extends StatefulWidget {
  final String title;
  final String? threadId;

  const ChatRoomScreen({
    super.key,
    required this.title,
    this.threadId,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _picker = ImagePicker();
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final _chatRepository = ChatRepository();

  bool _loading = true;
  String? _currentUserId;
  Timer? _pollTimer;
  List<ChatMessage> _messages = [];
  StreamSubscription<List<Map<String, dynamic>>>? _messageSubscription;
  final _currentUserId = Supabase.instance.client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _setupRealtimeChat();
  }

  void _setupRealtimeChat() {
    if (widget.threadId != null && widget.threadId!.isNotEmpty) {
      _messageSubscription = Supabase.instance.client
          .from('chat_messages')
          .stream(primaryKey: ['id'])
          .eq('thread_id', widget.threadId!)
          .order('created_at', ascending: true)
          .listen((data) {
        if (!mounted) return;

        final loaded = raw.map((m) {
          final senderId = (m['sender_id'] ?? '').toString();
          final messageText =
              (m['message_text'] ?? m['content'] ?? m['message'] ?? '')
                  .toString();
          return ChatMessage(
            id: m['id']?.toString() ?? '',
            text: messageText,
            isMe: _currentUserId != null && senderId == _currentUserId,
            time: m['created_at'] != null
                ? DateTime.tryParse(m['created_at'].toString()) ??
                    DateTime.now()
                : DateTime.now(),
          );
        }).toList();

        setState(() {
          _messages = loaded;
          _loading = false;
        });

        if (_currentUserId != null && _currentUserId!.isNotEmpty) {
          await _chatRepository.markAsRead(widget.threadId!);
        }

        _scrollToBottom();
        return;
      } catch (_) {
        if (!mounted) return;
        setState(() => _loading = false);
        return;
      }
    }

    if (!mounted) return;
    setState(() {
      _messages = [];
      _loading = false;
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendText() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.selectionClick();

    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          text: text,
          isMe: true,
          time: DateTime.now(),
        ),
      );
      _controller.clear();
    });

    _scrollToBottom();

    // Try to send to backend
    if (widget.threadId != null && widget.threadId!.isNotEmpty) {
      try {
        await _chatRepository.sendMessage(
          threadId: _activeThreadId!,
          senderId: _currentUserId!,
          content: text,
        );
        await _loadMessages(showLoader: false);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    HapticFeedback.lightImpact();

    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (picked == null) return;

      setState(() {
        _messages.add(
          ChatMessage(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            imagePath: picked.path,
            isMe: true,
            time: DateTime.now(),
          ),
        );
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image pick failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      itemCount: _messages.length,
                      itemBuilder: (context, i) => _Bubble(m: _messages[i]),
                    ),
            ),
            _InputBar(
              controller: _controller,
              onPickImage: _pickImage,
              onSend: _sendText,
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage m;

  const _Bubble({required this.m});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bubbleColor = m.isMe
        ? AppColors.gold.withValues(alpha: 0.95)
        : (isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.06));

    final textColor =
        m.isMe ? Colors.black : (isDark ? Colors.white : Colors.black);

    return Align(
      alignment: m.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: m.hasImage ? 280 : 260),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(18),
          border: m.isMe
              ? null
              : Border.all(
                  color: (isDark ? Colors.white : Colors.black)
                      .withValues(alpha: 0.08),
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (m.hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  File(m.imagePath!),
                  height: 180,
                  width: 260,
                  fit: BoxFit.cover,
                ),
              ),
            if (m.hasImage && m.hasText) const SizedBox(height: 8),
            if (m.hasText)
              Text(
                m.text!,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
              ),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onPickImage;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.onPickImage,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        border: Border(
          top: BorderSide(
            color:
                (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onPickImage,
            icon: const Icon(Icons.add_photo_alternate_outlined),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'Message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(
                    color: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: 0.10),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(
                    color: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: 0.10),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(
                    color: AppColors.gold.withValues(alpha: 0.6),
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            onPressed: onSend,
            icon: const Icon(Icons.send_rounded),
          ),
        ],
      ),
    );
  }
}
