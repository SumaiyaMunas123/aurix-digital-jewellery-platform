import 'package:flutter/material.dart';
import 'package:aurix/core/widgets/aurix_glass_card.dart';
import 'package:aurix/dev/dummy_data/dummy_products.dart';
import 'package:aurix/features/customer/products/models/product.dart';
import 'package:aurix/features/customer/products/product_detail/product_detail_screen.dart';
import 'package:aurix/core/navigation/nav.dart';

class DealsSection extends StatelessWidget {
  const DealsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final items = DummyProducts.items
        .where((e) => (e["isDeal"] == true))
        .map((e) => Product.fromMap(e))
        .toList();

    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final p = items[i];
          return SizedBox(
            width: 260,
            child: GestureDetector(
              onTap: () => Nav.push(context, ProductDetailScreen(product: p)),
              child: AurixGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (p.imageUrl != null && p.imageUrl!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 70,
                            width: double.infinity,
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                            child: Image.network(
                              p.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.image_outlined,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Text("Deal", style: TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    const Spacer(),
                    Text(p.priceLabel, style: const TextStyle(fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}