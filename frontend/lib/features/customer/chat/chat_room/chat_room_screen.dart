import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';


import 'package:aurix/features/customer/chat/models/chat_message.dart';
import 'package:aurix/features/customer/chat/data/chat_api.dart';
import 'package:aurix/core/theme/app_colors.dart';


class ChatRoomScreen extends StatefulWidget {
  final String title;
  final String? threadId;
  final String? myUserId;

  const ChatRoomScreen({
    super.key,
    required this.title,
    this.threadId,
    this.myUserId,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {

  final _picker = ImagePicker();
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  List<ChatMessage> _messages = [];
  bool _loading = true;
  bool _sending = false;

  bool get _hasRemoteChatContext {
    final tid = widget.threadId?.trim();
    final uid = widget.myUserId?.trim();
    return tid != null && tid.isNotEmpty && uid != null && uid.isNotEmpty;
  }


  @override
  void initState() {
    super.initState();
    if (_hasRemoteChatContext) {
      _loadMessages();
      _markAsRead();
    } else {
      _messages = [
        ChatMessage(id: '1', text: 'Hi! How can I help you today?', isMe: false, time: DateTime.now()),
        ChatMessage(id: '2', text: 'I want a 22K ring design.', isMe: true, time: DateTime.now()),
      ];
      _loading = false;
    }
  }

  Future<void> _loadMessages() async {
    if (!_hasRemoteChatContext) return;

    setState(() => _loading = true);
    try {
      final msgs = await ChatApi.getMessages(widget.threadId!, widget.myUserId!);
      setState(() {
        _messages = msgs;
        _loading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load messages: $e')));
      }
    }
  }

  Future<void> _markAsRead() async {
    if (!_hasRemoteChatContext) return;

    try {
      await ChatApi.markAsRead(threadId: widget.threadId!, userId: widget.myUserId!);
    } catch (_) {}
  }

  @override
  void dispose() {
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
    if (text.isEmpty || _sending) return;

    HapticFeedback.selectionClick();

    if (!_hasRemoteChatContext) {
      setState(() {
        _messages.add(ChatMessage(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          text: text,
          isMe: true,
          time: DateTime.now(),
        ));
        _controller.clear();
      });
      _scrollToBottom();
      return;
    }

    setState(() => _sending = true);
    try {
      await ChatApi.sendMessage(
        threadId: widget.threadId!,
        senderId: widget.myUserId!,
        text: text,
      );
      _controller.clear();
      await _loadMessages();
      await _markAsRead();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send: $e')));
      }
    } finally {
      setState(() => _sending = false);
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
    final isMe = m.isMe;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bubbleColor = isMe
        ? AppColors.gold.withOpacity(0.95)
        : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06));

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
              : Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.08)),
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
        border: Border(top: BorderSide(color: (isDark ? Colors.white : Colors.black).withOpacity(0.08))),
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
                  borderSide: BorderSide(color: (isDark ? Colors.white : Colors.black).withOpacity(0.10)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(color: (isDark ? Colors.white : Colors.black).withOpacity(0.10)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(color: AppColors.gold.withOpacity(0.6)),
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