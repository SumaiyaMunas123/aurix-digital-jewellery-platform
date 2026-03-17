import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:aurix/core/widgets/aurix_glass_card.dart';
import 'package:aurix/core/theme/app_colors.dart';

class QuotationRequestsScreen extends StatelessWidget {
  const QuotationRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final requests = const [
      (
        customer: "Nimal Perera",
        item: "Custom 22K Ring Design",
        date: "Today",
      ),
      (
        customer: "Ayesha Fernando",
        item: "Bridal Necklace Inquiry",
        date: "Today",
      ),
      (
        customer: "Kavindu Silva",
        item: "Pendant Price Request",
        date: "Yesterday",
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      children: [
        const Text(
          "Quotation Requests",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          "Review and respond to customer requests.",
          style: TextStyle(
            color: Theme.of(context).hintColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...requests.map(
          (q) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AurixGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0x22D4AF37),
                        child: Icon(
                          Icons.request_quote_rounded,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          q.customer,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        q.date,
                        style: TextStyle(
                          color: Theme.of(context).hintColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    q.item,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Reply screen next.")),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: AppColors.gold,
                            ),
                            child: const Center(
                              child: Text(
                                "Reply",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Marked for later.")),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.gold.withOpacity(0.25),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                "Later",
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}