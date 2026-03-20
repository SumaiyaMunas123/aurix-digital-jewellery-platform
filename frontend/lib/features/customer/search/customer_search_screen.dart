import 'package:flutter/material.dart';

import 'package:aurix/core/navigation/nav.dart';
import 'package:aurix/core/widgets/aurix_glass_card.dart';
import 'package:aurix/dev/dummy_data/dummy_jewellers.dart';
import 'package:aurix/dev/dummy_data/dummy_products.dart';
import 'package:aurix/features/customer/jewellers/jeweller_detail_screen.dart';
import 'package:aurix/features/customer/products/models/product.dart';
import 'package:aurix/features/customer/products/product_detail/product_detail_screen.dart';

class CustomerSearchScreen extends StatefulWidget {
  const CustomerSearchScreen({super.key});

  @override
  State<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends State<CustomerSearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final products =
        DummyProducts.items.map((e) => Product.fromMap(e)).toList();
    final jewellers = DummyJewellers.items;
    final q = _query.trim().toLowerCase();

    final productResults = q.isEmpty
        ? const <Product>[]
        : products.where((p) {
            return p.name.toLowerCase().contains(q) ||
                p.jeweller.toLowerCase().contains(q) ||
                p.category.toLowerCase().contains(q);
          }).toList();

    final jewellerResults = q.isEmpty
        ? const <Map<String, String>>[]
        : jewellers.where((j) {
            final name = (j['name'] ?? '').toLowerCase();
            final city = (j['city'] ?? '').toLowerCase();
            return name.contains(q) || city.contains(q);
          }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      children: [
        AurixGlassCard(
          child: TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: const InputDecoration(
              hintText: 'Search jewellery, jewellers, categories…',
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (q.isEmpty)
          const AurixGlassCard(
            child: Text(
              'Type to search products and jewellers.',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          )
        else ...[
          Text(
            'Products',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(height: 8),
          if (productResults.isEmpty)
            const AurixGlassCard(
              child: Text('No matching products.',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            )
          else
            ...productResults.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AurixGlassCard(
                  child: ListTile(
                    onTap: () =>
                        Nav.push(context, ProductDetailScreen(product: p)),
                    title: Text(
                      p.name,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text('${p.jeweller} • ${p.priceLabel}'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 10),
          Text(
            'Jewellers',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(height: 8),
          if (jewellerResults.isEmpty)
            const AurixGlassCard(
              child: Text('No matching jewellers.',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            )
          else
            ...jewellerResults.map(
              (j) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AurixGlassCard(
                  child: ListTile(
                    onTap: () => Nav.push(
                      context,
                      JewellerDetailScreen(
                        jewellerName: j['name'] ?? 'Jeweller',
                        city: j['city'] ?? '-',
                      ),
                    ),
                    title: Text(
                      j['name'] ?? 'Jeweller',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(j['city'] ?? '-'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}
