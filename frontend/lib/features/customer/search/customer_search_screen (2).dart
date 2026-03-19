import 'package:flutter/material.dart';
import 'package:aurix/core/widgets/aurix_glass_card.dart';

class CustomerSearchScreen extends StatelessWidget {
  const CustomerSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      children: [
        AurixGlassCard(
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search jewellery, jewellers, categories…",
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search_rounded),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const AurixGlassCard(
          child: Text(
            "Search results will appear here.",
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}