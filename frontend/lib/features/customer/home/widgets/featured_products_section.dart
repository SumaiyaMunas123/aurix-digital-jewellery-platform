import 'package:flutter/material.dart';
import 'package:aurix/core/widgets/aurix_glass_card.dart';
import 'package:aurix/dev/dummy_data/dummy_products.dart';
import 'package:aurix/features/customer/products/models/product.dart';
import 'package:aurix/features/customer/products/product_detail/product_detail_screen.dart';
import 'package:aurix/core/navigation/nav.dart';

class FeaturedProductsSection extends StatelessWidget {
  const FeaturedProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final items = DummyProducts.items
        .where((e) => (e["isFeatured"] == true))
        .map((e) => Product.fromMap(e))
        .toList();

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final p = items[i];
          return SizedBox(
            width: 220,
            child: GestureDetector(
              onTap: () => Nav.push(context, ProductDetailScreen(product: p)),
              child: AurixGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(p.jeweller, style: TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Row(
                      children: [
                        _chip(p.karat),
                        const SizedBox(width: 8),
                        _chip(p.weight),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      p.priceLabel,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
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