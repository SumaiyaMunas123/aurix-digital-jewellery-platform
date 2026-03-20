import 'package:flutter/material.dart';
import 'package:aurix/core/navigation/nav.dart';
import 'package:aurix/dev/dummy_data/dummy_products.dart';
import 'package:aurix/features/customer/products/models/product.dart';
import 'package:aurix/features/customer/products/product_detail/product_detail_screen.dart';
import 'package:aurix/core/widgets/aurix_page_scaffold.dart';
import 'package:aurix/core/widgets/aurix_glass_card.dart';

class TrendingScreen extends StatelessWidget {
  const TrendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = DummyProducts.items
        .where((e) => e['isTrending'] == true)
        .map((e) => Product.fromMap(e))
        .toList();

    return AurixPageScaffold(
      title: "Trending",
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, i) {
          final p = items[i];
          return GestureDetector(
            onTap: () => Nav.push(context, ProductDetailScreen(product: p)),
            child: AurixGlassCard(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(p.priceLabel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
