import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:aurix/core/widgets/aurix_glass_card.dart';
import 'package:aurix/features/customer/wishlist/data/wishlist_store.dart';
import 'package:aurix/dev/dummy_data/dummy_products.dart';
import 'package:aurix/features/customer/products/models/product.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<WishlistStore>();
    final all = DummyProducts.items.map((e) => Product.fromMap(e)).toList();
    final favs = all.where((p) => store.contains(p.id)).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      children: [
        const Text("Wishlist", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        const SizedBox(height: 12),
        if (favs.isEmpty)
          const AurixGlassCard(
            child: Text("No items in wishlist yet.", style: TextStyle(fontWeight: FontWeight.w800)),
          )
        else
          ...favs.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AurixGlassCard(
                  child: ListTile(
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                    subtitle: Text(p.jeweller),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite_rounded),
                      onPressed: () => store.toggle(p.id),
                    ),
                  ),
                ),
              )),
      ],
    );
  }
}