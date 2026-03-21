import 'package:flutter/material.dart';
import 'package:aurix/core/widgets/aurix_glass_card.dart';
import 'package:aurix/dev/dummy_data/dummy_products.dart';
import 'package:aurix/features/customer/products/models/product.dart';
import 'package:aurix/features/customer/products/product_detail/product_detail_screen.dart';
import 'package:aurix/core/navigation/nav.dart';

class NewArrivalsSection extends StatelessWidget {
  const NewArrivalsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final items = DummyProducts.items
        .where((e) => (e["isNew"] == true))
        .map((e) => Product.fromMap(e))
        .toList();

    return Column(
      children: items.map((p) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => Nav.push(context, ProductDetailScreen(product: p)),
            child: AurixGlassCard(
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.20)),
                    ),
                    child: p.imageUrl != null && p.imageUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              p.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined),
                            ),
                          )
                        : const Icon(Icons.image_outlined),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 6),
                        Text(p.jeweller, style: TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _chip(p.karat),
                            const SizedBox(width: 8),
                            _chip(p.weight),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.25)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
    );
  }
}