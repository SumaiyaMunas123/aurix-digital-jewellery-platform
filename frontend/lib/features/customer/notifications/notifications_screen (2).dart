import 'package:flutter/material.dart';
import 'package:aurix/core/widgets/aurix_background.dart';
import 'package:aurix/core/widgets/aurix_glass_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      {
        "title": "Quotation reply received",
        "subtitle": "Luxe Jewels replied to your quotation request.",
        "icon": Icons.request_quote_rounded,
      },
      {
        "title": "New message",
        "subtitle": "Aurora Gold sent you a message.",
        "icon": Icons.chat_bubble_rounded,
      },
      {
        "title": "Price alert",
        "subtitle": "Gold rate changed today.",
        "icon": Icons.currency_exchange_rounded,
      },
      {
        "title": "New deal available",
        "subtitle": "A new jewellery deal has been added.",
        "icon": Icons.local_offer_rounded,
      },
    ];

    return Scaffold(
      body: AurixBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        "Notifications",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return AurixGlassCard(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              const Color(0xFFD4AF37).withOpacity(0.15),
                          child: Icon(
                            item["icon"] as IconData,
                            color: const Color(0xFFD4AF37),
                          ),
                        ),
                        title: Text(
                          item["title"] as String,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        subtitle: Text(item["subtitle"] as String),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}