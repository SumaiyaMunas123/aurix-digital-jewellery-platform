import 'package:flutter/material.dart';
import 'package:aurix/core/widgets/aurix_glass_card.dart';

class TrendingDesignsSection extends StatelessWidget {
  const TrendingDesignsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemBuilder: (_, i) {
        return AurixGlassCard(
          child: Center(
            child: Text(
              "Design ${i + 1}",
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        );
      },
    );
  }
}