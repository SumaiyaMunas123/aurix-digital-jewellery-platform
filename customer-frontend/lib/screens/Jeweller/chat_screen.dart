import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String chatName;

  const ChatScreen({super.key, required this.chatName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const Color gold = Color(0xFFD4AF37);
  static const Color card = Color(0xFF141414);

  final TextEditingController _controller = TextEditingController();

  final List<_Message> _messages = [
    _Message(text: 'Hi, I’m interested in the ring.', isMe: false),
    _Message(text: 'Sure! Which karat do you prefer?', isMe: true),
  ];

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_Message(text: text, isMe: true));
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title:
            Text(widget.chatName, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                return Align(
                  alignment:
                      m.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: m.isMe ? gold : card,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      m.text,
                      style: TextStyle(
                        color: m.isMe ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.black,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type message...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: gold),
                  onPressed: _send,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isMe;

  _Message({required this.text, required this.isMe});
}