import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:aurix/features/customer/chat/models/chat_message.dart';
import 'package:aurix/features/customer/chat/data/chat_repository.dart';
import 'package:aurix/core/theme/app_colors.dart';

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
        setState(() {
          _messages = data.map((m) {
            return ChatMessage(
              id: m['id']?.toString() ?? '',
              text: m['message_text'] ?? m['content'] ?? m['message'] ?? '',
              isMe: m['sender_id'] == _currentUserId,
              time: m['created_at'] != null
                  ? DateTime.parse(m['created_at'])
                  : DateTime.now(),
            );
          }).toList();
        });
        _scrollToBottom();
      });
    } else {
      // Fallback sample data if no thread
      setState(() {
        _messages = [
          ChatMessage(
            id: "1",
            text: "Hi! How can I help you today?",
            isMe: false,
            time: DateTime.now().subtract(const Duration(minutes: 5)),
          ),
          ChatMessage(
            id: "2",
            text: "I want a 22K ring design.",
            isMe: true,
            time: DateTime.now().subtract(const Duration(minutes: 3)),
          ),
          ChatMessage(
            id: "3",
            text: "Great! We have some beautiful 22K designs.",
            isMe: false,
            time: DateTime.now().subtract(const Duration(minutes: 1)),
          ),
        ];
      });
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
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

    _controller.clear();
    _scrollToBottom();

    // Try to send to backend
    if (widget.threadId != null && widget.threadId!.isNotEmpty) {
      try {
        await _chatRepository.sendMessage(
          threadId: widget.threadId!,
          content: text,
        );
        print('✅ Message sent successfully');
      } catch (e) {
        print('⚠️ Failed to send message: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send: $e")),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    HapticFeedback.lightImpact();
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (picked == null) return;

      setState(() {
        _messages.add(ChatMessage(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          imagePath: picked.path,
          isMe: true,
          time: DateTime.now(),
        ));
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image pick failed: $e")),
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
              child: ListView.builder(
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
    final isMe = m.isMe;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bubbleColor = isMe
        ? AppColors.gold.withValues(alpha: 0.95)
        : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06));

    final textColor = isMe ? Colors.black : (isDark ? Colors.white : Colors.black);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: m.hasImage ? 280 : 260),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(18),
          border: isMe
              ? null
              : Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08)),
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
              Text(m.text!, style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
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
        border: Border(top: BorderSide(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08))),
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
                hintText: "Message…",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.10)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.10)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(color: AppColors.gold.withValues(alpha: 0.6)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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