import 'package:flutter/material.dart';

class EnquiriesScreen extends StatefulWidget {
  const EnquiriesScreen({super.key});

  @override
  State<EnquiriesScreen> createState() => _EnquiriesScreenState();
}

class _EnquiriesScreenState extends State<EnquiriesScreen> {
  static const Color gold = Color(0xFFD4AF37);
  static const Color card = Color(0xFF141414);

  int _selectedTab = 0; // 0=new, 1=replied, 2=closed

  final List<_Enquiry> _all = const [
    _Enquiry(
      customerName: 'Nimal Perera',
      itemName: '22K Gold Ring',
      message: 'Can you share the final price with making charges?',
      time: '10:24 AM',
      status: _EnquiryStatus.newEnquiry,
    ),
    _Enquiry(
      customerName: 'Sithumi Jayasinghe',
      itemName: 'Gold Necklace (Custom)',
      message: 'I need a custom design similar to this. Possible?',
      time: 'Yesterday',
      status: _EnquiryStatus.newEnquiry,
    ),
    _Enquiry(
      customerName: 'Kavindu Silva',
      itemName: 'Bracelet - 18K',
      message: 'Thanks. Can you reduce the making charge a little?',
      time: 'Mon',
      status: _EnquiryStatus.replied,
    ),
    _Enquiry(
      customerName: 'Ayesha Fernando',
      itemName: 'Earrings (Studs)',
      message: 'Order confirmed. Please update delivery timeline.',
      time: 'Sun',
      status: _EnquiryStatus.closed,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Enquiries',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _tabs(),
            const SizedBox(height: 14),

            Expanded(
              child: filtered.isEmpty
                  ? _emptyState()
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final e = filtered[index];
                        return _EnquiryCard(
                          enquiry: e,
                          onTap: () {
                            // Later: Navigate to enquiry detail screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Open enquiry: ${e.itemName} (detail later)'),
                              ),
                            );
                          },
                          onChat: () {
                            // Later: Navigate to chat
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Open chat with ${e.customerName} (later)'),
                              ),
                            );
                          },
                          onReply: () {
                            // Later: reply/quotation UI
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Reply / Quotation (later)')),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabs() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          _tabButton('New', 0),
          _tabButton('Replied', 1),
          _tabButton('Closed', 2),
        ],
      ),
    );
  }

  Widget _tabButton(String text, int index) {
    final selected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? gold : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Text(
        'No enquiries found.',
        style: TextStyle(color: Colors.white.withOpacity(0.7)),
      ),
    );
  }

  List<_Enquiry> _filtered() {
    if (_selectedTab == 0) {
      return _all.where((e) => e.status == _EnquiryStatus.newEnquiry).toList();
    } else if (_selectedTab == 1) {
      return _all.where((e) => e.status == _EnquiryStatus.replied).toList();
    }
    return _all.where((e) => e.status == _EnquiryStatus.closed).toList();
  }
}

class _EnquiryCard extends StatelessWidget {
  final _Enquiry enquiry;
  final VoidCallback onTap;
  final VoidCallback onReply;
  final VoidCallback onChat;

  const _EnquiryCard({
    required this.enquiry,
    required this.onTap,
    required this.onReply,
    required this.onChat,
  });

  static const Color gold = Color(0xFFD4AF37);
  static const Color card = Color(0xFF141414);

  @override
  Widget build(BuildContext context) {
    final statusUI = _statusUI(enquiry.status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // top row
            Row(
              children: [
                Expanded(
                  child: Text(
                    enquiry.customerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Text(
                  enquiry.time,
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // item + badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    enquiry.itemName,
                    style: TextStyle(color: Colors.white.withOpacity(0.85)),
                  ),
                ),
                _Badge(text: statusUI.text, color: statusUI.color),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              enquiry.message,
              style: TextStyle(color: Colors.white.withOpacity(0.7), height: 1.3),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onChat,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.18)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Chat'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onReply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(enquiry.status == _EnquiryStatus.closed ? 'View' : 'Reply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _StatusUI _statusUI(_EnquiryStatus s) {
    switch (s) {
      case _EnquiryStatus.newEnquiry:
        return const _StatusUI(text: 'NEW', color: gold);
      case _EnquiryStatus.replied:
        return const _StatusUI(text: 'REPLIED', color: Colors.lightBlueAccent);
      case _EnquiryStatus.closed:
        return const _StatusUI(text: 'CLOSED', color: Colors.greenAccent);
    }
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

enum _EnquiryStatus { newEnquiry, replied, closed }

class _Enquiry {
  final String customerName;
  final String itemName;
  final String message;
  final String time;
  final _EnquiryStatus status;

  const _Enquiry({
    required this.customerName,
    required this.itemName,
    required this.message,
    required this.time,
    required this.status,
  });
}

class _StatusUI {
  final String text;
  final Color color;

  const _StatusUI({required this.text, required this.color});
}
