import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:aurix/core/theme/app_colors.dart';
import 'package:aurix/core/widgets/aurix_glass_card.dart';

import 'jeweller_add_product_screen.dart';

class JewellerProductsScreen extends StatelessWidget {
  const JewellerProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      (
        name: "22K Gold Ring",
        price: "LKR 85,000",
        status: "Active",
      ),
      (
        name: "Bridal Necklace Set",
        price: "LKR 240,000",
        status: "Active",
      ),
      (
        name: "Rose Gold Pendant",
        price: "LKR 62,000",
        status: "Draft",
      ),
      (
        name: "Diamond Bangle",
        price: "LKR 180,000",
        status: "Active",
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                "My Products",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const JewellerAddProductScreen(),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.gold,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add_rounded, color: Colors.black, size: 18),
                    SizedBox(width: 6),
                    Text(
                      "Add",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AurixGlassCard(
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.gold.withOpacity(0.25),
                      ),
                    ),
                    child: const Icon(Icons.image_outlined),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.price,
                          style: TextStyle(
                            color: Theme.of(context).hintColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
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
                            item.status,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}