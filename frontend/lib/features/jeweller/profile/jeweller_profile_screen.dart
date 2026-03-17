import 'package:flutter/material.dart';

import 'package:aurix/core/widgets/aurix_glass_card.dart';
import 'package:aurix/core/theme/app_colors.dart';

class JewellerProfileScreen extends StatelessWidget {
  const JewellerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      children: [
        const Text(
          "Jeweller Profile",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 16),

        const AurixGlassCard(
          child: Column(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: Color(0x22D4AF37),
                child: Icon(
                  Icons.storefront_rounded,
                  size: 34,
                  color: AppColors.gold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                "Luxe Jewels",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
              ),
              SizedBox(height: 6),
              Text(
                "Verified Jeweller",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        const AurixGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Shop Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 12),
              _InfoRow(label: "Owner", value: "Tharindu Perera"),
              SizedBox(height: 8),
              _InfoRow(label: "Email", value: "luxejewels@gmail.com"),
              SizedBox(height: 8),
              _InfoRow(label: "Mobile", value: "+94 77 123 4567"),
              SizedBox(height: 8),
              _InfoRow(label: "Location", value: "Colombo"),
            ],
          ),
        ),

        const SizedBox(height: 16),

        AurixGlassCard(
          child: Column(
            children: [
              _actionTile(context, Icons.edit_rounded, "Edit Profile"),
              const SizedBox(height: 10),
              _actionTile(context, Icons.inventory_rounded, "Manage Products"),
              const SizedBox(height: 10),
              _actionTile(context, Icons.logout_rounded, "Logout"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionTile(BuildContext context, IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}