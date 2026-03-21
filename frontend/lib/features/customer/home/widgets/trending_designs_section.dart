import 'package:flutter/material.dart';
import 'package:aurix/core/widgets/aurix_glass_card.dart';
import 'package:aurix/dev/dummy_data/dummy_products.dart';
import 'package:aurix/features/customer/products/models/product.dart';
import 'package:aurix/features/customer/products/product_detail/product_detail_screen.dart';
import 'package:aurix/core/navigation/nav.dart';

class TrendingDesignsSection extends StatelessWidget {
  const TrendingDesignsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final items = DummyProducts.items
        .where((e) => (e["isTrending"] == true))
        .map((e) => Product.fromMap(e))
        .toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (_, i) {
        final p = items[i];
        return GestureDetector(
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
                        height: 80,
                        width: double.infinity,
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                        child: Image.network(
                          p.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.image_outlined,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  p.jeweller,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  p.priceLabel,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}