import 'package:flutter/material.dart';

import '../../../core/navigation/nav.dart';
import '../../../core/widgets/aurix_background.dart';
import '../../../core/widgets/aurix_glass_card.dart';
import '../../../dev/dummy_data/dummy_products.dart';
import '../products/models/product.dart';
import '../products/product_detail/product_detail_screen.dart';
import '../products/product_detail/quotation_request_screen.dart';

class JewellerDetailScreen extends StatelessWidget {
  final String jewellerName;
  final String city;

  const JewellerDetailScreen({
    super.key,
    required this.jewellerName,
    required this.city,
  });

  @override
  Widget build(BuildContext context) {
    final products = DummyProducts.items
        .where((e) => (e['jeweller'] ?? '').toString() == jewellerName)
        .map((e) => Product.fromMap(e))
        .toList();

    return Scaffold(
      body: AurixBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const Expanded(
                    child: Text(
                      'Jeweller',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 12),
              AurixGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jewellerName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      city,
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Available Products',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              if (products.isEmpty)
                const AurixGlassCard(
                  child: Text(
                    'No products available yet.',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                )
              else
                ...products.map(
                  (product) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AurixGlassCard(
                      child: ListTile(
                        onTap: () => Nav.push(
                          context,
                          ProductDetailScreen(product: product),
                        ),
                        title: Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        subtitle: Text(product.priceLabel),
                        trailing: IconButton(
                          icon: const Icon(Icons.request_quote_rounded),
                          onPressed: () => Nav.push(
                            context,
                            QuotationRequestScreen(
                              productName: product.name,
                              jewellerName: jewellerName,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
