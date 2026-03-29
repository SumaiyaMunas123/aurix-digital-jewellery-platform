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
  String _currentUserId = '';
  Timer? _pollTimer;
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Get current user ID
    final userId = await _chatRepository.getCurrentUserId();
    if (userId != null) {
      setState(() {
        _currentUserId = userId;
      });
    }
    
    // Load initial messages
    await _loadChatHistory();
    
    // Poll for new messages every 2 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (widget.threadId != null && widget.threadId!.isNotEmpty) {
        _loadChatHistory();
      }
    });
  }

  Future<void> _loadChatHistory() async {
    if (widget.threadId == null || widget.threadId!.isEmpty) {
      if (mounted) {
        setState(() {
          _messages = [];
          _loading = false;
        });
      }
      return;
    }

    try {
      // Fetch messages from backend
      final messagesData = await _chatRepository.getMessages(widget.threadId!);
      
      // Convert to ChatMessage objects
      final messages = messagesData.map((m) {
        final senderId = (m['sender_id'] ?? m['sender']?['id'] ?? '').toString();
        final messageText = (m['message_text'] ?? m['message'] ?? m['content'] ?? '').toString();
        final createdAt = m['created_at'] ?? DateTime.now().toIso8601String();
        
        return ChatMessage(
          id: m['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          text: messageText,
          isMe: _currentUserId == senderId,
          time: DateTime.tryParse(createdAt.toString()) ?? DateTime.now(),
        );
      }).toList();

      if (mounted) {
        setState(() {
          _messages = messages;
          _loading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      print('❌ Error loading chat history: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
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

    if (_currentUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not loaded. Try again.')),
      );
      return;
    }

    HapticFeedback.selectionClick();

    // Optimistically add message to UI
    final tempMessage = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: text,
      isMe: true,
      time: DateTime.now(),
    );

    setState(() {
      _messages.add(tempMessage);
      _controller.clear();
    });

    _scrollToBottom();

    // Send to backend
    if (widget.threadId != null && widget.threadId!.isNotEmpty) {
      try {
        print('📤 Sending message: threadId=${widget.threadId}, senderId=$_currentUserId, content=$text');
        
        final result = await _chatRepository.sendMessage(
          threadId: widget.threadId!,
          senderId: _currentUserId,
          content: text,
        );
        
        print('✅ Message sent successfully: ${result['id']}');
        
        // Refresh chat history to show confirmed message
        await Future.delayed(const Duration(milliseconds: 500));
        await _loadChatHistory();
      } catch (e) {
        print('❌ Failed to send message: $e');
        // Remove optimistic message if send failed
        setState(() {
          _messages.removeWhere((m) => m.id == tempMessage.id);
        });
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e')),
        );
      }
    } else {
      print('⚠️ No threadId available');
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
                  : _messages.isEmpty
                      ? const Center(
                          child: Text('No messages yet. Start the conversation!'),
                        )
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: onPickImage,
              child: const Icon(Icons.image_rounded, size: 24),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: onSend,
              child: const Icon(Icons.send_rounded, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
