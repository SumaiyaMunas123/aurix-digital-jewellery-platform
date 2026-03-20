import 'package:flutter/material.dart';
import 'package:aurix/core/navigation/nav.dart';
import 'package:aurix/core/widgets/aurix_page_scaffold.dart';
import 'package:aurix/core/widgets/aurix_glass_card.dart';
import 'package:aurix/dev/dummy_data/dummy_products.dart';
import 'package:aurix/features/customer/products/models/product.dart';
import 'package:aurix/features/customer/products/product_detail/product_detail_screen.dart';

class NewArrivalsScreen extends StatelessWidget {
  final String? titleOverride;
  const NewArrivalsScreen({super.key, this.titleOverride});

  @override
  Widget build(BuildContext context) {
    final items = DummyProducts.items
        .where((e) => e['isNew'] == true)
        .map((e) => Product.fromMap(e))
        .toList();

    return AurixPageScaffold(
      title: titleOverride ?? "New Arrivals",
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final p = items[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AurixGlassCard(
              child: ListTile(
                onTap: () => Nav.push(context, ProductDetailScreen(product: p)),
                leading: const Icon(Icons.image_outlined),
                title: Text(p.name,
                    style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text(p.jeweller),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            ),
          );
        },
      ),
    );
  }
}
