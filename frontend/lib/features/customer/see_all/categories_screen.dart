import 'package:flutter/material.dart';
import 'package:aurix/core/widgets/aurix_page_scaffold.dart';
import 'package:aurix/core/widgets/aurix_glass_card.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static const cats = [
    "Rings",
    "Necklaces",
    "Pendants",
    "Bangles",
    "Bracelets",
    "Earrings",
  ];

  @override
  Widget build(BuildContext context) {
    return AurixPageScaffold(
      title: "Categories",
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
        itemCount: cats.length,
        itemBuilder: (context, i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AurixGlassCard(
              child: ListTile(
                title: Text(cats[i], style: const TextStyle(fontWeight: FontWeight.w900)),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            ),
          );
        },
      ),
    );
  }
}