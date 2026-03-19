import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/aurix_background.dart';
import '../../../../core/widgets/aurix_glass_card.dart';

class ProductDetailScreen extends StatelessWidget {
  final dynamic product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  String _readString(dynamic source, String field, String fallback) {
    try {
      final value = source
          .toJson()[field];
      if (value == null) return fallback;
      return value.toString();
    } catch (_) {
      try {
        final value = source.toMap()[field];
        if (value == null) return fallback;
        return value.toString();
      } catch (_) {
        try {
          final value = source[field];
          if (value == null) return fallback;
          return value.toString();
        } catch (_) {
          return fallback;
        }
      }
    }
  }

  bool _isAskPrice(dynamic source) {
    final rawPrice = _readString(source, 'price', '');
    final rawAsk = _readString(source, 'isAskPrice', 'false').toLowerCase();

    if (rawAsk == 'true') return true;
    if (rawPrice.isEmpty) return true;
    if (rawPrice == '0') return true;
    if (rawPrice.toLowerCase() == 'ask price') return true;

    return false;
  }

  String _priceLabel(dynamic source) {
    if (_isAskPrice(source)) return 'Ask Price';

    final rawPrice = _readString(source, 'price', '0');
    if (rawPrice.toLowerCase().contains('lkr')) return rawPrice;

    return 'LKR $rawPrice';
  }

  @override
  Widget build(BuildContext context) {
    final title = _readString(product, 'name', 'Jewellery Product');
    final jeweller = _readString(product, 'jeweller', 'Aurix Jeweller');
    final description = _readString(
      product,
      'description',
      'Beautiful jewellery product from a verified jeweller.',
    );
    final priceText = _priceLabel(product);
    final askPrice = _isAskPrice(product);

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
                      'Product Detail',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 12),
              AurixGlassCard(
                child: Container(
                  height: 240,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.gold.withOpacity(0.20),
                    ),
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    size: 60,
                    color: AppColors.gold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AurixGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      jeweller,
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: askPrice
                            ? AppColors.gold.withOpacity(0.16)
                            : AppColors.gold.withOpacity(0.12),
                        border: Border.all(
                          color: AppColors.gold.withOpacity(0.22),
                        ),
                      ),
                      child: Text(
                        priceText,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Added to cart.'),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.gold.withOpacity(0.28),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Add to Cart',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Quotation request flow next.'),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: AppColors.gold,
                        ),
                        child: const Center(
                          child: Text(
                            'Get Quotation',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}