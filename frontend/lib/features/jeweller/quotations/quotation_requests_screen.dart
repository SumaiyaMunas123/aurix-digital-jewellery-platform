import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/aurix_glass_card.dart';
import '../../customer/quotations/data/quotation_store.dart';
import 'quotation_reply_screen.dart';

class QuotationRequestsScreen extends StatelessWidget {
  const QuotationRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<QuotationStore>();

    final requests = store.requestsForJeweller('Luxe Jewels');

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
        if (requests.isEmpty)
          const AurixGlassCard(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No quotation requests yet.',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          )
        else
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
                            q.customerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.gold.withOpacity(0.25),
                            ),
                          ),
                          child: Text(
                            q.status,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      q.productName,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Size: ${q.size}  •  Qty: ${q.quantity}',
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      q.notes.isEmpty ? 'No notes' : q.notes,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => QuotationReplyScreen(
                                    request: q,
                                  ),
                                ),
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
                              context
                                  .read<QuotationStore>()
                                  .updateStatus(q.id, 'Later');
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