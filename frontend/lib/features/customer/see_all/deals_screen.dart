import 'package:flutter/material.dart';
import 'package:aurix/core/widgets/aurix_page_scaffold.dart';
import 'package:aurix/core/widgets/aurix_glass_card.dart';
import 'package:aurix/dev/dummy_data/dummy_products.dart';
import 'package:aurix/features/customer/products/models/product.dart';

class DealsScreen extends StatelessWidget {
  const DealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = DummyProducts.items
        .where((e) => e["isDeal"] == true)
        .map((e) => Product.fromMap(e))
        .toList();

    return AurixPageScaffold(
      title: "Deals",
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final p = items[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AurixGlassCard(
              child: ListTile(
                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text(p.priceLabel),
                trailing: const Icon(Icons.local_offer_rounded),
              ),
            ),
          );
        },
      ),
    );
  }
}