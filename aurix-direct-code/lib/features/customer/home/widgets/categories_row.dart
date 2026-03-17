import 'package:flutter/material.dart';
import 'package:aurix/core/widgets/aurix_glass_card.dart';

class CategoriesRow extends StatelessWidget {
  const CategoriesRow({super.key});

  static const _cats = [
    "Rings",
    "Necklaces",
    "Pendants",
    "Bangles",
    "Bracelets",
    "Earrings",
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          return AurixGlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            radius: 999,
            child: Text(_cats[i], style: const TextStyle(fontWeight: FontWeight.w900)),
          );
        },
      ),
    );
  }
}