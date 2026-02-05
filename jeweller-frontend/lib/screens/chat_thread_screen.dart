import 'package:flutter/material.dart';
import 'quotation_detail_screen.dart';

class ChatThreadScreen extends StatefulWidget {
  final VoidCallback? onViewed;
  
  const ChatThreadScreen({super.key, this.onViewed});

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  static const Color primaryColor = Color(0xFFD4AF35);
  
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hello! Welcome to LUXE Jewellers. How can I help you today?',
      'isUser': false,
      'time': '10:00 AM',
      'type': 'text',
    },
    {
      'text': 'Hi! I\'m looking for a custom engagement ring.',
      'isUser': true,
      'time': '10:02 AM',
      'type': 'text',
    },
    {
      'text': 'That\'s wonderful! Congratulations! We specialize in custom pieces. What style are you considering?',
      'isUser': false,
      'time': '10:03 AM',
      'type': 'text',
    },
    {
      'text': 'I\'m thinking of a classic solitaire with a round diamond.',
      'isUser': true,
      'time': '10:05 AM',
      'type': 'text',
    },
    {
      'text': 'Excellent choice! What is your budget range and preferred metal?',
      'isUser': false,
      'time': '10:06 AM',
      'type': 'text',
    },
    {
      'text': 'Around Rs. 300,000 to 400,000. I prefer 18K white gold.',
      'isUser': true,
      'time': '10:08 AM',
      'type': 'text',
    },
    {
      'text': 'Perfect! Based on your preferences, I\'ve prepared a quotation for you.',
      'isUser': false,
      'time': '10:15 AM',
      'type': 'text',
    },
    {
      'text': '',
      'isUser': false,
      'time': '10:15 AM',
      'type': 'quotation',
      'quotationData': {
        'title': '18K White Gold Solitaire Ring',
        'price': 'Rs. 350,000',
        'sku': 'LXE-SR-0891',
      },
    },
    {
      'text': 'This looks perfect! Thank you so much.',
      'isUser': true,
      'time': '10:20 AM',
      'type': 'text',
    },
    {
      'text': 'You\'re welcome! Would you like to proceed with this design?',
      'isUser': false,
      'time': '10:21 AM',
      'type': 'text',
    },
    {
      'text': 'Yes, please. Can we also discuss matching wedding bands?',
      'isUser': true,
      'time': '10:25 AM',
      'type': 'text',
    },
    {
      'text': 'Absolutely! I\'ll prepare some options for matching bands. Give me a moment.',
      'isUser': false,
      'time': '10:26 AM',
      'type': 'text',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Mark as viewed when screen opens
    if (widget.onViewed != null) {
      Future.delayed(Duration.zero, () {
        widget.onViewed!();
      });
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          'text': _messageController.text,
          'isUser': true,
          'time': _formatTime(TimeOfDay.now()),
          'type': 'text',
        });
      });
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF201D12) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 1,
        backgroundColor: isDark ? const Color(0xFF2A271A) : Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            // Shop avatar placeholder
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.store,
                color: primaryColor.withOpacity(0.5),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "LUXE Jewellers",
              style: TextStyle(
                fontSize: 18,
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.call,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calling shop...')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                
                if (message['type'] == 'quotation') {
                  return QuotationMessageCard(
                    quotationData: message['quotationData'],
                    isDark: isDark,
                  );
                }
                
                return message['isUser']
                    ? RightChatBubble(
                        message: message['text'],
                        time: message['time'],
                        isDark: isDark,
                      )
                    : LeftChatBubble(
                        message: message['text'],
                        time: message['time'],
                        isDark: isDark,
                      );
              },
            ),
          ),
          ChatInputField(
            controller: _messageController,
            onSend: _sendMessage,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

/* =======================
   CHAT BUBBLES
   ======================= */

class LeftChatBubble extends StatelessWidget {
  final String message;
  final String time;
  final bool isDark;
  
  const LeftChatBubble({
    super.key,
    required this.message,
    required this.time,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A271A) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RightChatBubble extends StatelessWidget {
  final String message;
  final String time;
  final bool isDark;
  
  const RightChatBubble({
    super.key,
    required this.message,
    required this.time,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: const Color(0xFFD4AF37),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* =======================
   QUOTATION CARD
   ======================= */

class QuotationMessageCard extends StatelessWidget {
  final Map<String, dynamic> quotationData;
  final bool isDark;
  
  const QuotationMessageCard({
    super.key,
    required this.quotationData,
    required this.isDark,
  });

  static const Color primaryColor = Color(0xFFD4AF35);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A271A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.diamond,
              size: 24,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quotationData['title'],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  quotationData['price'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  quotationData['sku'],
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 32,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuotationDetailScreen(),
                  ),
                );
              },
              child: const Text(
                "View",
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* =======================
   CHAT INPUT FIELD
   ======================= */

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isDark;
  
  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSend,
    required this.isDark,
  });

  static const Color primaryColor = Color(0xFFD4AF35);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A271A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Type a message...",
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF201D12) : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: primaryColor,
            radius: 22,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: onSend,
            ),
          ),
        ],
      ),
    );
  }
}
