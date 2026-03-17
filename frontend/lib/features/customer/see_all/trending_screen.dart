import 'package:flutter/material.dart';
import 'package:aurix/core/widgets/aurix_page_scaffold.dart';
import 'package:aurix/core/widgets/aurix_glass_card.dart';

class TrendingScreen extends StatelessWidget {
  const TrendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AurixPageScaffold(
      title: "Trending",
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
        itemCount: 12,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemBuilder: (_, i) {
          return AurixGlassCard(
            child: Center(
              child: Text("Design ${i + 1}", style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
          );
        },
      ),
    );
  }
}