import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/aurix_glass_card.dart';
import '../../customer/home/widgets/live_gold_rate_card.dart';

class JewellerDashboardScreen extends StatelessWidget {
  const JewellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      children: [
        const Text(
          "Dashboard",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Overview of your shop activity and market updates.",
          style: TextStyle(
            color: Theme.of(context).hintColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        const LiveGoldRateCard(),
        const SizedBox(height: 16),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.18,
          children: const [
            _StatsCard(
              title: "Total Products",
              value: "24",
              icon: Icons.inventory_2_rounded,
            ),
            _StatsCard(
              title: "Pending Quotes",
              value: "08",
              icon: Icons.request_quote_rounded,
            ),
            _StatsCard(
              title: "Total Orders",
              value: "12",
              icon: Icons.shopping_bag_rounded,
            ),
            _StatsCard(
              title: "Revenue",
              value: "LKR 240K",
              icon: Icons.payments_rounded,
            ),
          ],
        ),

        const SizedBox(height: 18),

        const AurixGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Today's Summary",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 12),
              _SummaryRow(label: "New quotation requests", value: "3"),
              SizedBox(height: 8),
              _SummaryRow(label: "Products viewed", value: "87"),
              SizedBox(height: 8),
              _SummaryRow(label: "Unread chats", value: "5"),
              SizedBox(height: 8),
              _SummaryRow(label: "Wishlist adds", value: "11"),
              SizedBox(height: 8),
              _SummaryRow(label: "Orders placed today", value: "2"),
            ],
          ),
        ),

        const SizedBox(height: 18),

        const AurixGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Business Insights",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 12),
              _SummaryRow(label: "Top performing category", value: "Rings"),
              SizedBox(height: 8),
              _SummaryRow(label: "Low response quotations", value: "2"),
              SizedBox(height: 8),
              _SummaryRow(label: "Most saved product", value: "Bridal Necklace"),
              SizedBox(height: 8),
              _SummaryRow(label: "Active listings", value: "21"),
            ],
          ),
        ),

        const SizedBox(height: 18),

        const AurixGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 12),
              _QuickActionTile(
                icon: Icons.add_box_rounded,
                title: "Add New Product",
              ),
              SizedBox(height: 10),
              _QuickActionTile(
                icon: Icons.request_quote_rounded,
                title: "Review Quotations",
              ),
              SizedBox(height: 10),
              _QuickActionTile(
                icon: Icons.chat_bubble_rounded,
                title: "Open Messages",
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatsCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AurixGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.gold,
            size: 26,
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).hintColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;

  const _QuickActionTile({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}