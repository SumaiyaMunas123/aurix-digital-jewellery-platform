import 'package:flutter/material.dart';
import 'quotation_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  final VoidCallback onViewed;
  
  const NotificationScreen({super.key, required this.onViewed});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  static const Color primaryColor = Color(0xFFD4AF35);

  final List<Map<String, dynamic>> notifications = [
    {
      'type': 'chat',
      'title': 'New message from LUXE Jewellers',
      'message': 'Thank you for your interest in our products!',
      'time': '5 min ago',
      'isRead': false,
    },
    {
      'type': 'quotation',
      'title': 'New Quotation Received',
      'message': 'Veni Jewellers sent you a quotation for Gold Bangle',
      'time': '1 hour ago',
      'isRead': false,
    },
    {
      'type': 'chat',
      'title': 'New message from Cartier',
      'message': 'We have the ring you requested in stock',
      'time': '2 hours ago',
      'isRead': false,
    },
    {
      'type': 'order',
      'title': 'Order Confirmed',
      'message': 'Your order #12345 has been confirmed',
      'time': '1 day ago',
      'isRead': true,
    },
    {
      'type': 'promotion',
      'title': 'Special Offer!',
      'message': '20% off on all diamond jewellery this weekend',
      'time': '2 days ago',
      'isRead': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Mark as viewed when screen opens
    Future.delayed(Duration.zero, () {
      widget.onViewed();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF201D12) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF2A271A) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 1,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationCard(notification, isDark);
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, bool isDark) {
    IconData icon;
    Color iconColor;

    switch (notification['type']) {
      case 'chat':
        icon = Icons.chat_bubble_outline;
        iconColor = Colors.blue;
        break;
      case 'quotation':
        icon = Icons.description_outlined;
        iconColor = primaryColor;
        break;
      case 'order':
        icon = Icons.shopping_bag_outlined;
        iconColor = Colors.green;
        break;
      case 'promotion':
        icon = Icons.local_offer_outlined;
        iconColor = Colors.orange;
        break;
      default:
        icon = Icons.notifications_outlined;
        iconColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () {
        if (notification['type'] == 'quotation') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const QuotationDetailScreen(),
            ),
          );
        } else if (notification['type'] == 'chat') {
          Navigator.pushNamed(context, '/chat-thread');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification['isRead']
              ? (isDark ? const Color(0xFF2A271A) : Colors.white)
              : (isDark
                  ? const Color(0xFF2A271A).withOpacity(0.8)
                  : primaryColor.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification['isRead']
                ? (isDark ? Colors.grey[800]! : Colors.grey[300]!)
                : primaryColor.withOpacity(0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification['title'],
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (!notification['isRead'])
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification['message'],
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification['time'],
                    style: TextStyle(
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
