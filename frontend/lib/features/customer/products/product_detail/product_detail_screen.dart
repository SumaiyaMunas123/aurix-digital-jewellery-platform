import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/aurix_background.dart';
import '../../../../core/widgets/aurix_glass_card.dart';

class ProductDetailScreen extends StatefulWidget {
  final dynamic product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  bool isInWishlist = false;

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

  @override
  Widget build(BuildContext context) {
    final title = _readString(widget.product, 'name', 'Jewellery Product');
    final jeweller = _readString(widget.product, 'jeweller', 'Aurix Jeweller');
    final description = _readString(
      widget.product,
      'description',
      'Beautiful jewellery piece',
    );
    final priceText = _priceLabel(widget.product);
    final askPrice = _isAskPrice(widget.product);

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
                      color: AppColors.gold.withValues(alpha: 0.20),
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
                            ? AppColors.gold.withValues(alpha: 0.16)
                            : AppColors.gold.withValues(alpha: 0.12),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.22),
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
                    const SizedBox(height: 24),
                    // Product Specifications
                    const Text(
                      'Specifications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSpecRow('Metal Type', _readString(widget.product, 'metal_type', 'Gold')),
                    _buildSpecRow('Karat', _readString(widget.product, 'karat', '18K')),
                    _buildSpecRow('Weight', '${_readString(widget.product, 'weight_grams', '0')} grams'),
                    _buildSpecRow('Category', _readString(widget.product, 'category', 'Jewellery')),
                    _buildSpecRow('Making Charge', '₹${_readString(widget.product, 'making_charge', '0')}')
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Quantity Selector
              AurixGlassCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: quantity > 1
                              ? () {
                                  setState(() => quantity--);
                                }
                              : null,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.gold.withValues(alpha: 0.2),
                              ),
                            ),
                            child: const Icon(Icons.remove, size: 20),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            quantity.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() => quantity++);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.gold.withValues(alpha: 0.2),
                              ),
                            ),
                            child: const Icon(Icons.add, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Action Buttons
              Row(
                children: [
                  // Wishlist Button
                  GestureDetector(
                    onTap: () {
                      setState(() => isInWishlist = !isInWishlist);
                      HapticFeedback.selectionClick();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isInWishlist
                                ? 'Added to wishlist'
                                : 'Removed from wishlist',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isInWishlist
                              ? AppColors.gold
                              : AppColors.gold.withValues(alpha: 0.28),
                        ),
                        color: isInWishlist
                            ? AppColors.gold.withValues(alpha: 0.12)
                            : null,
                      ),
                      child: Icon(
                        isInWishlist ? Icons.favorite : Icons.favorite_border,
                        color: isInWishlist ? AppColors.gold : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Add to Cart Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added $quantity item(s) to cart'),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.28),
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
                  // Get Quotation Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Quotation request initiated'),
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
                            'Quotation',
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

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).hintColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _priceLabel(dynamic source) {
    if (_isAskPrice(source)) {
      return 'Ask Price';
    }
    final price = _readString(source, 'price', '0');
    return '₹$price';
  }
}