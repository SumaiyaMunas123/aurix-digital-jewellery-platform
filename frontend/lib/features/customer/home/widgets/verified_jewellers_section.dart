import 'package:flutter/material.dart';
import 'package:aurix/core/widgets/aurix_glass_card.dart';
import 'package:aurix/dev/dummy_data/dummy_jewellers.dart';
import 'package:aurix/core/theme/app_colors.dart';

class VerifiedJewellersSection extends StatelessWidget {
  const VerifiedJewellersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final items = DummyJewellers.items;

    return Column(
      children: items.map((j) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AurixGlassCard(
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold.withOpacity(0.18),
                    border: Border.all(color: AppColors.gold.withOpacity(0.35)),
                  ),
                  child: const Icon(Icons.verified_rounded, color: AppColors.gold),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "${j["name"]}  •  ${j["city"]}",
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}